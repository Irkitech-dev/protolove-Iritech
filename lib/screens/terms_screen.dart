// lib/screens/terms_screen.dart

import 'package:flutter/material.dart';

import '../service/service.dart';
import 'screen.dart';

class TermsScreen extends StatefulWidget {
  static const String routeName = 'terms';

  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final TermsService _termsService = TermsService();

  bool accepted = false;
  bool loading = false;

  Future<void> saveTerms() async {
    try {
      setState(() {
        loading = true;
      });

      await _termsService.acceptTerms();

      NavigationService().pushNamedAndRemoveUntil(
        HowItWorksScreen.routeName,
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la aceptación')),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff5f7),
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      '''
TÉRMINOS Y CONDICIONES DE PROTOLOVE

Bienvenido a Protolove.

Al usar esta aplicación aceptas estos términos y condiciones.

1. Uso de la aplicación

Protolove es una aplicación creada para ayudarte a gestionar perfiles, prototipos o información relacionada con compatibilidad.

Debes usar la aplicación de forma responsable y respetuosa.

2. Cuenta de usuario

Eres responsable de la información que ingresas en tu cuenta.

No debes compartir tu cuenta con otras personas.

3. Información almacenada

Protolove puede guardar información como tu nombre, correo, perfil, preferencias, prototipos y datos necesarios para el funcionamiento de la app.

Estos datos se almacenan usando Supabase.

4. Seguridad

La aplicación intenta proteger tus datos, pero ningún sistema es completamente perfecto.

No ingreses información extremadamente sensible o privada.

5. Conducta prohibida

No está permitido:

• Usar información falsa.
• Usar datos de otra persona sin permiso.
• Ofender, acosar o dañar a otros usuarios.
• Intentar acceder a datos que no te pertenecen.
• Usar la aplicación para actividades ilegales.

6. Cambios

Protolove puede cambiar, mejorar o eliminar funciones en futuras versiones.

7. Responsabilidad

Protolove no garantiza resultados exactos ni compatibilidad real. Las decisiones que tomes usando la app son tu responsabilidad.

8. Aceptación

Al marcar la casilla y presionar continuar, confirmas que leíste y aceptas estos términos.
                      ''',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.45,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: accepted,
                activeColor: Colors.pinkAccent,
                onChanged: (value) {
                  setState(() {
                    accepted = value ?? false;
                  });
                },
                title: const Text(
                  'Acepto los términos y condiciones',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: accepted && !loading ? saveTerms : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    loading ? 'Guardando...' : 'Aceptar y continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
