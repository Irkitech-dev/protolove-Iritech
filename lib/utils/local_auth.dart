import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticateWithBiometrics() async {
  try {
    final bool canAuthenticate =
        await auth.canCheckBiometrics || await auth.isDeviceSupported();

    if (!canAuthenticate) return false;

    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Autentícate para continuar',
      
    );

    return didAuthenticate;
  } catch (e) {
    return false;
  }
}