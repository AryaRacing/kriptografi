import 'package:flutter/material.dart';
import 'dart:math';
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

  String _encryptionMode = 'CBC'; // Default AES mode
  String _rsaCiphertext = '';
  String _rsaDecryptedText = '';
  String _superEncryptedData = '';
  
  String _selectedKeySize = '128'; // Default key size
  int _secretKeyLength = 0; // For secret key character count
  int _ivLength = 0; // For IV character count

  // RSA parameters
  int p = 0, q = 0, n = 0, m = 0, e = 0, d = 0;

  @override
  void initState() {
    super.initState();
    _generateRSAKeys();
  }

  // RSA Key Generation Functions
  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  int _findE(int m) {
    int e = 2;
    while (e < m && _gcd(e, m) != 1) {
      e++;
    }
    return e;
  }

  int _modInverse(int e, int m) {
    int d = 1;
    while ((e * d) % m != 1) {
      d++;
    }
    return d;
  }

  void _generateRSAKeys() {
    Random rand = Random();
    List<int> primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31];

    p = primes[rand.nextInt(primes.length)];
    q = primes[rand.nextInt(primes.length)];

    n = p * q;
    m = (p - 1) * (q - 1);

    e = _findE(m);
    d = _modInverse(e, m);

    setState(() {});
  }

  int _modPow(int base, int exp, int mod) {
    int result = 1;
    base = base % mod;
    while (exp > 0) {
      if (exp % 2 == 1) result = (result * base) % mod;
      exp = exp >> 1;
      base = (base * base) % mod;
    }
    return result;
  }

  List<int> _rsaEncrypt(String plaintext) {
    return plaintext.codeUnits.map((int char) {
      return _modPow(char, e, n);
    }).toList();
  }

  String _rsaDecrypt(List<int> ciphertext) {
    return String.fromCharCodes(
      ciphertext.map((int char) {
        return _modPow(char, d, n);
      }).toList(),
    );
  }

  void _rsaEncryptText() {
    setState(() {
      List<int> encryptedText = _rsaEncrypt(_superEncryptedData); // Use super encrypted data for RSA
      _rsaCiphertext = encryptedText.join(', ');
    });
  }

  void _rsaDecryptText() {
    setState(() {
      List<String> ciphertextParts = _rsaCiphertext.split(', ');
      List<int> ciphertextNumbers = ciphertextParts
          .map((part) => int.tryParse(part))
          .where((num) => num != null)
          .cast<int>()
          .toList();
      _rsaDecryptedText = _rsaDecrypt(ciphertextNumbers);
    });
  }

  // Caesar Cipher Methods
  String _caesarEncrypt(String plaintext, int shift) {
    return String.fromCharCodes(
      plaintext.runes.map((char) {
        return char + shift;
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

  String _aesEncrypt(String plaintext, String secretKey, String iv) {
    // Add your AES encryption logic here (this is just a placeholder)
    return base64.encode(utf8.encode(plaintext)); // Placeholder encoding
  }

  String _superEncrypt() {
    // Get user inputs
    String caesarText = _caesarEncrypt(_caesarPlaintextController.text, int.parse(_caesarShiftController.text));
    String vigenereText = _vigenereEncrypt(caesarText, _vigenereKeyController.text);
    String aesText = _aesEncrypt(vigenereText, _aesSecretKeyController.text, _aesIvController.text);
    
    // Convert the final result into a readable format
    return "AES: $aesText"; // Only return AES output for RSA encryption
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

            // RSA Card
            _buildRSACard(),
            SizedBox(height: 20),

            // Final Encrypt Button for Super Encryption
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _superEncryptedData = _superEncrypt();
                });
              },
              child: Text('Encrypt using Super Encryption'),
            ),
            SizedBox(height: 20),

            // Output for Super Encrypted Data
            SelectableText(
              'Super Encrypted Data: $_superEncryptedData',
              style: TextStyle(fontSize: 16, color: Colors.green),
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
            Text('Caesar Cipher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text('Vigenère Cipher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text('AES Encryption', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            // Key Size Dropdown
            DropdownButton<String>(
              value: _selectedKeySize,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedKeySize = newValue!;
                  // Clear the secret key controller when changing key size
                  _aesSecretKeyController.clear();
                  _secretKeyLength = 0; // Reset character count
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
              decoration: InputDecoration(labelText: 'Enter Secret Key'),
              onChanged: (text) {
                setState(() {
                  _secretKeyLength = text.length; // Update character count
                });
              },
            ),
            // Display required character count based on selected key size
            Text(
              'Required Characters: ${_selectedKeySize == '128' ? 16 : _selectedKeySize == '192' ? 24 : 32}',
              style: TextStyle(color: Colors.grey),
            ),
            // Display current character count
            Text('Current Character Count: $_secretKeyLength', style: TextStyle(color: Colors.grey)),
            if (_encryptionMode == 'CBC') // Conditional IV Field
              Column(
                children: [
                  TextField(
                    controller: _aesIvController,
                    decoration: InputDecoration(labelText: 'Enter IV (for CBC)'),
                    onChanged: (text) {
                      setState(() {
                        _ivLength = text.length; // Update IV character count
                      });
                    },
                  ),
                  // Display character count for IV
                  Text('Character Count: $_ivLength', style: TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // RSA Card
  Widget _buildRSACard() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('RSA Encryption', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Public Key: (e: $e, n: $n)'),
            Text('Private Key: (d: $d)'),
            TextField(
              decoration: InputDecoration(labelText: 'Ciphertext'),
              onChanged: (text) {
                setState(() {
                  _rsaCiphertext = text;
                });
              },
            ),
            ElevatedButton(
              onPressed: _rsaEncryptText,
              child: Text('Encrypt with RSA'),
            ),
            Text('Encrypted Text: $_rsaCiphertext'),
            ElevatedButton(
              onPressed: _rsaDecryptText,
              child: Text('Decrypt with RSA'),
            ),
            Text('Decrypted Text: $_rsaDecryptedText'),
          ],
        ),
      ),
    );
  }
}
