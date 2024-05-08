import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List Universitas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => UniversityCubit(), // Membuat BlocProvider untuk UniversityCubit
        child: UniversityListScreen(), // Menampilkan UniversityListScreen sebagai home
      ),
    );
  }
}

class UniversityCubit extends Cubit<UniversityState> {
  UniversityCubit() : super(UniversityState.initial());

  Future<void> fetchUniversities(String country) async {
    try {
      final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country'), // Mengambil universitas berdasarkan negara
      );
      if (response.statusCode == 200) {
        final List<dynamic> universities = json.decode(response.body);
        emit(UniversityState.success(universities)); // Mengirim state sukses ke BlocBuilder
      } else {
        emit(UniversityState.error("Failed to load universities")); // Mengirim state error ke BlocBuilder
      }
    } catch (e) {
      emit(UniversityState.error("Failed to load universities")); // Mengirim state error ke BlocBuilder
    }
  }

  void updateCountry(String country) {
    emit(state.copyWith(selectedCountry: country)); // Memperbarui negara yang dipilih
    fetchUniversities(country); // Memuat universitas berdasarkan negara yang dipilih
  }
}

class UniversityState {
  final String selectedCountry;
  final List<dynamic> universities;
  final String? error;

  UniversityState({
    required this.selectedCountry,
    required this.universities,
    this.error,
  });

  factory UniversityState.initial() {
    return UniversityState(
      selectedCountry: 'Indonesia', // Negara yang dipilih secara default
      universities: [],
      error: null,
    );
  }

  factory UniversityState.success(List<dynamic> universities) {
    return UniversityState(
      selectedCountry: universities.isNotEmpty ? universities[0]['country'] : '', // Negara pertama dari daftar universitas
      universities: universities, // Daftar universitas yang dimuat
      error: null,
    );
  }

  factory UniversityState.error(String error) {
    return UniversityState(
      selectedCountry: '', // Tidak ada negara yang dipilih saat terjadi error
      universities: [],
      error: error,
    );
  }

  UniversityState copyWith({
    String? selectedCountry,
    List<dynamic>? universities,
    String? error,
  }) {
    return UniversityState(
      selectedCountry: selectedCountry ?? this.selectedCountry,
      universities: universities ?? this.universities,
      error: error ?? this.error,
    );
  }
}

class UniversityListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<UniversityCubit, UniversityState>(
          builder: (context, state) {
            return Text('Universitas Di ${state.selectedCountry}'); // Menampilkan judul dengan negara yang dipilih
          },
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityCubit, UniversityState>(
            builder: (context, state) {
              return DropdownButton<String>(
                value: state.selectedCountry,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<UniversityCubit>().updateCountry(newValue); // Memperbarui negara yang dipilih dan memuat universitas
                  }
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
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<UniversityCubit, UniversityState>(
              builder: (context, state) {
                if (state.error != null) {
                  return Center(
                    child: Text(state.error!), // Menampilkan pesan error jika terjadi kesalahan
                  );
                }
                return ListView.builder(
                  itemCount: state.universities.length, // Jumlah item dalam ListView sesuai dengan universitas yang dimuat
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      color: Colors.blue,
                      child: ListTile(
                        title: Text(
                          state.universities[index]['name'], // Menampilkan nama universitas
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          state.universities[index]['web_pages'].isEmpty
                              ? 'No website available' // Menampilkan pesan jika tidak ada halaman web tersedia
                              : state.universities[index]['web_pages'][0], // Menampilkan halaman web pertama jika ada
                          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
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
