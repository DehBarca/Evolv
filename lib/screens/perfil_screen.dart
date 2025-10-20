import 'package:flutter/material.dart';
import '../models/perfil.dart';

class PerfilScreen extends StatelessWidget {
  final Perfil perfil;

  const PerfilScreen({Key? key, required this.perfil}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0C7F9), // Fondo secundario
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: perfil.fotoUrl != null
                        ? NetworkImage(perfil.fotoUrl!)
                        : null,
                    backgroundColor: const Color(0xFFAC99F4), // acento suave
                    child: perfil.fotoUrl == null
                        ? Icon(Icons.person, color: Color(0xFF240A56), size: 36)
                        : null,
                  ),
                  const SizedBox(width: 20),
                  // Nombre, apellido y edad
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${perfil.nombre} ${perfil.apellido}',
                        style: TextStyle(
                          color: Color(0xFF240A56), // texto oscuro
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Edad: ${perfil.edad}',
                        style: TextStyle(
                          color: Color(0xFF461B9C), // fondo dark para contraste
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8A69EE), // primario
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(Icons.edit),
                      label: Text('Editar perfil'),
                      onPressed: () {
                        // Acción editar
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C31E5), // acción
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(Icons.share),
                      label: Text('Compartir perfil'),
                      onPressed: () {
                        // Acción compartir
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
