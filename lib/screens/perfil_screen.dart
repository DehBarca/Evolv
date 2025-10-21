import 'package:flutter/material.dart';
import '../models/perfil.dart';
import '../constants/app_constants.dart';

class PerfilScreen extends StatefulWidget {
  final Perfil? perfil;

  const PerfilScreen({super.key, this.perfil});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late String nombre;
  late String apellidos;
  late String edad;
  late String email;
  late String sobreMi;
  late String objetivos;
  late String imagenUrl;

  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidosController = TextEditingController();
  TextEditingController edadController = TextEditingController();
  TextEditingController sobreMiController = TextEditingController();
  TextEditingController objetivosController = TextEditingController();
  TextEditingController imagenController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Si no se pasa un perfil, vamos a usar valores por defecto
    if (widget.perfil != null) {
      nombre = widget.perfil!.nombre;
      apellidos = widget.perfil!.apellido;
      edad = widget.perfil!.edad.toString();
      email = widget.perfil!.email;
      sobreMi = widget.perfil!.sobreMi;
      objetivos = widget.perfil!.objetivos;
      imagenUrl = widget.perfil!.fotoUrl ?? 'https://via.placeholder.com/120';
    } else {
      // Valores por defecto
      nombre = 'Tu nombre';
      apellidos = 'Tus apellidos';
      edad = 'Tu edad';
      email = 'usuario@ejemplo.com';
      sobreMi =
          'Habla un poco sobre ti aquí. Esta es una sección donde puedes describirte a ti mismo, tus intereses, pasatiempos, y cualquier otra información que quieras compartir.';
      objetivos =
          'Aquí puedes escribir tus objetivos personales o profesionales. Describe lo que esperas lograr, tus metas a corto y largo plazo, y cómo planeas alcanzarlas.';
      imagenUrl = 'https://via.placeholder.com/120';
    }
  }

  // Función para mostrar diálogos
  void _mostrarDialogo(String boton) {
    String mensaje = '';
    String titulo = '';

    switch (boton) {
      case 'Editar':
        _mostrarDialogoEditar();
        return;
      case 'Compartir':
        titulo = 'Compartir Perfil';
        mensaje = 'Vas a compartir tu perfil con otros';
        break;
      case 'Mis Objetivos':
        titulo = 'Mis Objetivos';
        mensaje = 'Vas a ver o editar tus objetivos';
        break;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          ),
          title: Text(
            titulo,
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(mensaje, style: AppTextStyles.bodyText),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withOpacity(0.6),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                boxShadow: AppShadows.buttonShadow,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.action,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                  ),
                ),
                child: Text('ACEPTAR', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        );
      },
    );
  }

  // Diálogo de edición
  void _mostrarDialogoEditar() {
    nombreController.text = nombre;
    apellidosController.text = apellidos;
    edadController.text = edad;
    sobreMiController.text = sobreMi;
    objetivosController.text = objetivos;
    imagenController.text = imagenUrl;

    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.borderRadius * 1.5),
            ),
            elevation: 16,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primaryBackground, Colors.white],
                ),
                borderRadius: BorderRadius.circular(
                  AppSizes.borderRadius * 1.5,
                ),
              ),
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Editar Perfil',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Widget foto de perfil
                    Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: AppShadows.cardShadow,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            imagenController.text.isNotEmpty
                                ? imagenController.text
                                : 'https://via.placeholder.com/120',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.secondaryBackground,
                                child: Icon(
                                  Icons.person,
                                  size: AppSizes.iconSizeLarge,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    _buildEditField(
                      controller: imagenController,
                      label: 'URL de la imagen',
                      icon: Icons.image,
                      hintText: 'https://ejemplo.com/imagen.jpg',
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    _buildEditField(
                      controller: nombreController,
                      label: 'Nombre',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    _buildEditField(
                      controller: apellidosController,
                      label: 'Apellidos',
                      icon: Icons.people,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    _buildEditField(
                      controller: edadController,
                      label: 'Edad',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),

                    _buildEmailField(),
                    const SizedBox(height: AppSizes.paddingLarge),

                    _buildEditSection(
                      controller: sobreMiController,
                      title: 'Sobre mí',
                      icon: Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    _buildEditSection(
                      controller: objetivosController,
                      title: 'Mis objetivos',
                      icon: Icons.flag_outlined,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Widget botones editar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadius,
                              ),
                              boxShadow: AppShadows.buttonShadow,
                            ),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingMedium,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.borderRadius,
                                  ),
                                ),
                                side: BorderSide(color: AppColors.borderColor),
                              ),
                              child: Text(
                                'CANCELAR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.paddingMedium),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSizes.borderRadius,
                              ),
                              boxShadow: AppShadows.buttonShadow,
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                _guardarCambios();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.action,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSizes.paddingMedium,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.borderRadius,
                                  ),
                                ),
                              ),
                              child: Text(
                                'GUARDAR',
                                style: AppTextStyles.buttonText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget campos de edición
  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: AppDecorations.cardDecoration.copyWith(color: Colors.white),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppSizes.iconSizeSmall,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary.withOpacity(0.8),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget campo email no editable
  Widget _buildEmailField() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: AppColors.secondaryBackground.withOpacity(0.3),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.acentoSuave.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.email,
              color: AppColors.acentoSuave,
              size: AppSizes.iconSizeSmall,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: AppColors.textPrimary.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  // Widget secciones de edición
  Widget _buildEditSection({
    required TextEditingController controller,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: AppDecorations.cardDecoration.copyWith(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Container(height: 1, color: AppColors.borderColor),
          const SizedBox(height: AppSizes.paddingMedium),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _guardarCambios() {
    setState(() {
      nombre = nombreController.text;
      apellidos = apellidosController.text;
      edad = edadController.text;
      sobreMi = sobreMiController.text;
      objetivos = objetivosController.text;
      imagenUrl = imagenController.text.isNotEmpty
          ? imagenController.text
          : 'https://via.placeholder.com/120';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBackground, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Widget foto de perfil principal
                    Center(
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          boxShadow: AppShadows.cardShadow,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.secondaryBackground,
                                child: Icon(
                                  Icons.person,
                                  size: AppSizes.iconSizeLarge,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.paddingXLarge),

                    // Widget cards de información
                    _buildInfoCard('Nombre', nombre, Icons.person),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildInfoCard('Apellidos', apellidos, Icons.people),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildInfoCard('Edad', edad, Icons.cake),
                    const SizedBox(height: AppSizes.paddingMedium),
                    _buildEmailCard(),

                    const SizedBox(height: AppSizes.paddingLarge),

                    // Widget botones principales
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: AppSizes.paddingSmall,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadius,
                                ),
                                boxShadow: AppShadows.buttonShadow,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _mostrarDialogo('Editar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.paddingMedium,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.borderRadius,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.edit, size: 18),
                                label: Text(
                                  'Editar',
                                  style: AppTextStyles.buttonText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: AppSizes.paddingSmall,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.borderRadius,
                                ),
                                boxShadow: AppShadows.buttonShadow,
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () => _mostrarDialogo('Compartir'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSizes.paddingMedium,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.borderRadius,
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.share, size: 18),
                                label: Text(
                                  'Compartir',
                                  style: AppTextStyles.buttonText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.paddingXLarge),

                    // Widget sección sobre mí
                    _buildSectionCard(
                      'Sobre mí',
                      sobreMi,
                      Icons.info_outline,
                      AppColors.primary,
                    ),

                    const SizedBox(height: AppSizes.paddingLarge),

                    // Widget sección objetivos
                    _buildSectionCard(
                      'Mis objetivos',
                      objetivos,
                      Icons.flag_outlined,
                      AppColors.success,
                    ),

                    const SizedBox(height: AppSizes.paddingXLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget card información personal
  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: AppDecorations.cardDecoration.copyWith(color: Colors.white),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppSizes.iconSizeSmall,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget card email
  Widget _buildEmailCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: AppDecorations.cardDecoration.copyWith(
        color: AppColors.secondaryBackground.withOpacity(0.3),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.acentoSuave.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.email,
              color: AppColors.acentoSuave,
              size: AppSizes.iconSizeSmall,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_outline,
            color: AppColors.textPrimary.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  // Widget secciones con cards
  Widget _buildSectionCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: AppDecorations.cardDecoration.copyWith(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Container(height: 1, color: AppColors.borderColor),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
