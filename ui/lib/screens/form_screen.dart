import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FormScreen extends StatefulWidget {
  final Map<String, dynamic>? userToEdit;
  const FormScreen({super.key, this.userToEdit});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _hourController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userToEdit != null) {
      _nameController.text = widget.userToEdit!['name'] ?? '';
      _phoneController.text = widget.userToEdit!['phone'] ?? '';
      _dateController.text = widget.userToEdit!['date'] ?? '';
      
      // Normaliza o formato da hora
      final hour = widget.userToEdit!['hour'] ?? '';
      if (hour.isNotEmpty) {
        final parts = hour.split(':');
        if (parts.length >= 2) {
          _hourController.text = '${parts[0].padLeft(2, '0')}:00:00';
        }
      }
    }
  }

  List<String> _getTimeSlots() {
    List<String> timeSlots = [];
    for (int hour = 8; hour <= 11; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00:00');
    }
    for (int hour = 13; hour <= 18; hour++) {
      timeSlots.add('${hour.toString().padLeft(2, '0')}:00:00');
    }
    return timeSlots;
  }

  String _formatTimeDisplay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour <= 12 ? hour : hour - 12;
    return '$displayHour:00 $period';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_hourController.text.isEmpty || !_getTimeSlots().contains(_hourController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione um horário válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = widget.userToEdit != null
          ? 'http://localhost:5001/users/${widget.userToEdit!['id']}'
          : 'http://localhost:5001/post/users';

      final response = widget.userToEdit != null
          ? await http.put(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': _nameController.text,
                'phone': _phoneController.text,
                'date': _dateController.text,
                'hour': _hourController.text,
              }),
            )
          : await http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'name': _nameController.text,
                'phone': _phoneController.text,
                'date': _dateController.text,
                'hour': _hourController.text,
              }),
            );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.userToEdit != null
                ? 'Usuário atualizado com sucesso!'
                : 'Dados enviados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Falha ao enviar dados');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao enviar dados. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userToEdit != null ? 'Editar Usuário' : 'Formulário de Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Por favor, insira seu nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Por favor, insira seu telefone' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _dateController.text = pickedDate.toString().substring(0, 10);
                  }
                },
                validator: (value) => value?.isEmpty ?? true ? 'Por favor, insira uma data' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _hourController.text.isNotEmpty && _getTimeSlots().contains(_hourController.text)
                    ? _hourController.text
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(),
                ),
                items: _getTimeSlots().map((String time) {
                  return DropdownMenuItem<String>(
                    value: time,
                    child: Text(_formatTimeDisplay(time)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _hourController.text = newValue ?? '';
                  });
                },
                validator: (value) => value?.isEmpty ?? true ? 'Por favor, selecione um horário' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(widget.userToEdit != null ? 'Atualizar' : 'Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}