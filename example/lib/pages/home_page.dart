import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_example/bloc/tcp_client_bloc/tcp_client_bloc.dart';
import 'package:flutter_background_example/models/message.dart';
import 'package:flutter_background_example/models/socket_connection_state.dart';
import '../utils/validators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'about_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late TcpClientBloc _tcpBloc;
  TextEditingController? _hostEditingController;
  TextEditingController? _portEditingController;
  TextEditingController? _chatTextEditingController;

  @override
  void initState() {
    super.initState();
    _tcpBloc = BlocProvider.of<TcpClientBloc>(context);

    _hostEditingController = TextEditingController(text: '10.0.2.2');
    _portEditingController = TextEditingController(text: '5555');
    _chatTextEditingController = TextEditingController(text: '');

    _chatTextEditingController!.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCP Client Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return AboutPage();
              }));
            },
          )
        ],
      ),
      body: BlocConsumer<TcpClientBloc, TcpClientState>(
          listener: (BuildContext context, TcpClientState state) {
            if (state.connectionState == SocketConnectionState.Connected) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } else if (state.connectionState == SocketConnectionState.Failed) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('Connection failed'), Icon(Icons.error)],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
            } else {
            }
          },
          builder: (context, state) {
            if (state.connectionState == SocketConnectionState.None ||
                state.connectionState == SocketConnectionState.Failed) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _hostEditingController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (str) =>
                          isValidHost(str) ? null : 'Invalid hostname',
                      decoration: InputDecoration(
                        helperText:
                            'The ip address or hostname of the TCP server',
                        hintText: 'Enter the address here, e.g. 10.0.2.2',
                      ),
                    ),
                    TextFormField(
                      controller: _portEditingController,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (str) =>
                          isValidPort(str) ? null : 'Invalid port',
                      decoration: InputDecoration(
                        helperText: 'The port the TCP server is listening on',
                        hintText: 'Enter the port here, e. g. 8000',
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Connect'),
                      onPressed: isValidHost(_hostEditingController!.text) &&
                              isValidPort(_portEditingController!.text)
                          ? () {
                              _tcpBloc.add(Connect(
                                  host: _hostEditingController!.text,
                                  port:
                                      int.parse(_portEditingController!.text)));
                            }
                          : null,
                    )
                  ],
                ),
              );
            } else if (state.connectionState ==
                SocketConnectionState.Connecting) {
              return Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Connecting...'),
                  ],
                ),
              );
            } else if (state.connectionState ==
                SocketConnectionState.Connected) {
              return Column(children: [
                Expanded(
                  child: Container(
                    child: ListView.builder(
                        itemCount: state.messages.length,
                        itemBuilder: (context, idx) {
                          final m = state.messages[idx];
                          return Bubble(
                            child: Text(m.message),
                            alignment: m.origin == MessageOrigin.Client
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                          );
                        }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Message'),
                          controller: _chatTextEditingController,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _chatTextEditingController!.text.isEmpty
                            ? null
                            : () {
                                _tcpBloc.add(SendMessage(
                                    message: _chatTextEditingController!.text));
                                _chatTextEditingController!.text = '';
                              },
                      )
                    ],
                  ),
                ),
                ElevatedButton(
                  child: Text('Disconnect'),
                  onPressed: () {
                    _tcpBloc.add(Disconnect());
                  },
                ),
              ]);
            } else {
              return Container();
            }
          }),
    );
  }
}