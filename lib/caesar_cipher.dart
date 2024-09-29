import 'package:flutter/material.dart';

class CaesarCipherScreen extends StatefulWidget {
  @override
  _CaesarCipherScreenState createState() => _CaesarCipherScreenState();
}

class _CaesarCipherScreenState extends State<CaesarCipherScreen> {
  String _inputText = ''; // Input teks asli atau terenkripsi
  int? _shiftValue; // Nilai pergeseran (shift)
  String _encryptedText = ''; // Variable hasil enkripsi
  String _decryptedText = ''; // Variable hasil dekripsi
  String _bruteForceResults = ''; // Variable hasil brute force
  String _shiftValueError = ''; // Variabel untuk menyimpan pesan kesalahan

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _encryptText() {
    if (_inputText.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return;
    }

    if (_shiftValue == null) {
      _showErrorDialog('Kunci harus diisi');
      return;
    } else if (_shiftValueError.isNotEmpty) {
      _showErrorDialog(_shiftValueError); // Show error if shift value is invalid
      return;
    }

    setState(() {
      _encryptedText = _caesarCipher(_inputText, _shiftValue!);
      _shiftValueError = ''; // Clear error message after encryption
    });
  }

  void _decryptText() {
    if (_inputText.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return;
    }

    if (_shiftValue == null) {
      _showErrorDialog('Kunci harus diisi');
      return;
    } else if (_shiftValueError.isNotEmpty) {
      _showErrorDialog(_shiftValueError); // Show error if shift value is invalid
      return;
    }

    setState(() {
      _decryptedText = _caesarCipher(_inputText, -_shiftValue!);
    });
  }

  void _bruteForce() {
    setState(() {
      _bruteForceResults = ''; // Kosongkan sebelum brute force
      List<String> results = [];
      for (int i = 0; i < 26; i++) {
        results.add('Shift $i: ${_caesarCipher(_encryptedText, -i)}');
      }
      _bruteForceResults = results.join('\n');
    });
  }

  String _caesarCipher(String text, int shift) {
    return String.fromCharCodes(
      text.runes.map((int rune) {
        var char = String.fromCharCode(rune);
        if (char.contains(RegExp(r'[A-Za-z]'))) {
          var base = char.toLowerCase() == char ? 'a'.codeUnitAt(0) : 'A'.codeUnitAt(0);
          return (rune - base + shift) % 26 + base;
        }
        return rune;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade300, Colors.green.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: Text('Caesar Cipher', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent, // Make background transparent
            elevation: 0, // Remove shadow
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded( // Tambahkan Expanded disini untuk menghindari background putih
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      // Encryption Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Encrypt Text', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              TextField(
                                decoration: InputDecoration(labelText: 'Input Text'),
                                onChanged: (value) {
                                  setState(() {
                                    _inputText = value;
                                  });
                                },
                              ),
                              TextField(
                                decoration: InputDecoration(labelText: 'Shift Value'),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    _shiftValue = null; // Set to null if input is empty
                                    _shiftValueError = ''; // Clear error message
                                  } else {
                                    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      _shiftValue = int.tryParse(value); // Try to parse the input to an integer
                                      _shiftValueError = ''; // Clear error message if valid number
                                    } else {
                                      _shiftValueError = 'Kunci harus berupa angka'; // Set error message
                                      _shiftValue = null; // Ensure shiftValue is null for invalid input
                                    }
                                  }
                                  setState(() {}); // Update the state to reflect changes
                                },
                              ),
                              // Display the error message below the Shift Value input
                              if (_shiftValueError.isNotEmpty)
                                Text(
                                  _shiftValueError,
                                  style: TextStyle(color: Colors.red),
                                ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CryptoActionCard(
                                    title: 'Encrypt',
                                    onPressed: () {
                                      if (_shiftValueError.isNotEmpty) {
                                        _showErrorDialog(_shiftValueError); // Show error if shift value is invalid
                                      } else {
                                        _encryptText(); // Proceed with encryption
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Display hasil enkripsi
                              if (_encryptedText.isNotEmpty)
                                Text(
                                  'Encrypted Text: $_encryptedText',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Decryption Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Decrypt Text', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              TextField(
                                decoration: InputDecoration(labelText: 'Input Encrypted Text'),
                                onChanged: (value) {
                                  setState(() {
                                    _inputText = value;
                                  });
                                },
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CryptoActionCard(
                                    title: 'Decrypt',
                                    onPressed: _decryptText,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Display hasil dekripsi
                              if (_decryptedText.isNotEmpty)
                                Text(
                                  'Decrypted Text: $_decryptedText',
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Brute Force Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Brute Force', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CryptoActionCard(
                                    title: 'Brute Force',
                                    onPressed: _bruteForce,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Tabel Hasil Brute Force
                      if (_bruteForceResults.isNotEmpty)
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Brute Force Results:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                SizedBox(height: 10),
                                Text(
                                  _bruteForceResults,
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CryptoActionCard extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  CryptoActionCard({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white, // Ubah warna teks menjadi putih
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}