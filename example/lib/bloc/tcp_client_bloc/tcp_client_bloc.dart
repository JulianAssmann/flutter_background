import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_example/models/message.dart';
import 'package:flutter_background_example/models/socket_connection_state.dart';
import '../../utils/notification_service.dart';

part 'tcp_client_event.dart';
part 'tcp_client_state.dart';

class TcpClientBloc extends Bloc<TcpClientEvent, TcpClientState> {
  Socket? _socket;
  StreamSubscription? _socketStreamSub;

  TcpClientBloc() : super(TcpClientState.initial());

  @override
  Stream<TcpClientState> mapEventToState(
    TcpClientEvent event,
  ) async* {
    if (event is Connect) {
      yield* _mapConnectToState(event);
    } else if (event is Disconnect) {
      yield* _mapDisconnectToState();
    } else if (event is ErrorOccured) {
      yield* _mapErrorToState();
    } else if (event is MessageReceived) {
      yield* _mapMessageReceivedToState(event);
    } else if (event is SendMessage) {
      yield* _mapSendMessageToState(event);
    }
  }

  Stream<TcpClientState> _mapConnectToState(Connect event) async* {
    yield state.copywith(connectionState: SocketConnectionState.Connecting);

    var hasPermissions = await FlutterBackground.hasPermissions;
    if (!hasPermissions) {
      // TODO: Show warning to user or something
      print('hasPermissions: $hasPermissions');
    }
    try {
      final config = FlutterBackgroundAndroidConfig(
        notificationTitle: 'flutter_background example app',
        notificationText:
            'Background notification for keeping the example app running in the background',
        notificationIcon: AndroidResource(name: 'background_icon'),
      );
      // Demonstrate calling initialize twice in a row is possible without causing problems.
      hasPermissions =
          await FlutterBackground.initialize(androidConfig: config);
      hasPermissions =
          await FlutterBackground.initialize(androidConfig: config);
    } catch (ex) {
      print(ex);
    }
    if (hasPermissions) {
      final backgroundExecution =
          await FlutterBackground.enableBackgroundExecution();
      if (backgroundExecution) {
        try {
          _socket = await Socket.connect(event.host, event.port);
          _socketStreamSub = _socket!.asBroadcastStream().listen((event) {
            add(MessageReceived(
                message: Message(
              message: String.fromCharCodes(event),
              timestamp: DateTime.now(),
              origin: MessageOrigin.Server,
            )));
          });
          _socket!.handleError(() {
            add(ErrorOccured());
          });

          yield state.copywith(
              connectionState: SocketConnectionState.Connected);
        } catch (err) {
          print(err);
          yield state.copywith(connectionState: SocketConnectionState.Failed);
        }
        return;
      }
    }
    yield state.copywith(connectionState: SocketConnectionState.Failed);
  }

  Stream<TcpClientState> _mapDisconnectToState() async* {
    yield state.copywith(connectionState: SocketConnectionState.Disconnecting);
    await _socketStreamSub?.cancel();
    await _socket?.close();
    await FlutterBackground.disableBackgroundExecution();
    yield state
        .copywith(connectionState: SocketConnectionState.None, messages: []);
  }

  Stream<TcpClientState> _mapSendMessageToState(SendMessage event) async* {
    if (_socket != null) {
      yield state.copyWithNewMessage(
          message: Message(
        message: event.message,
        timestamp: DateTime.now(),
        origin: MessageOrigin.Client,
      ));
      _socket!.write(event.message);
    }
  }

  @override
  Future<void> close() {
    _socketStreamSub?.cancel();
    _socket?.close();
    return super.close();
  }

  Stream<TcpClientState> _mapErrorToState() async* {
    yield state.copywith(connectionState: SocketConnectionState.Failed);
    await _socketStreamSub?.cancel();
    await _socket?.close();
  }

  Stream<TcpClientState> _mapMessageReceivedToState(
      MessageReceived event) async* {
    await NotificationService().newNotification(event.message.message, false);
    yield state.copyWithNewMessage(message: event.message);
  }
}
