import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon_model.dart';

Future<Pokemon> fetchPokemon(String pokemonName) async {
  final Uri url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);

    return Pokemon.fromJson(json);
  } else {
    throw Exception(
      'Falló la carga del Pokémon. Código: ${response.statusCode}',
    );
  }
}
