class Perfil {
  final String nombre;
  final String apellido;
  final int edad;
  final String? fotoUrl;

  Perfil({
    required this.nombre,
    required this.apellido,
    required this.edad,
    this.fotoUrl,
  });
}
