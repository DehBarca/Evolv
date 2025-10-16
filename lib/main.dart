import 'package:flutter/material.dart';
import 'screens/perfil_screen.dart';
import 'models/perfil.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final perfil = Perfil(
      nombre: 'Juan',
      apellido: 'Pérez',
      edad: 28,
      fotoUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTpKUEitLoMmkyGNeZ7oyRuw8LYm2Xr3HNER3XifqBmpD_mpNPSCI0sIdbMTbCnasLnmr4&usqp=CAU", // Puedes poner una URL de imagen si tienes una
    );

    return MaterialApp(home: PerfilScreen(perfil: perfil));
  }
}
