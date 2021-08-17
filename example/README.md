# flutter_background example

This app demonstrantes the use of the flutter_background plugin.
For demonstration purposes it uses TCP sockets to 'chats' with a TCP server.

The app allows the user to create a TCP connection to a TCP server identified by a hostname and a port the user can enter. A chat-like UI allows to receive messages from and send messages to the server. The user is notified about incoming messages by creating notifications using [flutter_local_notifications](https://github.com/MaikuB/flutter_local_notifications).

Using the `flutter_background` plugin, the app continues to receive messages from the server when running in the background.

The `server` folder contains a very simple TCP server that accepts incoming connections. It shows incoming messages from the client and sends messages written in the terminal to the client. Additionally it sends messages to the client in an interval of 5 seconds in order to demonstrate, that the app can receive messages even when running in the background.

## Requirements

You need to have the following tools installed:

- [Flutter](https://flutter.dev/docs/get-started/install)

## Run

To start the server, go into the `server` folder and run

```bash
dart server.dart
```

To start the app, go into the `app` folder and run

```bash
flutter run
```

## Configuration

In the server file (`server/server.dart`) you can configure the hostname and port of the TCP server by setting the `const` values `hostname` and `port`.

If you run the app in the Android Emulator, set the `hostname` in `server.dart` to `localhost` and input the IP address `10.0.2.2` (the hosts IP address from inside the Android Emulator) in the app.

If you run the app on a real device, set the `hostname` in `server.dart` and in the client app to the IP address of the machine in the local network (obtained via `ifconfig` (Linux/Mac OS) or `ipconfig` (Windows)).

The ports specified in the server and the app must be the same.

## Tools used

- [Flutter](https://flutter.dev/)
- [bubble](https://github.com/vi-k/bubble)
- [flutter_local_notifications](https://github.com/MaikuB/flutter_local_notifications)