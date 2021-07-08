import 'pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/tcp_client_bloc/tcp_client_bloc.dart';

class BackgroundSocketsExampleApp extends StatefulWidget {
  @override
  _BackgroundSocketsExampleAppState createState() =>
      _BackgroundSocketsExampleAppState();
}

class _BackgroundSocketsExampleAppState
    extends State<BackgroundSocketsExampleApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TcpClientBloc>(create: (context) => TcpClientBloc()),
      ],
      child: MaterialApp(
        home: MainPage(),
      ),
    );
  }
}
