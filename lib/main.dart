import 'package:audio_player/just_audio_page.dart';
import 'package:audio_player/player_bloc/just_audio_player_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Player Demo',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: BlocProvider(
        create: (_) => JustAudioPlayerCubit()..init(),
        child: HomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}


