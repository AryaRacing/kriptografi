import 'package:cryptolicious/aes_page.dart';
import 'package:cryptolicious/rsa_page.dart';
import 'package:cryptolicious/vigenere_cipher.dart';
import 'package:flutter/material.dart';
import 'caesar_cipher.dart';
import 'super_encryption.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Algorithms',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Raleway',
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.green.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Cryptolicious',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black38,
                      offset: Offset(3.0, 3.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              CryptoCard(
                icon: Icons.lock,
                title: 'Caesar Cipher',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaesarCipherScreen(),
                    ),
                  );
                },
              ),
              CryptoCard(
                icon: Icons.vpn_key,
                title: 'Vigenere Cipher',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VigenereCipherScreen(),
                    ),
                  );
                },
              ),
              CryptoCard(
                icon: Icons.security,
                title: 'AES',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AESPage(),
                    ),
                  );
                },
              ),
              CryptoCard(
                icon: Icons.fingerprint,
                title: 'RSA',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RSAPage(),
                    ),
                  );
                },
              ),
              CryptoCard(
                icon: Icons.enhanced_encryption,
                title: 'Super Encryption',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuperEncryptionPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CryptoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  CryptoCard({required this.icon, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 10),
      shadowColor: Colors.black54,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        splashColor: Colors.blue.withAlpha(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.blueAccent),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }
}
