import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización simple (Android leerá el google-services.json automáticamente)
  await Firebase.initializeApp();

  runApp(const MiAppPeliculas());
}

class MiAppPeliculas extends StatelessWidget {
  const MiAppPeliculas({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Actividad 3.7 Firebase',
      debugShowCheckedModeBanner: false,
      home: PantallaFirebase(),
    );
  }
}

class PantallaFirebase extends StatelessWidget {
  // Referencia a la colección en la nube
  final CollectionReference coleccionPeliculas = FirebaseFirestore.instance
      .collection('peliculas');

  PantallaFirebase({Key? key}) : super(key: key);

  void agregarPelicula(BuildContext context) {
    coleccionPeliculas
        .add({
          'titulo': 'Batman: El Caballero de la Noche',
          'anio': 2008,
          'metodo': 'Manual', // Para saber que funcionó nuestro método manual
          'creado_en': DateTime.now(),
        })
        .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Guardado exitoso!'),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integración Manual')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_fire_department,
              size: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 20),
            const Text(
              'Integración vía google-services.json',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => agregarPelicula(context),
              icon: const Icon(Icons.save),
              label: const Text('Guardar en Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
