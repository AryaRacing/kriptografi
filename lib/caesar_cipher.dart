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
  TextEditingController _decryptionController = TextEditingController(); // Controller untuk input dekripsi

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

  // Tambahkan metode untuk memeriksa input alfanumerik
  bool _isAlphanumeric(String text) {
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(text); // Memeriksa apakah hanya huruf dan angka, termasuk spasi
  }

  void _encryptText() {
    if (_inputText.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return; // Hentikan eksekusi fungsi jika input kosong
    }

    // Validasi apakah input hanya berisi huruf dan angka
    if (!_isAlphanumeric(_inputText)) {
      _showErrorDialog('Input text hanya boleh berisi huruf dan angka (alphanumeric)');
      return; // Hentikan eksekusi fungsi jika input tidak valid
    }

    if (_shiftValue == null) {
      _showErrorDialog('Kunci harus diisi');
      return; // Hentikan eksekusi fungsi jika kunci tidak diisi
    } else if (_shiftValueError.isNotEmpty) {
      _showErrorDialog(_shiftValueError); // Show error if shift value is invalid
      return; // Hentikan eksekusi fungsi jika ada kesalahan pada shift value
    }

    setState(() {
      _encryptedText = _caesarCipher(_inputText, _shiftValue!);
      _decryptionController.text = _encryptedText; // Set input text for decryption card to encrypted text
      _bruteForceResults = ''; // Reset brute force results after encryption
      _shiftValueError = ''; // Clear error message after encryption
    });
  }

  void _decryptText() {
    // Cek apakah nilai shift kosong
    if (_shiftValue == null) {
      _showErrorDialog('Kunci tidak boleh kosong');
      return; // Hentikan eksekusi fungsi jika shift kosong
    }

    // Cek apakah input text kosong
    if (_decryptionController.text.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return; // Hentikan eksekusi fungsi jika input kosong
    }

    // Validasi apakah input hanya berisi huruf dan angka
    if (!_isAlphanumeric(_decryptionController.text)) {
      _showErrorDialog('Input text hanya boleh berisi huruf dan angka (alphanumeric)');
      return; // Hentikan eksekusi fungsi jika input tidak valid
    }

    setState(() {
      _decryptedText = _caesarCipher(_decryptionController.text, -(_shiftValue!)); // Menggunakan shift yang ada
      _encryptedText = ''; // Reset encrypted text after decryption
      _bruteForceResults = ''; // Reset brute force results after decryption
    });
  }

  void _bruteForce() {
    // Gunakan input dari kartu dekripsi untuk brute force
    if (_decryptionController.text.isEmpty) {
      _showErrorDialog('Teks untuk brute force harus ada');
      return;
    }

    setState(() {
      _bruteForceResults = ''; // Kosongkan sebelum brute force
      List<String> results = [];
      for (int i = 0; i < 26; i++) {
        results.add('Shift $i: ${_caesarCipher(_decryptionController.text, -i)}');
      }
      _bruteForceResults = results.join('\n\n');
    });
  }

  String _caesarCipher(String text, int shift) {
    return String.fromCharCodes(
      text.runes.map((int rune) {
        var char = String.fromCharCode(rune);

        // Cek apakah karakter adalah huruf
        if (char.contains(RegExp(r'[A-Za-z]'))) {
          var base = char.toLowerCase() == char ? 'a'.codeUnitAt(0) : 'A'.codeUnitAt(0);
          return (rune - base + shift) % 26 + base;
        }
        // Cek apakah karakter adalah angka
        else if (char.contains(RegExp(r'[0-9]'))) {
          var base = '0'.codeUnitAt(0);
          return (rune - base + shift) % 10 + base;
        }
        // Jika bukan huruf atau angka, kembalikan karakter asli (termasuk spasi)
        return rune;
      }),
    );
  }

  @override
  void dispose() {
    _decryptionController.dispose(); // Hapus controller saat widget dihapus
    super.dispose();
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
                              Text('Encrypted Text: $_encryptedText', style: TextStyle(fontSize: 16)),
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
                                controller: _decryptionController,
                                decoration: InputDecoration(labelText: 'Input Encrypted Text'),
                                onChanged: (value) {
                                  // Hapus setState disini untuk menghindari update yang tidak perlu
                                },
                              ),
                              // Button for decryption
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CryptoActionCard(
                                    title: 'Decrypt',
                                    onPressed: () {
                                      _decryptText(); // Call decrypt function
                                    },
                                  ),
                                  CryptoActionCard(
                                    title: 'Brute Force',
                                    onPressed: _bruteForce, // Call brute force function
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Display hasil dekripsi
                              Text('Decrypted Text: $_decryptedText', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      // Brute Force Results Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Brute Force Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(_bruteForceResults, style: TextStyle(fontSize: 16)),
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
      child: Text(title),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        backgroundColor: Colors.greenAccent
      ),
    );
  }
}
