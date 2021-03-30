part of 'tcp_client_bloc.dart';

@immutable
class TcpClientState {
  final SocketConnectionState connectionState;
  final List<Message> messages;

  TcpClientState({
    required this.connectionState,
    required this.messages,
  });

  factory TcpClientState.initial() {
    return TcpClientState(
        connectionState: SocketConnectionState.None, messages: <Message>[]);
  }

  TcpClientState copywith({
    SocketConnectionState? connectionState,
    List<Message>? messages,
  }) {
    return TcpClientState(
      connectionState: connectionState ?? this.connectionState,
      messages: messages ?? this.messages,
    );
  }

  TcpClientState copyWithNewMessage({required Message message}) {
    return TcpClientState(
      connectionState: connectionState,
      messages: List.from(messages)..add(message),
    );
  }
}
