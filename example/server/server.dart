import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

Future<void> startServer() async {
  final server = await ServerSocket.bind('0.0.0.0', 5555);
  print('TCP server started at ${server.address}:${server.port}.');

  try {
    server.listen((Socket socket) {
      print(
          'New TCP client ${socket.address.address}:${socket.port} connected.');

      var totalSeconds = 0;
      final timer = Timer.periodic(Duration(seconds: 60), (timer) {
        totalSeconds += timer.tick;
        socket.add(totalSeconds.toString().codeUnits);
      });
      socket.handleError(() {
        print('Connection closed');
        timer.cancel();
      }).listen((Uint8List data) {
        print('Incoming message from client: ${String.fromCharCodes(data)}');
      });
    });
  } on SocketException catch (ex) {
    print(ex.message);
  }
}

void main() {
  startServer();
}
