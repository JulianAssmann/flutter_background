import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'dart:typed_data';

Future<void> startServer() async {
  final server = await ServerSocket.bind('0.0.0.0', 6666);
  print('TCP server started at ${server.address}:${server.port}.');

  try {
    server.listen((Socket socket) {
      print(
          'New TCP client ${socket.address.address}:${socket.port} connected.');
      var totalSeconds = 0;
      final timer = Timer.periodic(Duration(seconds: 10), (timer) {
        totalSeconds += 10;

        final hours = totalSeconds ~/ 3600;
        final minutes = (totalSeconds ~/ 60) % 60;
        final seconds = totalSeconds % 60;
        final message =
            '${DateTime.now().toString()}: ${hours}h ${minutes}m ${seconds}s';

        socket.add(message.codeUnits);
        print('Sending message $message');
      });
      socket.handleError((err, stacktrace) {
        print('Connection closed with error $err\nStacktrace: $stacktrace');
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
