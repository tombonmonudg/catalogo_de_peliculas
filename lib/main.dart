import 'package:flutter/material.dart';
import 'api_service.dart';
import 'pokemon_model.dart';

void main() {
  runApp(const MiAppPeliculas());
}

class MiAppPeliculas extends StatelessWidget {
  const MiAppPeliculas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Películas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: PantallaInicio(),
    );
  }
}

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late Future<Pokemon> futurePokemon;

  @override
  void initState() {
    super.initState();

    futurePokemon = fetchPokemon('pikachu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/fondo_peliculas.jpg', fit: BoxFit.cover),

          Container(color: Colors.black.withOpacity(0.5)),

          Center(
            child: FutureBuilder<Pokemon>(
              future: futurePokemon,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(color: Colors.white);
                } else if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  );
                } else if (snapshot.hasData) {
                  final pokemon = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¡Pokémon Obtenido!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),

                      Image.network(
                        pokemon.imageUrl,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 20),

                      Text(
                        pokemon.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }

                return Text('Iniciando...');
              },
            ),
          ),
        ],
      ),
    );
  }
}
