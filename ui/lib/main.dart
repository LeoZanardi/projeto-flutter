// Importação dos pacotes necessários
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Função principal que inicia o aplicativo
void main() {
  runApp(const MyApp());
}

// Classe principal do aplicativo que configura o tema e a tela inicial
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título do aplicativo
      title: 'Form App',
      // Configuração do tema com cores e estilo Material 3
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Define a tela inicial como HomeScreen
      home: const HomeScreen(),
    );
  }
}
