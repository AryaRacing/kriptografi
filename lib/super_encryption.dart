import 'package:flutter/material.dart';
import 'dart:convert'; // Required for base64 encoding

class SuperEncryptionPage extends StatefulWidget {
  @override
  _SuperEncryptionPageState createState() => _SuperEncryptionPageState();
}

class _SuperEncryptionPageState extends State<SuperEncryptionPage> {
  // Controllers for inputs
  TextEditingController _caesarPlaintextController = TextEditingController();
  TextEditingController _caesarShiftController = TextEditingController();
  TextEditingController _vigenereKeyController = TextEditingController();
  TextEditingController _aesSecretKeyController = TextEditingController();
  TextEditingController _aesIvController = TextEditingController();

  String _selectedMode = 'CBC'; // Default mode CBC
  String _selectedKeySize = '128'; // Default key size
  String _superEncryptedData = '';
  String _decryptedData = '';

  // Caesar Cipher Methods
  String _caesarEncrypt(String plaintext, int shift) {
    return String.fromCharCodes(
      plaintext.runes.map((char) {
        return char + shift;
      }),
    );
  }

  String _caesarDecrypt(String ciphertext, int shift) {
    return String.fromCharCodes(
      ciphertext.runes.map((char) {
        return char - shift;
      }),
    );
  }

  // Vigenère Cipher Methods
  String _vigenereEncrypt(String plaintext, String key) {
    String result = '';
    for (int i = 0, j = 0; i < plaintext.length; i++) {
      var char = plaintext.codeUnitAt(i);
      var keyChar = key.codeUnitAt(j % key.length);
      result += String.fromCharCode((char + keyChar) % 256);
      j++;
    }
    return result;
  }

  String _vigenereDecrypt(String ciphertext, String key) {
    String result = '';
    for (int i = 0, j = 0; i < ciphertext.length; i++) {
      var char = ciphertext.codeUnitAt(i);
      var keyChar = key.codeUnitAt(j % key.length);
      result += String.fromCharCode(
          (char - keyChar + 256) % 256); // Ensure positive result
      j++;
    }
    return result;
  }

  String _aesEncrypt(String plaintext, String secretKey, String iv) {
    // Add your AES encryption logic here (this is just a placeholder)
    return base64.encode(utf8.encode(plaintext)); // Placeholder encoding
  }

  String _aesDecrypt(String ciphertext) {
    // Add your AES decryption logic here (this is just a placeholder)
    return utf8.decode(base64.decode(ciphertext)); // Placeholder decoding
  }

  String _superEncrypt() {
    // Get user inputs
    String caesarText = _caesarEncrypt(_caesarPlaintextController.text,
        int.parse(_caesarShiftController.text));
    String vigenereText =
        _vigenereEncrypt(caesarText, _vigenereKeyController.text);
    String aesText = _aesEncrypt(
        vigenereText, _aesSecretKeyController.text, _aesIvController.text);

    // Store the final result
    _superEncryptedData = aesText; // Store AES output for later decryption
    return aesText;
  }

  String _superDecrypt() {
    String aesText = _superEncryptedData; // Get encrypted data
    String decryptedAesText = _aesDecrypt(aesText);
    String vigenereText =
        _vigenereDecrypt(decryptedAesText, _vigenereKeyController.text);
    String caesarText =
        _caesarDecrypt(vigenereText, int.parse(_caesarShiftController.text));

    return caesarText; // Return final decrypted plaintext
  }

  // Method to validate key size for AES
  bool _validateKeySize(String secretKey) {
    int requiredLength = 0;
    if (_selectedKeySize == '128') {
      requiredLength = 16;
    } else if (_selectedKeySize == '192') {
      requiredLength = 24;
    } else if (_selectedKeySize == '256') {
      requiredLength = 32;
    }

    return secretKey.length == requiredLength;
  }

  // Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Encryption'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Caesar Cipher Input
            _buildCaesarCipherInput(),
            SizedBox(height: 20),

            // Vigenère Cipher Input
            _buildVigenereCipherInput(),
            SizedBox(height: 20),

            // AES Input
            _buildAesInput(),
            SizedBox(height: 20),

            // Final Encrypt Button for Super Encryption
            ElevatedButton(
              onPressed: () {
                if (_validateKeySize(_aesSecretKeyController.text)) {
                  setState(() {
                    _superEncryptedData = _superEncrypt();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Invalid Secret Key length for the selected key size')));
                }
              },
              child: Text('Encrypt using Super Encryption'),
            ),
            SizedBox(height: 20),

            // Output for Super Encrypted Data
            SelectableText(
              'Super Encrypted Data: $_superEncryptedData',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 20),

            // Button for Decryption
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _decryptedData = _superDecrypt();
                });
              },
              child: Text('Decrypt Super Encrypted Data'),
            ),
            SizedBox(height: 20),

            // Output for Decrypted Data
            SelectableText(
              'Decrypted Data: $_decryptedData',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  // Caesar Cipher Input Widget
  Widget _buildCaesarCipherInput() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Caesar Cipher',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _caesarPlaintextController,
              decoration: InputDecoration(labelText: 'Enter Plaintext'),
            ),
            TextField(
              controller: _caesarShiftController,
              decoration: InputDecoration(labelText: 'Enter Shift Key'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  // Vigenère Cipher Input Widget
  Widget _buildVigenereCipherInput() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Vigenère Cipher',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _vigenereKeyController,
              decoration: InputDecoration(labelText: 'Enter Key (Alphabet)'),
            ),
          ],
        ),
      ),
    );
  }

  // AES Input Widget
  Widget _buildAesInput() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('AES Encryption',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedMode,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedMode = newValue!;
                });
              },
              items: <String>['CBC', 'ECB']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _selectedKeySize,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKeySize = newValue!;
                });
              },
              items: <String>['128', '192', '256']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('$value bits'),
                );
              }).toList(),
            ),
            TextField(
              controller: _aesSecretKeyController,
              decoration: InputDecoration(
                labelText: 'Enter Secret Key',
                hintText: 'Key length based on selected size (16/24/32 chars)',
              ),
              obscureText: true,
              maxLength: _selectedKeySize == '128'
                  ? 16
                  : _selectedKeySize == '192'
                      ? 24
                      : 32, // Max length based on key size
            ),
            if (_selectedMode == 'CBC')
              TextField(
                controller: _aesIvController,
                decoration: InputDecoration(
                  labelText: 'Enter IV (16 characters)',
                ),
                obscureText: true,
                maxLength: 16,
              ),
          ],
        ),
      ),
    );
  }
}
