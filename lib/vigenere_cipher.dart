import 'package:flutter/material.dart';

class VigenereCipherScreen extends StatefulWidget {
  @override
  _VigenereCipherScreenState createState() => _VigenereCipherScreenState();
}

class _VigenereCipherScreenState extends State<VigenereCipherScreen> {
  String _inputText = '';
  String _key = '';
  String _encryptedText = '';
  String _decryptedText = '';
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

    if (_key.isEmpty) {
      _showErrorDialog('Kunci tidak boleh kosong');
      return;
    }

    if (_inputText.contains(RegExp(r'[^A-Za-z\s]'))) {
      _showErrorDialog('Input text tidak boleh mengandung angka atau karakter non-alfabet');
      return;
    }

    if (!_key.contains(RegExp(r'^[A-Za-z\s]+$'))) {
      _showErrorDialog('Kunci harus berupa huruf alfabet saja');
      return;
    }

    setState(() {
      _encryptedText = _vigenereCipher(_inputText, _key, encrypt: true);
    });
  }

  void _decryptText() {
    if (_inputText.isEmpty) {
      _showErrorDialog('Input text tidak boleh kosong');
      return;
    }

    if (_key.isEmpty) {
      _showErrorDialog('Kunci tidak boleh kosong');
      return;
    }

    if (_inputText.contains(RegExp(r'[^A-Za-z\s]'))) {
      _showErrorDialog('Input text tidak boleh mengandung angka atau karakter non-alfabet');
      return;
    }

    if (!_key.contains(RegExp(r'^[A-Za-z\s]+$'))) {
      _showErrorDialog('Kunci harus berupa huruf alfabet saja');
      return;
    }

    setState(() {
      _decryptedText = _vigenereCipher(_inputText, _key, encrypt: false);
    });
  }

  String _vigenereCipher(String text, String key, {required bool encrypt}) {
    String result = '';
    int keyIndex = 0;
    key = key.toLowerCase();

    for (int i = 0; i < text.length; i++) {
      var char = text[i];

      if (char.contains(RegExp(r'[A-Za-z]'))) {
        var shift = key[keyIndex % key.length].codeUnitAt(0) - 'a'.codeUnitAt(0);
        var base = char.toLowerCase() == char ? 'a'.codeUnitAt(0) : 'A'.codeUnitAt(0);

        if (encrypt) {
          result += String.fromCharCode((char.codeUnitAt(0) - base + shift) % 26 + base);
        } else {
          result += String.fromCharCode((char.codeUnitAt(0) - base - shift + 26) % 26 + base);
        }

        keyIndex++;
      } else {
        result += char;
      }
    }

    return result;
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
            title: Text('Vigenère Cipher', style: TextStyle(color: Colors.white)),
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
        child: Container(
          height: double.infinity,
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
                            decoration: InputDecoration(labelText: 'Key'),
                            onChanged: (value) {
                              setState(() {
                                _key = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          CryptoActionCard(
                            title: 'Encrypt',
                            onPressed: _encryptText,
                          ),
                          SizedBox(height: 20),
                          Text(
                            _encryptedText,
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
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
                            decoration: InputDecoration(labelText: 'Input Encrypted Text'),
                            onChanged: (value) {
                              setState(() {
                                _inputText = value;
                              });
                            },
                          ),
                          TextField(
                            decoration: InputDecoration(labelText: 'Key'),
                            onChanged: (value) {
                              setState(() {
                                _key = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          CryptoActionCard(
                            title: 'Decrypt',
                            onPressed: _decryptText,
                          ),
                          SizedBox(height: 20),
                          Text(
                            _decryptedText,
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
