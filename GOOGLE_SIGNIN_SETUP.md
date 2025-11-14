# 🔐 Configuración de Google Sign In

## ✅ Código ya implementado

El código para Google Sign In ya está integrado en la aplicación. Ahora necesitas configurar las credenciales en Firebase Console.

## 📋 Pasos para configurar Google Sign In:

### 1. **Configurar en Firebase Console**

#### Para Android:
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto "Evolv"
3. Ve a **Authentication** > **Sign-in method**
4. Habilita **Google** como proveedor
5. Guarda los cambios

#### Obtener SHA-1 y SHA-256 (Android):
```bash
cd android
./gradlew signingReport
```

Copia los valores SHA-1 y SHA-256 de la variante `debug`

6. Ve a **Project Settings** > **Your apps** > selecciona tu app Android
7. Haz clic en "Add fingerprint"
8. Pega el SHA-1 y luego el SHA-256
9. Descarga el nuevo archivo `google-services.json`
10. Reemplázalo en `android/app/google-services.json`

#### Para iOS:
1. En Firebase Console, ve a **Project Settings** > **Your apps** > iOS
2. Descarga el archivo `GoogleService-Info.plist`
3. Copia el **REVERSED_CLIENT_ID**
4. Abre `ios/Runner/Info.plist`
5. Agrega:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>TU_REVERSED_CLIENT_ID_AQUI</string>
    </array>
  </dict>
</array>
```

#### Para Windows/Web:
1. En Firebase Console, habilita Google Sign In
2. Para Web, agrega tus dominios autorizados en la configuración
3. Windows usa la implementación web por defecto

### 2. **Verificar la configuración**

Después de configurar, ejecuta:
```bash
flutter clean
flutter pub get
flutterfire configure
```

### 3. **Probar la aplicación**

```bash
# Para Android
flutter run -d <tu_dispositivo_android>

# Para Windows
flutter run -d windows

# Para Web
flutter run -d chrome
```

## 🎨 Características implementadas:

### En Login Screen (`login.dart`):
- ✅ Botón "Continuar con Google" con icono de Google
- ✅ Divisor visual con texto "O"
- ✅ Indicador de carga durante autenticación
- ✅ Manejo de errores personalizado

### En Register Screen (`register.dart`):
- ✅ Mismo botón de Google Sign In
- ✅ Navegación automática después de autenticarse
- ✅ Consistencia visual con login

### En AuthService (`auth_service.dart`):
- ✅ Método `signInWithGoogle()`
- ✅ Integración con FirebaseAuth
- ✅ Cierre de sesión de Google al cerrar sesión
- ✅ Manejo de errores y cancelaciones

## 🔄 Flujo de Google Sign In:

1. Usuario hace clic en "Continuar con Google"
2. Se muestra el selector de cuenta de Google
3. Usuario selecciona su cuenta
4. Google proporciona las credenciales
5. Firebase autentica al usuario
6. AuthWrapper detecta el cambio y navega a Home
7. La información del usuario (nombre, email, foto) se obtiene automáticamente

## 📝 Notas importantes:

### Permisos necesarios:

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS (`ios/Runner/Info.plist`):**
Ya debería estar configurado por defecto.

### Cancelación del inicio de sesión:
- Si el usuario cancela el proceso, se muestra el mensaje "Inicio de sesión cancelado"
- No afecta al estado de la aplicación

### Primera vez:
- La primera vez que un usuario inicia sesión con Google, Firebase crea automáticamente una cuenta
- Los siguientes inicios de sesión usan la cuenta existente

### Información del usuario:
- El nombre del usuario de Google se muestra en el drawer
- El email se muestra debajo del nombre
- La foto de perfil se puede agregar usando `user.photoURL`

## 🎯 Ventajas de Google Sign In:

1. **Sin contraseñas**: Los usuarios no necesitan crear ni recordar contraseñas
2. **Rápido**: Un solo clic para autenticarse
3. **Seguro**: Usa OAuth 2.0 de Google
4. **Confiable**: Los usuarios confían en Google
5. **Información verificada**: Email verificado automáticamente

## 🐛 Solución de problemas:

### Error: "PlatformException(sign_in_failed)"
- Verifica que el SHA-1 y SHA-256 estén correctamente configurados en Firebase
- Asegúrate de haber descargado el nuevo `google-services.json`
- Ejecuta `flutter clean` y vuelve a compilar

### Error: "10: Developer Error"
- El SHA-1 no está configurado correctamente
- Regenera el SHA-1 con `./gradlew signingReport`
- Agrega todos los SHA-1 (debug y release) en Firebase Console

### El botón no responde:
- Verifica que Google Sign In esté habilitado en Firebase Console
- Revisa los logs con `flutter logs`

### Error en iOS:
- Verifica que el `REVERSED_CLIENT_ID` esté correctamente configurado en `Info.plist`
- Asegúrate de haber agregado el archivo `GoogleService-Info.plist`

## 📱 Testing:

Para probar en diferentes plataformas:

```bash
# Android (requiere dispositivo físico o emulador)
flutter run -d android

# iOS (requiere Mac y simulador/dispositivo iOS)
flutter run -d ios

# Windows
flutter run -d windows

# Web
flutter run -d chrome
```

## ✨ Próximos pasos opcionales:

1. **Agregar foto de perfil**:
   - Usa `user.photoURL` en el drawer para mostrar la foto de Google

2. **Agregar más proveedores**:
   - Facebook Login
   - Apple Sign In
   - Twitter Login

3. **Vincular cuentas**:
   - Permitir que un usuario vincule Google con su cuenta de email/contraseña

## 🔗 Referencias útiles:

- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Google Sign In Flutter](https://pub.dev/packages/google_sign_in)
- [FlutterFire](https://firebase.flutter.dev/)
