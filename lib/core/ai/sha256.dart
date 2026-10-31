import 'dart:typed_data';

/// Minimal streaming SHA-256 (FIPS 180-4), used to verify downloaded model
/// files without adding a dependency.
class Sha256 {
  static const _k = <int>[
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];

  final _h = Uint32List.fromList([
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19,
  ]);
  final _block = Uint8List(64);
  final _w = Uint32List(64);
  int _blockLen = 0;
  int _total = 0;
  bool _done = false;

  void add(List<int> data) {
    if (_done) throw StateError('Sha256 already finalised');
    _total += data.length;
    var i = 0;
    while (i < data.length) {
      final n = (64 - _blockLen).clamp(0, data.length - i);
      _block.setRange(_blockLen, _blockLen + n, data, i);
      _blockLen += n;
      i += n;
      if (_blockLen == 64) {
        _process();
        _blockLen = 0;
      }
    }
  }

  static int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xffffffff;

  void _process() {
    for (var t = 0; t < 16; t++) {
      _w[t] = (_block[t * 4] << 24) | (_block[t * 4 + 1] << 16) | (_block[t * 4 + 2] << 8) | _block[t * 4 + 3];
    }
    for (var t = 16; t < 64; t++) {
      final s0 = _rotr(_w[t - 15], 7) ^ _rotr(_w[t - 15], 18) ^ (_w[t - 15] >> 3);
      final s1 = _rotr(_w[t - 2], 17) ^ _rotr(_w[t - 2], 19) ^ (_w[t - 2] >> 10);
      _w[t] = (_w[t - 16] + s0 + _w[t - 7] + s1) & 0xffffffff;
    }
    var a = _h[0], b = _h[1], c = _h[2], d = _h[3], e = _h[4], f = _h[5], g = _h[6], h = _h[7];
    for (var t = 0; t < 64; t++) {
      final s1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e) & 0xffffffff & g);
      final t1 = (h + s1 + ch + _k[t] + _w[t]) & 0xffffffff;
      final s0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final t2 = (s0 + maj) & 0xffffffff;
      h = g;
      g = f;
      f = e;
      e = (d + t1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (t1 + t2) & 0xffffffff;
    }
    _h[0] = (_h[0] + a) & 0xffffffff;
    _h[1] = (_h[1] + b) & 0xffffffff;
    _h[2] = (_h[2] + c) & 0xffffffff;
    _h[3] = (_h[3] + d) & 0xffffffff;
    _h[4] = (_h[4] + e) & 0xffffffff;
    _h[5] = (_h[5] + f) & 0xffffffff;
    _h[6] = (_h[6] + g) & 0xffffffff;
    _h[7] = (_h[7] + h) & 0xffffffff;
  }

  /// Finishes the hash and returns it as lowercase hex.
  String hex() {
    if (!_done) {
      final bitLen = _total * 8;
      final total = _total;
      add(const [0x80]);
      while (_blockLen != 56) {
        add(const [0]);
      }
      final len = Uint8List(8);
      for (var i = 0; i < 8; i++) {
        len[7 - i] = (bitLen >> (8 * i)) & 0xff;
      }
      add(len);
      _total = total;
      _done = true;
    }
    return _h.map((v) => v.toRadixString(16).padLeft(8, '0')).join();
  }

  static String of(List<int> data) => (Sha256()..add(data)).hex();
}
