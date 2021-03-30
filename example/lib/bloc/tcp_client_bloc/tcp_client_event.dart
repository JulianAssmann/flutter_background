part of 'tcp_client_bloc.dart';

@immutable
abstract class TcpClientEvent {}

/// Represents a request for a connection to a server.
class Connect extends TcpClientEvent {
  /// The host of the server to connect to.
  final dynamic host;

  /// The port of the server to connect to.
  final int port;

  Connect({required this.host, required this.port});

  @override
  String toString() => '''Connect {
    host: $host,
    port: $port
  }''';
}

/// Represents a request to disconnect from the server or abort the current connection request.
class Disconnect extends TcpClientEvent {
  @override
  String toString() => 'Disconnect { }';
}

/// Represents a socket error.
class ErrorOccured extends TcpClientEvent {
  @override
  String toString() => '''ErrorOccured { }''';
}

/// Represents the event of an incoming message from the TCP server.
class MessageReceived extends TcpClientEvent {
  final Message message;

  MessageReceived({required this.message});

  @override
  String toString() => '''MessageReceived {
    message: $message,
  }''';
}

/// Represents a request to send a message to the TCP server.
class SendMessage extends TcpClientEvent {
  /// The message to be sent to the TCP server.
  final String message;

  SendMessage({required this.message});

  @override
  String toString() => 'SendMessage { }';
}
