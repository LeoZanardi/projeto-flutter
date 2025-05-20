// Importação dos pacotes necessários
import 'package:flutter/material.dart';
import 'form_screen.dart';
import 'user_list_screen.dart';

// Classe que representa a tela inicial do aplicativo
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior com título
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Bem-vindo à Tech Barber: inovação e estilo no horário definido!',
          style: TextStyle(

              ///Estilos Do titulo (cor, fonte , etc)
              fontFamily: 'Arial',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        backgroundColor:
            const Color.fromARGB(255, 6, 1, 85), //BackgroundColor do titulo
      ),

      // Corpo da tela com os botões de navegação
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormScreen()),
                );
              },
              child: const Text(
                'Fazer um Agendamento',
                style: TextStyle(
                  ///Estilos Do botao (cor, fonte , etc)
                  fontFamily: 'Arial',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 6, 1, 85),
                ),
              ),
            ),

            ///imagem da logo
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 250,
            ),
            // Espaçamento entre os botões
            const SizedBox(height: 20),
            // Botão para acessar a lista de usuários
            ElevatedButton(
              onPressed: () {
                // Navega para a tela de listagem de usuários
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserListScreen()),
                );
              },
              child: const Text(
                'Conferir Horários Marcados',
                style: TextStyle(
                  ///Estilos Do botao (cor, fonte , etc)
                  fontFamily: 'Arial',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 6, 1, 85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
