import 'dart:async';
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_example/message.dart';
import 'package:flutter_background_example/socket_connection_state.dart';
import 'package:flutter_background_example/validators.dart';

import 'notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController? _hostEditingController;
  TextEditingController? _portEditingController;
  TextEditingController? _chatTextEditingController;
  Timer? _timer;
  int _timerTotalSeconds = 0;

  List<Message> _messages = [];

  Socket? _socket;
  StreamSubscription? _socketStreamSub;
  SocketConnectionState _state = SocketConnectionState.none;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _hostEditingController = TextEditingController(text: '10.0.2.2');
    _portEditingController = TextEditingController(text: '6666');
    _chatTextEditingController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_background exmaple'), actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            showAboutDialog(
                applicationName: 'flutter_background example',
                context: context);
          },
        )
      ]),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case SocketConnectionState.none:
        return _buildConnectionDetails();
      case SocketConnectionState.connecting:
        return const Text('Connecting');
      case SocketConnectionState.connected:
        return _buildChat();
      case SocketConnectionState.failed:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Connection failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3)));
        setState(() {
          _state = SocketConnectionState.none;
        });
        return Container();
      case SocketConnectionState.disconnecting:
        return const Text('Disconnecting');
    }
  }

  /// Builds the UI that allows for filling in the connection details
  /// (IP address, port) and initiate the connection.
  Widget _buildConnectionDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _hostEditingController,
              autovalidateMode: AutovalidateMode.always,
              validator: (str) => isValidHost(str) ? null : 'Invalid hostname',
              decoration: const InputDecoration(
                helperText: 'The IP address or hostname of the TCP server',
                hintText: 'Enter the address here, e.g. 10.0.2.2',
              ),
            ),
            TextFormField(
              controller: _portEditingController,
              autovalidateMode: AutovalidateMode.always,
              validator: (str) => isValidPort(str) ? null : 'Invalid port',
              decoration: const InputDecoration(
                helperText: 'The port the TCP server is listening on',
                hintText: 'Enter the port here, e. g. 6666',
              ),
            ),
            ElevatedButton(
                onPressed: _state == SocketConnectionState.none
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _connectToServer(_hostEditingController!.text,
                              int.parse(_portEditingController!.text));
                        }
                      }
                    : null,
                child: const Text('Connect')),
          ])),
    );
  }

  /// Builds the UI that allows to chat.
  Widget _buildChat() {
    return Column(children: [
      Expanded(
        child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, idx) {
              final m = _messages[idx];
              return Bubble(
                alignment:
                    m.sender ? Alignment.centerRight : Alignment.centerLeft,
                child: Text(m.text),
              );
            }),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(hintText: 'Message'),
                controller: _chatTextEditingController,
              ),
            ),
            IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_chatTextEditingController!.text.isNotEmpty) {
                    final message =
                        Message(_chatTextEditingController!.text, true);
                    _socket!.write(message.text);
                    _chatTextEditingController!.text = '';
                    setState(() {
                      _messages = _messages.toList()..add(message);
                    });
                  }
                })
          ],
        ),
      ),
      ElevatedButton(
        child: const Text('Disconnect'),
        onPressed: () {
          _disconnectFromServer();
        },
      )
    ]);
  }

  Future<void> _connectToServer(String host, int port) async {
    const config = FlutterBackgroundAndroidConfig(
      notificationTitle: 'flutter_background example app',
      notificationText:
          'Background notification for keeping the example app running in the background',
      notificationIcon: AndroidResource(name: 'background_icon'),
      notificationImportance: AndroidNotificationImportance.normal,
      enableWifiLock: true,
      showBadge: true,
    );

    var hasPermissions = await FlutterBackground.hasPermissions;
    if (!hasPermissions) {
      await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: const Text('Permissions needed'),
                content: const Text(
                    'Shortly the OS will ask you for permission to execute this app in the background. This is required in order to receive chat messages when the app is not in the foreground.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ]);
          });
    }

    hasPermissions = await FlutterBackground.initialize(androidConfig: config);

    if (hasPermissions) {
      if (hasPermissions) {
        final backgroundExecution =
            await FlutterBackground.enableBackgroundExecution();
        if (backgroundExecution) {
          try {
            setState(() {
              _state = SocketConnectionState.connecting;
            });

            _socket = await Socket.connect(host, port);
            _socketStreamSub =
                _socket!.asBroadcastStream().listen((data) async {
              final message =
                  'Message from server: ${String.fromCharCodes(data)}';
              await NotificationService().newNotification(message, false);
              setState(() {
                _messages = _messages.toList()..add(Message(message, false));
              });

              _timer?.cancel();
              _timer = Timer(const Duration(seconds: 60), () {
                _timerTotalSeconds += _timer!.tick;

                _timerTotalSeconds += 10;

                final hours = _timerTotalSeconds ~/ 3600;
                final minutes = (_timerTotalSeconds ~/ 60) % 60;
                final seconds = _timerTotalSeconds % 60;
                final message =
                    'Background service alive for ${hours}h ${minutes}m ${seconds}s';

                _messages = _messages.toList()..add(Message(message, false));
              });
            }, onError: (err) {
              print(err);
              setState(() {
                _state = SocketConnectionState.failed;
              });
              _disconnectFromServer();
            }, onDone: () {
              setState(() {
                _state = SocketConnectionState.failed;
              });
              _disconnectFromServer();
            }, cancelOnError: true);

            setState(() {
              _state = SocketConnectionState.connected;
            });
          } catch (ex) {
            print(ex);
            _socket?.close();
            _socketStreamSub?.cancel();
            _socket = null;
            _socketStreamSub = null;
            setState(() {
              _state = SocketConnectionState.failed;
            });
          }
        }
      }
    }
  }

  Future<void> _disconnectFromServer() async {
    setState(() {
      _state = SocketConnectionState.disconnecting;
    });

    await _socketStreamSub?.cancel();
    await _socket?.close();
    await FlutterBackground.disableBackgroundExecution();
    _socket = null;
    _socketStreamSub = null;

    setState(() {
      _messages = [];
      _state = SocketConnectionState.none;
    });
  }
}
