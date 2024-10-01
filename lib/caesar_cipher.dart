import 'package:flutter/material.dart';

class CaesarCipherScreen extends StatefulWidget {
  @override
  _CaesarCipherScreenState createState() => _CaesarCipherScreenState();
}

class _CaesarCipherScreenState extends State<CaesarCipherScreen> {
  String _inputText = ''; 
  int? _shiftValue; 
  String _encryptedText = ''; 
  String _decryptedText = ''; 
  String _bruteForceResults = ''; 
  String _shiftValueError = '';
  TextEditingController _decryptionController = TextEditingController();

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

  bool _isAlphanumeric(String text) {
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(text);
  }

  void _encryptText() {
    if (_inputText.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return;
    }

    if (!_isAlphanumeric(_inputText)) {
      _showErrorDialog('Input text hanya boleh berisi huruf dan angka (alphanumeric)');
      return;
    }

    if (_shiftValue == null) {
      _showErrorDialog('Kunci harus diisi');
      return; 
    } else if (_shiftValueError.isNotEmpty) {
      _showErrorDialog(_shiftValueError); 
      return; 
    }

    setState(() {
      _encryptedText = _caesarCipher(_inputText, _shiftValue!);
      _decryptionController.text = _encryptedText;
      _bruteForceResults = ''; 
      _shiftValueError = ''; 
    });
  }

  void _decryptText() {
    if (_shiftValue == null) {
      _showErrorDialog('Kunci tidak boleh kosong');
      return;
    }

    if (_decryptionController.text.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return; 
    }

    if (!_isAlphanumeric(_decryptionController.text)) {
      _showErrorDialog('Input text hanya boleh berisi huruf dan angka (alphanumeric)');
      return;
    }

    setState(() {
      _decryptedText = _caesarCipher(_decryptionController.text, -(_shiftValue!));
      _encryptedText = '';
      _bruteForceResults = '';
    });
  }

  void _bruteForce() {
    if (_decryptionController.text.isEmpty) {
      _showErrorDialog('Teks untuk brute force harus ada');
      return;
    }

    setState(() {
      _bruteForceResults = '';
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

        if (char.contains(RegExp(r'[A-Za-z]'))) {
          var base = char.toLowerCase() == char ? 'a'.codeUnitAt(0) : 'A'.codeUnitAt(0);
          return (rune - base + shift) % 26 + base;
        }
        else if (char.contains(RegExp(r'[0-9]'))) {
          var base = '0'.codeUnitAt(0);
          return (rune - base + shift) % 10 + base;
        }
        return rune;
      }),
    );
  }

  @override
  void dispose() {
    _decryptionController.dispose();
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
            backgroundColor: Colors.transparent,
            elevation: 0, 
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
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
                                    _shiftValue = null; 
                                    _shiftValueError = ''; 
                                  } else {
                                    if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                                      _shiftValue = int.tryParse(value); 
                                      _shiftValueError = ''; 
                                    } else {
                                      _shiftValueError = 'Kunci harus berupa angka'; 
                                      _shiftValue = null; 
                                    }
                                  }
                                  setState(() {}); 
                                },
                              ),
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
                                        _showErrorDialog(_shiftValueError);
                                      } else {
                                        _encryptText();
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
                                },
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  CryptoActionCard(
                                    title: 'Decrypt',
                                    onPressed: () {
                                      _decryptText();
                                    },
                                  ),
                                  CryptoActionCard(
                                    title: 'Brute Force',
                                    onPressed: _bruteForce, 
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text('Decrypted Text: $_decryptedText', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
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
