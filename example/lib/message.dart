class Message {
  /// Indicates whether or not this client is the sender or not.
  /// `true` means that this client was the sender,
  /// `false` means that the message was received.
  final bool sender;

  /// The text message.
  final String text;

  /// Creates a new messsage.
  ///
  /// [text] is the actual message.
  /// [sender] indicates, whether this client is the sender or not.
  Message(this.text, this.sender);
}
