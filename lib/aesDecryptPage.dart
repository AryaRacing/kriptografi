import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';

class AESDecryptPage extends StatefulWidget {
  @override
  _AESDecryptPageState createState() => _AESDecryptPageState();
}

class _AESDecryptPageState extends State<AESDecryptPage> {
  final _encryptedTextController = TextEditingController();
  final _keyController = TextEditingController(text: "aesEncryptionKey");
  final _ivController = TextEditingController(text: "encryptionIntVec");
  String? _decryptedText;
  String _mode = 'CBC';
  int _keySize = 128; 
  String _outputFormat = 'Base64';

  Uint8List _hexToBytes(String hex) {
    hex = hex.replaceAll(' ', '');
    List<int> result = [];
    for (int i = 0; i < hex.length; i += 2) {
      String byte = hex.substring(i, i + 2);
      result.add(int.parse(byte, radix: 16));
    }
    return Uint8List.fromList(result);
  }

  int _getExpectedLength(int keySize) {
    switch (keySize) {
      case 128:
        return 16;
      case 192:
        return 24;
      case 256:
        return 32; 
      default:
        return 16; 
    }
  }

  void _decryptText() {
    if (_encryptedTextController.text.isEmpty || _keyController.text.isEmpty) {
      _showErrorDialog('Encrypted text and secret key cannot be empty.');
      return;
    }

    int expectedKeyLength = _keySize ~/ 8;
    if (_keyController.text.length != expectedKeyLength) {
      _showErrorDialog('Secret key must be exactly $expectedKeyLength characters long.');
      return;
    }

    if (_mode == 'CBC' && _ivController.text.length != 16) {
      _showErrorDialog('IV (Initialization Vector) must be exactly 16 characters long.');
      return;
    }

    final key = encrypt.Key.fromUtf8(_keyController.text.padRight(expectedKeyLength, '0'));
    final iv = _mode == 'CBC' ? encrypt.IV.fromUtf8(_ivController.text) : encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: _mode == 'CBC' ? encrypt.AESMode.cbc : encrypt.AESMode.ecb));

    try {
      final decrypted = _outputFormat == 'Base64'
          ? encrypter.decrypt64(_encryptedTextController.text, iv: iv)
          : encrypter.decrypt(encrypt.Encrypted(_hexToBytes(_encryptedTextController.text)), iv: iv);

      setState(() {
        _decryptedText = decrypted;
      });
    } catch (e) {
      setState(() {
        _decryptedText = 'Decryption failed';
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AES Decryption', style: TextStyle(fontFamily: 'Raleway')),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _encryptedTextController,
                    decoration: InputDecoration(labelText: 'Enter encrypted text', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _mode,
                    items: ['CBC', 'ECB'].map((mode) {
                      return DropdownMenuItem(value: mode, child: Text(mode));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _mode = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Mode', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _keySize,
                    items: [128, 192, 256].map((size) {
                      return DropdownMenuItem(value: size, child: Text(size.toString()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _keySize = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Key Size (bits)', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    decoration: InputDecoration(labelText: 'Secret Key', border: OutlineInputBorder()),
                  ),
                  Text('Character count: ${_keyController.text.length}/${_getExpectedLength(_keySize)}'),
                  if (_mode == 'CBC') ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: _ivController,
                      decoration: InputDecoration(labelText: 'Initialization Vector (IV)', border: OutlineInputBorder()),
                    ),
                    Text('Character count: ${_ivController.text.length}/16'),
                  ],
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _outputFormat,
                    items: ['Base64', 'Hex'].map((format) {
                      return DropdownMenuItem(value: format, child: Text(format));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _outputFormat = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Input Format', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _decryptText,
                    child: Text('Decrypt', style: TextStyle(fontSize: 18, fontFamily: 'Raleway')),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (_decryptedText != null)
              SelectableText('Decrypted Text: $_decryptedText', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
