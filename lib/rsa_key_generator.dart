import 'dart:math';

class RSAKeyGenerator {
  int _p = 0;
  int _q = 0;
  int _n = 0;
  int _m = 0;
  int _e = 0;
  int _d = 0;

  // Fungsi untuk menghasilkan bilangan prima kecil
  int _generatePrime() {
    List<int> primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47];
    return primes[Random().nextInt(primes.length)];
  }

  // Fungsi untuk menghitung GCD (Greatest Common Divisor)
  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  // Fungsi untuk menghasilkan kunci RSA
  void generateKeys() {
    do {
      _p = _generatePrime();
      _q = _generatePrime();
    } while (_p == _q); // Ensure p and q are distinct

    _n = _p * _q;
    _m = (_p - 1) * (_q - 1);

    // Cari nilai e (bilangan prima yang relatif prima terhadap m)
    _e = 2;
    while (_e < _m && _gcd(_e, _m) != 1) {
      _e++;
    }

    // Cari nilai d, (d * e) % m == 1
    _d = 1;
    while ((_d * _e) % _m != 1) {
      _d++;
    }
  }

  // Fungsi untuk enkripsi plaintext
  List<int> encrypt(String plaintext) {
    List<int> encryptedText = [];
    for (int i = 0; i < plaintext.length; i++) {
      int charCode = plaintext.codeUnitAt(i);
      // Enkripsi menggunakan rumus: (charCode^e) % n
      int encryptedChar = BigInt.from(charCode).modPow(BigInt.from(_e), BigInt.from(_n)).toInt();
      encryptedText.add(encryptedChar);
    }
    return encryptedText;
  }

  // Fungsi untuk dekripsi ciphertext
  String decrypt(List<int> ciphertext) {
    String decryptedText = '';
    for (int encryptedChar in ciphertext) {
      // Dekripsi menggunakan rumus: (encryptedChar^d) % n
      int decryptedChar = BigInt.from(encryptedChar).modPow(BigInt.from(_d), BigInt.from(_n)).toInt();
      decryptedText += String.fromCharCode(decryptedChar);
    }
    return decryptedText;
  }

  // Getters untuk mengambil nilai dari kunci RSA
  int get p => _p;
  int get q => _q;
  int get n => _n;
  int get m => _m;
  int get e => _e;
  int get d => _d;
}
