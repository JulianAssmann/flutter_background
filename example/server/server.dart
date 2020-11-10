import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

// TODO: Set your hostname
const String hostname = "192.168.0.32";
const int port = 5555;

Future<void> startServer() async {
  ServerSocket server = await ServerSocket.bind(hostname, port);
  print("TCP server started at ${server.address.address}:${server.port}.");

  server.listen((Socket socket) {
    print("New TCP client ${socket.address.address}:${socket.port} connected.");

    int totalSeconds = 0;
    final timer = Timer.periodic(Duration(seconds: 5), (timer) {
      totalSeconds += 5;
      socket.add(totalSeconds.toString().codeUnits);
    });
    socket
      .handleError(() {
        print("Connection closed");
        timer.cancel();
      })
      .listen((Uint8List data) {
        print("Incoming message from client: ${String.fromCharCodes(data)}");
      });
  });
}

void main() {
  startServer();
}