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
        title: const Text('Form App'),
      ),
      // Corpo da tela com os botões de navegação
      body: Center(
        child: Column(
          // Centraliza os botões verticalmente
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão para acessar o formulário de cadastro
            ElevatedButton(
              onPressed: () {
                // Navega para a tela de formulário
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormScreen()),
                );
              },
              child: const Text('Ir para o Formulário'),
            ),
            // Espaçamento entre os botões
            const SizedBox(height: 16),
            // Botão para acessar a lista de usuários
            ElevatedButton(
              onPressed: () {
                // Navega para a tela de listagem de usuários
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserListScreen()),
                );
              },
              child: const Text('Ver Usuários Cadastrados'),
            ),
          ],
        ),
      ),
    );
  }
} 