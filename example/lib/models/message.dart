enum MessageOrigin { Client, Server }

class Message {
  final DateTime timestamp;
  final String message;
  final MessageOrigin origin;

  Message({
    required this.timestamp,
    required this.message,
    required this.origin
  });
}
