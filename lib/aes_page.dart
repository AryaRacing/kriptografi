import 'package:cryptolicious/aesDecryptPage.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:typed_data';

class AESPage extends StatefulWidget {
  @override
  _AESPageState createState() => _AESPageState();
}

class _AESPageState extends State<AESPage> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController(text: "aesEncryptionKey");
  final _ivController = TextEditingController(text: "encryptionIntVec");
  String? _encryptedText;
  String? _decryptedText;
  String _mode = 'CBC'; // CBC or ECB mode
  int _keySize = 128; // Key size can be 128, 192, 256
  String _outputFormat = 'Base64'; // Base64 or Hex

  @override
  void initState() {
    super.initState();
    // Add listeners to update character counts
    _keyController.addListener(() {
      setState(() {}); // Rebuild widget when key text changes
    });
    _ivController.addListener(() {
      setState(() {}); // Rebuild widget when IV text changes
    });
  }

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
        return 16; // 16 characters for 128 bits
      case 192:
        return 24; // 24 characters for 192 bits
      case 256:
        return 32; // 32 characters for 256 bits
      default:
        return 16; // Default to 16 characters
    }
  }

  void _encryptText() {
    if (_textController.text.isEmpty || _keyController.text.isEmpty) {
      _showErrorDialog('Input text and secret key cannot be empty.');
      return;
    }

    // Secret key length check
    int expectedKeyLength = _keySize ~/ 8; // 128 bits -> 16 chars, 192 bits -> 24 chars, 256 bits -> 32 chars
    if (_keyController.text.length != expectedKeyLength) {
      _showErrorDialog('Secret key must be exactly $expectedKeyLength characters long.');
      return;
    }

    // IV length check (for CBC mode)
    if (_mode == 'CBC' && _ivController.text.length != 16) {
      _showErrorDialog('IV (Initialization Vector) must be exactly 16 characters long.');
      return;
    }

    final key = encrypt.Key.fromUtf8(_keyController.text.padRight(expectedKeyLength, '0'));
    final iv = _mode == 'CBC' ? encrypt.IV.fromUtf8(_ivController.text) : encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: _mode == 'CBC' ? encrypt.AESMode.cbc : encrypt.AESMode.ecb));

    final encrypted = encrypter.encrypt(_textController.text, iv: iv);
    
    setState(() {
      _encryptedText = _outputFormat == 'Base64' ? encrypted.base64 : encrypted.bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    });
  }

  void _decryptText() {
    if (_encryptedText == null || _keyController.text.isEmpty) {
      _showErrorDialog('Encrypted text and secret key cannot be empty.');
      return;
    }

    // Secret key length check
    int expectedKeyLength = _keySize ~/ 8;
    if (_keyController.text.length != expectedKeyLength) {
      _showErrorDialog('Secret key must be exactly $expectedKeyLength characters long.');
      return;
    }

    // IV length check (for CBC mode)
    if (_mode == 'CBC' && _ivController.text.length != 16) {
      _showErrorDialog('IV (Initialization Vector) must be exactly 16 characters long.');
      return;
    }

    final key = encrypt.Key.fromUtf8(_keyController.text.padRight(expectedKeyLength, '0'));
    final iv = _mode == 'CBC' ? encrypt.IV.fromUtf8(_ivController.text) : encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: _mode == 'CBC' ? encrypt.AESMode.cbc : encrypt.AESMode.ecb));

    try {
      final decrypted = _outputFormat == 'Base64'
          ? encrypter.decrypt64(_encryptedText!, iv: iv)
          : encrypter.decrypt(encrypt.Encrypted(_hexToBytes(_encryptedText!)), iv: iv);

      setState(() {
        _decryptedText = decrypted;
      });
    } catch (e) {
      setState(() {
        _decryptedText = 'Decryption failed';
      });
    }
  }

  // Method to show error dialog
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
        title: Text('AES Encryption', style: TextStyle(fontFamily: 'Raleway')),
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
                    controller: _textController,
                    decoration: InputDecoration(labelText: 'Enter text to encrypt', border: OutlineInputBorder()),
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
                    decoration: InputDecoration(labelText: 'Secret Key (optional)', border: OutlineInputBorder()),
                  ),
                  Text('Character count: ${_keyController.text.length}/${_getExpectedLength(_keySize)}'),
                  if (_mode == 'CBC') ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: _ivController,
                      decoration: InputDecoration(labelText: 'Initialization Vector (IV)', border: OutlineInputBorder()),
                    ),
                    Text('Character count: ${_ivController.text.length}/16'), // Always 16 for IV
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
                    decoration: InputDecoration(labelText: 'Output Format', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: Colors.green.shade400,
                    ),
                    onPressed: _encryptText,
                    child: Text('Encrypt', style: TextStyle(fontSize: 16, fontFamily: 'Raleway')),
                  ),
                  SizedBox(height: 16),
                  if (_encryptedText != null)
                    SelectableText(
                      'Encrypted Text: $_encryptedText',
                      style: TextStyle(fontSize: 16),
                    ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: Colors.blue.shade400,
                    ),
                    onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AESDecryptPage(),
                    ),
                  );
                },
                    child: Text('Decrypt', style: TextStyle(fontSize: 16, fontFamily: 'Raleway')),
                  ),
                  SizedBox(height: 16),
                  if (_decryptedText != null)
                    SelectableText(
                      'Decrypted Text: $_decryptedText',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
