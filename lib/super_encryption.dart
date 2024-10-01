import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:math';

class SuperEncryptionPage extends StatefulWidget {
  @override
  _SuperEncryptionPageState createState() => _SuperEncryptionPageState();
}

class _SuperEncryptionPageState extends State<SuperEncryptionPage> {
  final TextEditingController _caesarPlaintextController = TextEditingController();
  final TextEditingController _caesarShiftController = TextEditingController();
  final TextEditingController _vigenereKeyController = TextEditingController();
  final TextEditingController _aesSecretKeyController = TextEditingController();
  final TextEditingController _aesIVController = TextEditingController();

  String _selectedKeySize = '128';
  String _selectedMode = 'CBC';
  String _finalOutput = '';
  BigInt _publicKey = BigInt.zero;
  BigInt _n = BigInt.zero;
  BigInt _privateKey = BigInt.zero; // Store private key
  String _rsaKeyDisplay = '';

  // Predefined set of prime numbers for RSA
  final List<BigInt> _primes = [
    BigInt.from(3),
    BigInt.from(5),
    BigInt.from(7),
    BigInt.from(11),
    BigInt.from(13),
    BigInt.from(17),
    BigInt.from(19),
    BigInt.from(23),
    BigInt.from(29),
    BigInt.from(31),
    BigInt.from(37),
    BigInt.from(41),
    BigInt.from(43),
    BigInt.from(47),
  ];

  // Method to select random prime from predefined list
  BigInt _selectRandomPrime() {
    Random random = Random();
    return _primes[random.nextInt(_primes.length)];
  }

  // Method to generate a valid public exponent e
  BigInt _generateDynamicPublicExponent(BigInt phi) {
    List<BigInt> candidates = [BigInt.from(3), BigInt.from(5), BigInt.from(17), BigInt.from(65537)];
    for (BigInt candidate in candidates) {
      if (phi.gcd(candidate) == BigInt.one) {
        return candidate; // Return the first valid candidate
      }
    }
    return BigInt.from(3); // Default to 3 if no valid candidates found
  }

  // Method to handle RSA key generation
  void _generateRSAKeys() {
    BigInt p = _selectRandomPrime(); // Generate random prime
    BigInt q = _selectRandomPrime(); // Generate another random prime

    // Ensure p and q are not the same
    while (p == q) {
      q = _selectRandomPrime();
    }

    _n = p * q;
    BigInt phi = (p - BigInt.one) * (q - BigInt.one);

    // Generate dynamic public exponent
    BigInt e = _generateDynamicPublicExponent(phi);

    _privateKey = e.modInverse(phi); // Calculate private exponent
    _publicKey = e;

    // Update the displayed RSA keys
    _rsaKeyDisplay = 'Public Key: ($e, $_n)\nPrivate Key: $_privateKey';

    setState(() {}); // Trigger UI update
  }

  String _caesarCipher(String plaintext, int shift) {
    return plaintext.split('').map((char) {
      if (!RegExp(r'[a-zA-Z]').hasMatch(char)) return char;
      int base = char.codeUnitAt(0) < 97 ? 65 : 97;
      return String.fromCharCode((char.codeUnitAt(0) - base + shift) % 26 + base);
    }).join('');
  }

  String _vigenereCipher(String plaintext, String key) {
    String result = '';
    for (int i = 0, j = 0; i < plaintext.length; i++) {
      var char = plaintext[i];
      if (RegExp(r'[a-zA-Z]').hasMatch(char)) {
        int base = char.codeUnitAt(0) < 97 ? 65 : 97;
        int shift = key[j % key.length].toUpperCase().codeUnitAt(0) - 65;
        result += String.fromCharCode((char.codeUnitAt(0) - base + shift) % 26 + base);
        j++;
      } else {
        result += char;
      }
    }
    return result;
  }

  String _aesEncrypt(String plaintext, String secretKey, {String? iv}) {
    final key = encrypt.Key.fromUtf8(secretKey.padRight(32, '0')); // Pad to 32 characters
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final ivValue = iv != null ? encrypt.IV.fromUtf8(iv) : encrypt.IV.fromLength(16); // Default IV if ECB

    final encrypted = encrypter.encrypt(plaintext, iv: ivValue);
    return encrypted.base64;
  }

