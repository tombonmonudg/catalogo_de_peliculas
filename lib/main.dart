import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

// --- PUNTO DE ENTRADA ---

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); // Usa la config manual (google-services.json)

  runApp(const MiAppPeliculas());
}

class MiAppPeliculas extends StatelessWidget {
  const MiAppPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Películas',

      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),

      debugShowCheckedModeBanner: false,

      // Usamos un StreamBuilder para escuchar si el usuario está logueado o no
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const PantallaCatalogo(); // Si hay usuario, vamos al catálogo
          }

          return const PantallaLogin(); // Si no, vamos al Login
        },
      ),
    );
  }
}

// --- 1. PANTALLA DE LOGIN / REGISTRO ---

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool isLogin = true; // Para alternar entre Iniciar Sesión y Registrarse

  Future<void> submit() async {
    try {
      if (isLogin) {
        // Iniciar Sesión

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),

          password: _passwordController.text.trim(),
        );
      } else {
        // Registrarse

        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),

          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.movie_creation_outlined,

              size: 100,

              color: Colors.indigo,
            ),

            const SizedBox(height: 20),

            Text(
              isLogin ? 'Bienvenido al Catálogo' : 'Crear Cuenta Nueva',

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _emailController,

              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _passwordController,

              decoration: const InputDecoration(
                labelText: 'Contraseña',

                border: OutlineInputBorder(),
              ),

              obscureText: true,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,

              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),

              child: Text(isLogin ? 'Ingresar' : 'Registrarse'),
            ),

            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),

              child: Text(
                isLogin
                    ? '¿No tienes cuenta? Regístrate'
                    : '¿Ya tienes cuenta? Ingresa',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. PANTALLA DE CATÁLOGO (HOME) ---

class PantallaCatalogo extends StatelessWidget {
  const PantallaCatalogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Películas'),

        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),

            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),

      // Menú lateral para ir a Administración
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),

              child: Text(
                'Menú',

                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.movie),

              title: const Text('Catálogo'),

              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.settings),

              title: const Text('Administración (Agregar/Borrar)'),

              onTap: () {
                Navigator.pop(context); // Cerrar drawer

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) => const PantallaAdministracion(),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('peliculas').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay películas aún. Ve a Administración.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final id = docs[index].id;

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading:
                      data['imagen'] != null &&
                          data['imagen'].toString().isNotEmpty
                      ? Image.network(
                          data['imagen'],

                          width: 50,

                          fit: BoxFit.cover,

                          errorBuilder: (c, e, s) => const Icon(Icons.error),
                        )
                      : const Icon(Icons.movie),

                  title: Text(data['titulo'] ?? 'Sin título'),

                  subtitle: Text(data['anio']?.toString() ?? 'Sin año'),

                  onTap: () {
                    // Ir a Detalles

                    Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => PantallaDetalle(data: data, id: id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// --- 3. PANTALLA DE DETALLE ---

class PantallaDetalle extends StatelessWidget {
  final Map<String, dynamic> data;

  final String id;

  const PantallaDetalle({super.key, required this.data, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data['titulo'] ?? 'Detalle')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            if (data['imagen'] != null && data['imagen'].toString().isNotEmpty)
              Center(
                child: Image.network(
                  data['imagen'],

                  height: 300,

                  fit: BoxFit.cover,

                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              'Título: ${data['titulo']}',

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text('Año: ${data['anio']}', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Text(
              'Director: ${data['director'] ?? 'Desconocido'}',

              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              'Género: ${data['genero'] ?? 'No especificado'}',

              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            const Text(
              'Sinopsis:',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              data['sinopsis'] ?? 'Sin sinopsis disponible.',

              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. PANTALLA DE ADMINISTRACIÓN (Alta y Baja) ---

class PantallaAdministracion extends StatefulWidget {
  const PantallaAdministracion({super.key});

  @override
  State<PantallaAdministracion> createState() => _PantallaAdministracionState();
}

class _PantallaAdministracionState extends State<PantallaAdministracion> {
  final _tituloCtrl = TextEditingController();

  final _anioCtrl = TextEditingController();

  final _directorCtrl = TextEditingController();

  final _generoCtrl = TextEditingController();

  final _sinopsisCtrl = TextEditingController();

  final _imagenCtrl = TextEditingController();

  // Función para guardar en Firebase

  Future<void> _guardarPelicula() async {
    if (_tituloCtrl.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('peliculas').add({
      'titulo': _tituloCtrl.text,

      'anio': int.tryParse(_anioCtrl.text) ?? 2024,

      'director': _directorCtrl.text,

      'genero': _generoCtrl.text,

      'sinopsis': _sinopsisCtrl.text,

      'imagen': _imagenCtrl.text, // Aquí pegas una URL de internet

      'creado_en': DateTime.now(),
    });

    // Limpiar campos y cerrar teclado

    _tituloCtrl.clear();

    _anioCtrl.clear();

    _directorCtrl.clear();

    _generoCtrl.clear();

    _sinopsisCtrl.clear();

    _imagenCtrl.clear();

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Película Agregada')));
  }

  // Función para borrar de Firebase

  Future<void> _borrarPelicula(String id) async {
    await FirebaseFirestore.instance.collection('peliculas').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrar Películas')),

      body: Column(
        children: [
          // Formulario de Alta
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  const Text(
                    'Agregar Nueva Película',

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  TextField(
                    controller: _tituloCtrl,

                    decoration: const InputDecoration(labelText: 'Título'),
                  ),

                  TextField(
                    controller: _anioCtrl,

                    decoration: const InputDecoration(labelText: 'Año'),

                    keyboardType: TextInputType.number,
                  ),

                  TextField(
                    controller: _directorCtrl,

                    decoration: const InputDecoration(labelText: 'Director'),
                  ),

                  TextField(
                    controller: _generoCtrl,

                    decoration: const InputDecoration(labelText: 'Género'),
                  ),

                  TextField(
                    controller: _sinopsisCtrl,

                    decoration: const InputDecoration(labelText: 'Sinopsis'),
                  ),

                  TextField(
                    controller: _imagenCtrl,

                    decoration: const InputDecoration(
                      labelText: 'URL de Imagen (http...)',
                    ),
                  ),

                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: _guardarPelicula,

                    icon: const Icon(Icons.save),

                    label: const Text('Guardar Película'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(thickness: 2),

          // Lista para dar de Baja
          const Padding(
            padding: EdgeInsets.all(8.0),

            child: Text(
              'Listado (Desliza para borrar)',

              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('peliculas')
                  .snapshots(),

              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,

                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];

                    final data = doc.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(doc.id),

                      background: Container(
                        color: Colors.red,

                        alignment: Alignment.centerRight,

                        padding: const EdgeInsets.only(right: 20),

                        child: const Icon(Icons.delete, color: Colors.white),
                      ),

                      onDismissed: (direction) => _borrarPelicula(doc.id),

                      child: ListTile(
                        title: Text(data['titulo']),

                        subtitle: Text(data['director'] ?? ''),

                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () => _borrarPelicula(doc.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
