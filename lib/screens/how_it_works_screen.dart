import 'package:flutter/material.dart';

import '../service/service.dart';
import 'screen.dart';

class HowItWorksScreen extends StatelessWidget {
  static const String routeName = 'how-it-works';

  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffff5f7),
      appBar: AppBar(
        title: const Text('Cómo funciona'),
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
                child: ListView(
                  children: const [
                    Text(
                      '¿Cómo funciona Protolove?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Protolove no decide por ti. La app te ayuda a organizar tus ideas, comparar información y ver con más claridad qué buscas.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    SizedBox(height: 24),
                    _StepCard(
                      number: '1',
                      title: 'Crea tu prototipo',
                      description:
                          'Define qué características son importantes para ti. No se trata de imaginar a una persona perfecta, sino de entender tus preferencias y prioridades.',
                    ),
                    _StepCard(
                      number: '2',
                      title: 'Agrega casos reales',
                      description:
                          'Ingresa personas reales o candidatos para compararlos con tu prototipo de forma ordenada.',
                    ),
                    _StepCard(
                      number: '3',
                      title: 'Califica con objetividad',
                      description:
                          'Evalúa cada característica con calma. Puedes actualizar la información cuando conozcas mejor a la persona.',
                    ),
                    _StepCard(
                      number: '4',
                      title: 'Revisa el resultado',
                      description:
                          'La app genera una puntuación orientativa. No garantiza compatibilidad ni una relación exitosa. Úsalo como guía, no como decisión final.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Recuerda: las relaciones dependen de comunicación, respeto, valores, emociones y decisiones personales. Protolove solo te ayuda a organizar información.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    NavigationService().pushNamedAndRemoveUntil(
                      HomeScreen.routeName,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Entendido, continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            child: Text(number),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 15, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
