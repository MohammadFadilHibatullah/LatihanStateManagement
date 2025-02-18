import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

class University {
  String name;
  String website;

  University({required this.name, required this.website});
}

class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]);

  void fetchUniversities(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<University> universities = [];

      for (var item in data) {
        universities.add(
          University(
            name: item['name'],
            website: item['web_pages'][0],
          ),
        );
      }

      emit(universities);
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universitas App',
      home: BlocProvider(
        create: (context) => UniversityCubit(),
        child: UniversitiesPage(),
      ),
    );
  }
}

class UniversitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Universitas di Negara ASEAN',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF283593),
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityCubit, List<University>>(
            builder: (context, universityList) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Negara ASEAN',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  items: <String>[
                    'Indonesia',
                    'Singapura',
                    'Malaysia',
                    'Thailand',
                    'Vietnam',
                    'Filipina',
                    'Myanmar',
                    'Kamboja',
                    'Laos',
                    'Brunei Darussalam'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      context
                          .read<UniversityCubit>()
                          .fetchUniversities(newValue);
                    }
                  },
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<UniversityCubit, List<University>>(
              builder: (context, universityList) {
                if (universityList.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: universityList.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(universityList[index].name),
                        subtitle: Text(universityList[index].website),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
