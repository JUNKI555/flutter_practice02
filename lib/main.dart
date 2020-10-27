import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'entity/album.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<List<Album>> futureAlbums;
  Future<Album> futureAlbum;

  void _albumDetails(BuildContext context, int id) {
    futureAlbum = fetchAlbum(id);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Album Details'),
            ),
            body: Center(
              child: FutureBuilder<Album>(
                future: futureAlbum,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.title);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  return const CircularProgressIndicator();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    futureAlbums = fetchAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbums,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final items = snapshot.data;
              return Scrollbar(
                child: RefreshIndicator(
                  child: ListView.separated(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(snapshot.data[index].title),
                            onTap: () {
                              _albumDetails(context, snapshot.data[index].id);
                            },
                          ));
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        color: Colors.blue,
                      );
                    },
                  ),
                  onRefresh: () {
                    return;
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<List<Album>> fetchAlbums() async {
  final response =
      await http.get('https://jsonplaceholder.typicode.com/albums');

  if (response.statusCode == 200) {
    final jsonArray = jsonDecode(response.body) as List<dynamic>;
    return jsonArray.map((dynamic i) {
      return Album.fromJson(i as Map<dynamic, dynamic>);
    }).toList();
  } else {
    throw Exception('Faild to load album.');
  }
}

Future<Album> fetchAlbum(int id) async {
  final response =
      await http.get('https://jsonplaceholder.typicode.com/albums/$id');

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body) as Map);
  } else {
    throw Exception('Faild to load album.');
  }
}
