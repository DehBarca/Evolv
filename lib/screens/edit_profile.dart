import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/theme_provider.dart';
import '../services/user_profile_service.dart';
import 'change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _bioController = TextEditingController();
  final _goalsController = TextEditingController();
  final _photoUrlController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileService _profileService = UserProfileService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _bioController.dispose();
    _goalsController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await _profileService.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _nameController.text = profile.firstName;
          _lastNameController.text = profile.lastName;
          _ageController.text = profile.age > 0 ? profile.age.toString() : '';
          _bioController.text = profile.bio;
          _goalsController.text = profile.goals;
          _photoUrlController.text = profile.photoUrl ?? '';
        });
      }
    } catch (e) {
      _showErrorDialog(
        'Error al cargar datos',
        'No se pudieron cargar los datos del perfil: ${e.toString()}',
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final profile = UserProfile(
        uid: _auth.currentUser!.uid,
        firstName: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _auth.currentUser!.email ?? '',
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        bio: _bioController.text.trim(),
        goals: _goalsController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isNotEmpty
            ? _photoUrlController.text.trim()
            : null,
      );

      await _profileService.updateUserProfile(profile);

      _showSuccessDialog(
        'Perfil actualizado',
        'Los datos de tu perfil se han guardado correctamente.',
      );
    } catch (e) {
      _showErrorDialog(
        'Error al guardar',
        'No se pudo actualizar el perfil: ${e.toString()}',
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        // En una implementación real, aquí subirías la imagen a Firebase Storage
        // y obtendrías la URL de descarga. Por ahora, mostramos el path local.
        _showInfoDialog(
          'Imagen seleccionada',
          'Imagen seleccionada: ${image.name}\n\nNota: Para una implementación completa, la imagen se subiría a Firebase Storage y se obtendría una URL pública.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'Error',
        'No se pudo seleccionar la imagen: ${e.toString()}',
      );
    }
  }

  Future<void> _selectImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        // En una implementación real, aquí subirías la imagen a Firebase Storage
        // y obtendrías la URL de descarga. Por ahora, mostramos el path local.
        _showInfoDialog(
          'Foto tomada',
          'Foto tomada: ${image.name}\n\nNota: Para una implementación completa, la imagen se subiría a Firebase Storage y se obtendría una URL pública.',
        );
      }
    } catch (e) {
      _showErrorDialog('Error', 'No se pudo tomar la foto: ${e.toString()}');
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Seleccionar de galería'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Usar URL'),
                onTap: () {
                  Navigator.pop(context);
                  // El campo de URL ya está disponible
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Perfecto'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sección: Foto de perfil
              _buildSectionTitle('Foto de perfil'),
              _buildPhotoSection(isDark, themeProvider),
              const SizedBox(height: 24),

              // Sección: Información personal
              _buildSectionTitle('Información personal'),
              _buildPersonalInfoSection(isDark, themeProvider),
              const SizedBox(height: 24),

              // Sección: Acerca de ti
              _buildSectionTitle('Acerca de ti'),
              _buildBioSection(isDark, themeProvider),
              const SizedBox(height: 24),

              // Sección: Seguridad
              _buildSectionTitle('Seguridad'),
              _buildSecuritySection(isDark, themeProvider),
              const SizedBox(height: 32),

              // Botón guardar
              _buildSaveButton(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPhotoSection(bool isDark, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Vista previa de la foto
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: themeProvider.primaryColor, width: 3),
              ),
              child: ClipOval(
                child: _photoUrlController.text.isNotEmpty
                    ? Image.network(
                        _photoUrlController.text,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: themeProvider.primaryColor,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: themeProvider.primaryColor,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones para cambiar foto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: _showImageOptions,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: themeProvider.primaryColor),
                  ),
                  icon: Icon(
                    Icons.camera_alt,
                    color: themeProvider.primaryColor,
                    size: 18,
                  ),
                  label: Text(
                    'Cambiar foto',
                    style: TextStyle(color: themeProvider.primaryColor),
                  ),
                ),
                if (_photoUrlController.text.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _photoUrlController.clear());
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                    label: const Text(
                      'Quitar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo URL de la foto
            TextFormField(
              controller: _photoUrlController,
              decoration: InputDecoration(
                labelText: 'URL de la foto',
                hintText: 'https://ejemplo.com/foto.jpg',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                floatingLabelStyle: TextStyle(
                  color: themeProvider.primaryColor,
                ),
                prefixIcon: Icon(
                  Icons.image,
                  color: themeProvider.primaryColor,
                ),
              ),
              onChanged: (value) =>
                  setState(() {}), // Para actualizar la vista previa
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(bool isDark, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo nombre
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                floatingLabelStyle: TextStyle(
                  color: themeProvider.primaryColor,
                ),
                prefixIcon: Icon(
                  Icons.person,
                  color: themeProvider.primaryColor,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Campo apellidos
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Apellidos',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                floatingLabelStyle: TextStyle(
                  color: themeProvider.primaryColor,
                ),
                prefixIcon: Icon(
                  Icons.people,
                  color: themeProvider.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo edad
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Edad',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                floatingLabelStyle: TextStyle(
                  color: themeProvider.primaryColor,
                ),
                prefixIcon: Icon(Icons.cake, color: themeProvider.primaryColor),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final age = int.tryParse(value);
                  if (age == null || age < 1 || age > 120) {
                    return 'Ingresa una edad válida (1-120)';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(bool isDark, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo biografía
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Biografía',
                hintText: 'Cuéntanos un poco sobre ti...',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                floatingLabelStyle: TextStyle(
                  color: themeProvider.primaryColor,
                ),
                prefixIcon: Icon(
                  Icons.info_outline,
                  color: themeProvider.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo objetivos
            TextFormField(
              controller: _goalsController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Objetivos y metas',
                hintText: 'Describe tus objetivos personales...',
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeProvider.primaryColor),
                ),
                labelStyle: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                floatingLabelStyle: TextStyle(
                  color: themeProvider.primaryColor,
                ),
                prefixIcon: Icon(
                  Icons.flag_outlined,
                  color: themeProvider.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(bool isDark, ThemeProvider themeProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.lock, color: themeProvider.primaryColor),
              title: const Text(
                'Cambiar contraseña',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Actualiza tu contraseña de acceso'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.primaryColor,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          _isLoading ? 'Guardando...' : 'Guardar cambios',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
