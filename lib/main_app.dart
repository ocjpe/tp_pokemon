import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/pokemon.dart';

import 'package:http/http.dart' as http;


class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master/Details Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PokemonListScreen(),
    );
  }
}

class PokemonListScreen extends StatefulWidget {

  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  List<Pokemon> pokemons = [];

  @override
  void initState() {
    super.initState();
    fetchPokemons();
  }

  Future<void> fetchPokemons() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> results = jsonData['results'];

      List<Pokemon> fetchedPokemons = [];
      for (var result in results) {
        final pokemonResponse = await http.get(Uri.parse(result['url']));
        if (pokemonResponse.statusCode == 200) {
          final pokemonData = jsonDecode(pokemonResponse.body);
          final List<dynamic>? typesData = pokemonData['types'];
          List<String> types = [];
          if (typesData != null) {
            for (var typeEntry in typesData) {
              types.add(typeEntry['type']['name']);
            }
          }
          fetchedPokemons.add(Pokemon(
            id: pokemonData['id'],
            name: result['name'],
            imageUrl: 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemonData['id']}.png',
            types: types,
            height: pokemonData['height'],
            weight: pokemonData['weight'],
          ));
        } else {
          throw Exception('Failed to load Pokemon details');
        }
      }

      setState(() {
        pokemons = fetchedPokemons;
      });
    } else {
      throw Exception('Echec du téléchargement');
    }
  }

  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon List'),
      ),
      body: ListView.builder(
        itemCount: pokemons.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.red,
            child: ListTile(
              leading: Image.network(pokemons[index].imageUrl),
              title: Text('#${pokemons[index].id}. ${capitalize(pokemons[index].name)}'),
              textColor: Colors.white,
              subtitle: Text(pokemons[index].types.join(', ')),
              subtitleTextStyle: TextStyle(fontStyle: FontStyle.italic),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PokemonDetailScreen(pokemon: pokemons[index])),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  PokemonDetailScreen({required this.pokemon});

  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon numéro ${pokemon.id} : ${capitalize(pokemon.name)}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(pokemon.imageUrl),
            SizedBox(height: 50),
            Text(
              'Identifiant : ${pokemon.id}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Nom : ${capitalize(pokemon.name)}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Type : ${pokemon.types}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Taille : ${pokemon.height} cm',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Poids : ${pokemon.weight} kg',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
