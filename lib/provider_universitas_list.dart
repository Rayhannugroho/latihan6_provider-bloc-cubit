import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UniversityModel(),
      child: MyApp(), // Widget root dari aplikasi
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Universitas', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Warna tema untuk aplikasi
      ),
      home: UniversityListScreen(), // Layar awal dari aplikasi
    );
  }
}

class UniversityModel extends ChangeNotifier {
  String _selectedCountry = 'Indonesia'; // Negara yang dipilih secara default
  List<dynamic> _universities = []; // List untuk menyimpan universitas

  String get selectedCountry => _selectedCountry; // Getter untuk negara yang dipilih

  set selectedCountry(String country) {
    _selectedCountry = country; // Setter untuk negara yang dipilih
    notifyListeners();
  }

  List<dynamic> get universities => _universities; // Getter untuk universitas

  set universities(List<dynamic> universities) {
    _universities = universities; // Setter untuk universitas
    notifyListeners();
  }

  Future<void> fetchUniversities(String country) async {
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?country=$country'), // Mengambil universitas berdasarkan negara yang dipilih
    );
    if (response.statusCode == 200) {
      universities = json.decode(response.body); // Mendecode dan mengatur universitas yang diambil
    } else {
      throw Exception('Gagal memuat universitas'); // Melempar pengecualian jika gagal memuat universitas
    }
  }
}

class UniversityListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var universityModel = Provider.of<UniversityModel>(context); // Mendapatkan instans UniversityModel dari Provider

    return Scaffold(
      appBar: AppBar(
        title: Text('Universitas Di ${universityModel.selectedCountry}'), // Mengatur judul app bar dengan negara yang dipilih
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: universityModel.selectedCountry, // Mengatur nilai dropdown dengan negara yang dipilih
            onChanged: (String? newValue) {
              universityModel.selectedCountry = newValue!; // Memperbarui negara yang dipilih saat nilai dropdown berubah
              universityModel.fetchUniversities(newValue); // Mengambil universitas berdasarkan negara yang dipilih yang baru
            },
            items: <String>[
              'Indonesia',
              'Singapore',
              'Malaysia',
              'Thailand',
              'Vietnam',
              'Philippines',
              'Brunei',
              'Myanmar',
              'Cambodia',
              'Laos'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value, // Mengatur nilai item dropdown
                child: Text(value), // Mengatur teks item dropdown
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: universityModel.universities.length, // Mengatur jumlah item dalam list view
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  color: Colors.blue, // Mengatur warna kartu
                  child: ListTile(
                    title: Text(
                      universityModel.universities[index]['name'], // Mengatur nama universitas sebagai judul
                      style: TextStyle(color: Colors.black), // Mengatur warna teks judul
                    ),
                    subtitle: Text(
                      universityModel.universities[index]['web_pages'].isEmpty
                          ? 'Tidak ada situs web' // Menampilkan "Tidak ada situs web" jika halaman web kosong
                          : universityModel.universities[index]['web_pages'][0], // Menampilkan halaman web pertama jika ada
                      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)), // Mengatur warna teks subjudul
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
