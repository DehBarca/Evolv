// models/perfil.dart
class Perfil {
  final String nombre;
  final String apellido;
  final int edad;
  final String? fotoUrl;
  final String email;
  final String sobreMi;
  final String objetivos;

  Perfil({
    required this.nombre,
    required this.apellido,
    required this.edad,
    this.fotoUrl,
    this.email = 'usuario@ejemplo.com',
    this.sobreMi =
        'Habla un poco sobre ti aquí. Esta es una sección donde puedes describirte a ti mismo, tus intereses, pasatiempos, y cualquier otra información que quieras compartir.',
    this.objetivos =
        'Aquí puedes escribir tus objetivos personales o profesionales. Describe lo que esperas lograr, tus metas a corto y largo plazo, y cómo planeas alcanzarlas.',
  });
}
