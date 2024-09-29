import 'package:flutter/material.dart';
import 'dart:math';

class RSAPage extends StatefulWidget {
  @override
  _RSAPageState createState() => _RSAPageState();
}

class _RSAPageState extends State<RSAPage> {
  int p = 0, q = 0, n = 0, m = 0, e = 0, d = 0;
  String _ciphertext = '';
  String _decryptedText = '';
  TextEditingController _plaintextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateKeys();
  }

  // Fungsi untuk menemukan GCD
  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  // Fungsi untuk mencari nilai e
  int _findE(int m) {
    int e = 2;
    while (e < m && _gcd(e, m) != 1) {
      e++;
    }
    return e;
  }

  // Fungsi untuk mencari nilai d (modular inverse of e mod m)
  int _modInverse(int e, int m) {
    int d = 1;
    while ((e * d) % m != 1) {
      d++;
    }
    return d;
  }

  // Generate key untuk RSA
  void _generateKeys() {
    Random rand = Random();
    List<int> primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31];
    
    // Pilih dua bilangan prima secara acak
    p = primes[rand.nextInt(primes.length)];
    q = primes[rand.nextInt(primes.length)];

    n = p * q;
    m = (p - 1) * (q - 1);

    e = _findE(m);
    d = _modInverse(e, m);

    setState(() {});
  }

  // Fungsi enkripsi menggunakan kunci publik (e, n)
  List<int> _encrypt(String plaintext) {
    return plaintext.codeUnits.map((int char) {
      return _modPow(char, e, n); // C = P^e mod n
    }).toList();
  }

  // Fungsi dekripsi menggunakan kunci privat (d, n)
  String _decrypt(List<int> ciphertext) {
    return String.fromCharCodes(
      ciphertext.map((int char) {
        return _modPow(char, d, n); // P = C^d mod n
      }).toList(),
    );
  }

  // Fungsi untuk menghitung hasil pangkat dengan modulo (Modular Exponentiation)
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

  void _encryptText() {
    setState(() {
      List<int> encryptedText = _encrypt(_plaintextController.text);
      _ciphertext = encryptedText.join(', '); // Menyimpan ciphertext sebagai string
    });
  }

  void _decryptText() {
    setState(() {
      List<int> encryptedChars = _ciphertext.split(', ').map((e) => int.parse(e)).toList();
      _decryptedText = _decrypt(encryptedChars);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RSA Key Generator & Encryption'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Key Details:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    SizedBox(height: 10),
                    Text('p : $p (Bil. Prima)', style: TextStyle(fontSize: 18)),
                    Text('q : $q (Bil. Prima)', style: TextStyle(fontSize: 18)),
                    Text('n : $n (p * q)', style: TextStyle(fontSize: 18)),
                    Text('m : $m ((p - 1) * (q - 1))', style: TextStyle(fontSize: 18)),
                    Text('e : $e (kunci publik)', style: TextStyle(fontSize: 18)),
                    Text('d : $d (kunci privat)', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text(
                      'Public Key: ($e, $n)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      'Private Key: ($d, $n)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateKeys,
                icon: Icon(Icons.vpn_key),
                label: Text('Regenerate Key'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _plaintextController,
                decoration: InputDecoration(
                  labelText: 'Enter plaintext',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _encryptText,
                icon: Icon(Icons.lock),
                label: Text('Encrypt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              SelectableText(
                'Ciphertext: $_ciphertext',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _decryptText,
                icon: Icon(Icons.lock_open),
                label: Text('Decrypt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              SelectableText(
                'Decrypted Text: $_decryptedText',
                style: TextStyle(fontSize: 16, color: Colors.orange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