  String _rsaEncrypt(String plaintext) {
    final encoded = utf8.encode(plaintext);
    final bigIntPlaintext = BigInt.from(encoded[0]); // Simplified RSA Encryption for demonstration
    final encrypted = bigIntPlaintext.modPow(_publicKey, _n);
    return encrypted.toString();
  }

  void _superEncrypt() {
    String caesarPlaintext = _caesarPlaintextController.text;
    int caesarShift = int.parse(_caesarShiftController.text);
    String vigenereKey = _vigenereKeyController.text;
    String aesSecretKey = _aesSecretKeyController.text;
    String? aesIV = _selectedMode == 'CBC' ? _aesIVController.text : null; // Get IV if CBC mode

    // Validate secret key length
    if ((aesSecretKey.length != 16 && _selectedKeySize == '128') ||
        (aesSecretKey.length != 24 && _selectedKeySize == '192') ||
        (aesSecretKey.length != 32 && _selectedKeySize == '256')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Invalid Key Length'),
          content: Text('Secret key must be ${_selectedKeySize == '128' ? '16' : _selectedKeySize == '192' ? '24' : '32'} characters long for $_selectedKeySize bits.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Perform Caesar Cipher encryption
    String caesarEncrypted = _caesarCipher(caesarPlaintext, caesarShift);
    
    // Perform Vigenère Cipher encryption
    String vigenereEncrypted = _vigenereCipher(caesarEncrypted, vigenereKey);
    
    // Perform AES encryption
    String aesEncrypted = _aesEncrypt(vigenereEncrypted, aesSecretKey, iv: aesIV);
    
    // Perform RSA encryption on the AES result
    String rsaEncrypted = _rsaEncrypt(aesEncrypted);
    
    // Combine results
    _finalOutput = 'Caesar: $caesarEncrypted\nVigenère: $vigenereEncrypted\nAES: $aesEncrypted\nRSA: $rsaEncrypted';
    
    // Display the final output
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Super Encryption Result', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(_finalOutput),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

Widget _buildTextField(TextEditingController controller, String label, {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Super Encryption')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.green[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildInputCard('Caesar Cipher Input', [
                _buildTextField(_caesarPlaintextController, 'Plaintext'),
                _buildTextField(_caesarShiftController, 'Shift Value', keyboardType: TextInputType.number),
              ]),
              _buildInputCard('Vigenère Cipher Input', [
                _buildTextField(_vigenereKeyController, 'Key'),
              ]),
              _buildInputCard('AES Input', [
                _buildDropdownKeySize(),
                _buildDropdownMode(),
                _buildTextFieldWithCount(_aesSecretKeyController, 'Secret Key', obscureText: false), // Changed obscureText to false
                if (_selectedMode == 'CBC') _buildTextFieldWithCount(_aesIVController, 'IV', obscureText: true),
              ]),
              _buildRSAInputCard(), // Updated RSA card
              ElevatedButton(
                onPressed: _superEncrypt,
                child: Text('Super Encrypt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card builder for inputs
  Widget _buildInputCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...children,
          ],
        ),
      ),
    );
  }

  // Card builder for AES input with character count
Widget _buildTextFieldWithCount(TextEditingController controller, String label, {bool obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        obscureText: obscureText, // Set this to false when calling for AES secret key
      ),
      Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Text('${controller.text.length} characters', style: TextStyle(color: Colors.grey)),
      ),
    ],
  );
}
  // Dropdown for AES key size selection
  Widget _buildDropdownKeySize() {
    return DropdownButton<String>(
      value: _selectedKeySize,
      items: <String>['128', '192', '256'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text('$value bits'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedKeySize = newValue!;
        });
      },
    );
  }

  // Dropdown for AES mode selection
  Widget _buildDropdownMode() {
    return DropdownButton<String>(
      value: _selectedMode,
      items: <String>['CBC', 'ECB'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedMode = newValue!;
        });
      },
    );
  }

  // Build RSA card for key display
  Widget _buildRSAInputCard() {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RSA Key Generation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: _generateRSAKeys,
              child: Text('Generate RSA Keys'),
            ),
            SizedBox(height: 10),
            Text(_rsaKeyDisplay, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

