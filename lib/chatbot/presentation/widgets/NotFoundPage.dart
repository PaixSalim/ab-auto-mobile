import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page non trouvée')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(
                fontSize: 72,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oups ! Cette page semble avoir disparu dans le cyberespace.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            Icon(
              Icons.sentiment_dissatisfied,
              size: 80,
              color: Colors.orange[700],
            ),
            const SizedBox(height: 40),
            const Text(
              'Ne vous inquiétez pas, il arrive même aux meilleurs d\'entre nous de se perdre parfois.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed:
                  () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Retourner à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
