import 'dart:math' as math;

/// Thrown for any malformed expression. The message is Persian and shown
/// to the user as is.
class ExprException implements Exception {
  ExprException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Evaluates a typed scientific expression.
///
/// Supports + − × ÷ ^ %, parentheses, factorial `!`, constants π and e,
/// the functions sin cos tan asin acos atan sinh cosh tanh sqrt cbrt abs ln
/// log exp floor ceil round, implicit multiplication (2π, 3(4+1)) and the
/// previous answer as `Ans`. Persian digits and operators are accepted.
class ExprEvaluator {
  ExprEvaluator({this.degrees = true, this.ans = 0});

  final bool degrees;
  final double ans;

  late List<_Tok> _t;
  int _i = 0;

  static String normalize(String raw) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    var s = raw;
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
    }
    return s
        .replaceAll('٫', '.')
        .replaceAll('٬', '')
        .replaceAll('×', '*')
        .replaceAll('·', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('–', '-')
        .replaceAll('√', 'sqrt')
        .replaceAll('٪', '%');
  }

  double evaluate(String input) {
    final s = normalize(input).trim();
    if (s.isEmpty) throw ExprException('عبارت خالی است');
    _t = _tokenize(s);
    _i = 0;
    final v = _expr();
    if (_i < _t.length) throw ExprException('عبارت ناقص یا نادرست است');
    if (v.isNaN) throw ExprException('نتیجه تعریف‌شده نیست');
    if (v.isInfinite) throw ExprException('نتیجه بی‌نهایت است (تقسیم بر صفر؟)');
    return v;
  }

  List<_Tok> _tokenize(String s) {
    final out = <_Tok>[];
    var i = 0;
    while (i < s.length) {
      final c = s[i];
      if (c == ' ') {
        i++;
      } else if (_isDigit(c) || c == '.') {
        final st = i;
        while (i < s.length && (_isDigit(s[i]) || s[i] == '.')) {
          i++;
        }
        final v = double.tryParse(s.substring(st, i));
        if (v == null) throw ExprException('عدد نامعتبر: ${s.substring(st, i)}');
        out.add(_Tok.num(v));
      } else if (_isAlpha(c)) {
        final st = i;
        while (i < s.length && _isAlpha(s[i])) {
          i++;
        }
        out.add(_Tok.id(s.substring(st, i).toLowerCase()));
      } else if (c == 'π') {
        out.add(_Tok.id('pi'));
        i++;
      } else if ('+-*/^%!(),'.contains(c)) {
        out.add(_Tok.op(c));
        i++;
      } else {
        throw ExprException('نویسه نامعتبر: $c');
      }
    }
    return out;
  }

  static bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;
  static bool _isAlpha(String c) {
    final u = c.toLowerCase().codeUnitAt(0);
    return u >= 97 && u <= 122;
  }

  _Tok? get _peek => _i < _t.length ? _t[_i] : null;
  bool _isOp(String o) => _peek != null && _peek!.kind == 1 && _peek!.text == o;

  // expr := term (('+'|'-') term)*
  double _expr() {
    var v = _term();
    while (true) {
      if (_isOp('+')) {
        _i++;
        v += _term();
      } else if (_isOp('-')) {
        _i++;
        v -= _term();
      } else {
        return v;
      }
    }
  }

  bool get _startsOperand {
    final p = _peek;
    if (p == null) return false;
    return p.kind == 0 || p.kind == 2 || (p.kind == 1 && p.text == '(');
  }

  // term := unary (('*'|'/') unary | implicit unary)*
  double _term() {
    var v = _unary();
    while (true) {
      if (_isOp('*')) {
        _i++;
        v *= _unary();
      } else if (_isOp('/')) {
        _i++;
        final d = _unary();
        if (d == 0) throw ExprException('تقسیم بر صفر');
        v /= d;
      } else if (_startsOperand) {
        v *= _unary();
      } else {
        return v;
      }
    }
  }

  // unary := ('-'|'+') unary | power
  double _unary() {
    if (_isOp('-')) {
      _i++;
      return -_unary();
    }
    if (_isOp('+')) {
      _i++;
      return _unary();
    }
    return _power();
  }

  // power := postfix ('^' unary)?   (right associative)
  double _power() {
    final base = _postfix();
    if (_isOp('^')) {
      _i++;
      final e = _unary();
      return math.pow(base, e).toDouble();
    }
    return base;
  }

  // postfix := primary ('!' | '%')*
  double _postfix() {
    var v = _primary();
    while (true) {
      if (_isOp('!')) {
        _i++;
        v = _factorial(v);
      } else if (_isOp('%')) {
        _i++;
        v = v / 100;
      } else {
        return v;
      }
    }
  }

  double _factorial(double v) {
    if (v < 0 || v != v.floorToDouble()) {
      throw ExprException('فاکتوریل فقط برای عدد صحیح نامنفی');
    }
    if (v > 170) throw ExprException('فاکتوریل بیش از ۱۷۰ قابل محاسبه نیست');
    var r = 1.0;
    for (var k = 2; k <= v; k++) {
      r *= k;
    }
    return r;
  }

  double _primary() {
    final p = _peek;
    if (p == null) throw ExprException('عبارت ناقص است');
    if (p.kind == 0) {
      _i++;
      return p.value;
    }
    if (p.kind == 1 && p.text == '(') {
      _i++;
      final v = _expr();
      if (!_isOp(')')) throw ExprException('پرانتز بسته نشده است');
      _i++;
      return v;
    }
    if (p.kind == 2) {
      _i++;
      final name = p.text;
      switch (name) {
        case 'pi':
          return math.pi;
        case 'e':
          return math.e;
        case 'ans':
          return ans;
      }
      if (!_fns.contains(name)) throw ExprException('نام ناشناخته: $name');
      double arg;
      if (_isOp('(')) {
        _i++;
        arg = _expr();
        if (!_isOp(')')) throw ExprException('پرانتز بسته نشده است');
        _i++;
      } else {
        // sin30, sqrt9: a bare operand binds tighter than a power
        arg = _power();
      }
      return _apply(name, arg);
    }
    throw ExprException('عملگر در جای نادرست: ${p.text}');
  }

  static const _fns = {
    'sin', 'cos', 'tan', 'asin', 'acos', 'atan', 'sinh', 'cosh', 'tanh',
    'sqrt', 'cbrt', 'abs', 'ln', 'log', 'exp', 'floor', 'ceil', 'round',
  };

  double _rad(double x) => degrees ? x * math.pi / 180 : x;
  double _out(double r) => degrees ? r * 180 / math.pi : r;

  double _apply(String f, double x) {
    switch (f) {
      case 'sin':
        return _clean(math.sin(_rad(x)));
      case 'cos':
        return _clean(math.cos(_rad(x)));
      case 'tan':
        final r = _rad(x);
        if (_clean(math.cos(r)) == 0) throw ExprException('tan تعریف‌شده نیست');
        return _clean(math.tan(r));
      case 'asin':
        if (x < -1 || x > 1) throw ExprException('asin فقط در بازه ۱- تا ۱');
        return _out(math.asin(x));
      case 'acos':
        if (x < -1 || x > 1) throw ExprException('acos فقط در بازه ۱- تا ۱');
        return _out(math.acos(x));
      case 'atan':
        return _out(math.atan(x));
      case 'sinh':
        return (math.exp(x) - math.exp(-x)) / 2;
      case 'cosh':
        return (math.exp(x) + math.exp(-x)) / 2;
      case 'tanh':
        final a = math.exp(x), b = math.exp(-x);
        return (a - b) / (a + b);
      case 'sqrt':
        if (x < 0) throw ExprException('جذر عدد منفی');
        return math.sqrt(x);
      case 'cbrt':
        return x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();
      case 'abs':
        return x.abs();
      case 'ln':
        if (x <= 0) throw ExprException('ln فقط برای عدد مثبت');
        return math.log(x);
      case 'log':
        if (x <= 0) throw ExprException('log فقط برای عدد مثبت');
        return math.log(x) / math.ln10;
      case 'exp':
        return math.exp(x);
      case 'floor':
        return x.floorToDouble();
      case 'ceil':
        return x.ceilToDouble();
      case 'round':
        return x.roundToDouble();
    }
    throw ExprException('تابع ناشناخته: $f');
  }

  /// Removes float noise such as sin(180°) = 1.2e-16.
  double _clean(double v) => v.abs() < 1e-12 ? 0 : v;
}

class _Tok {
  _Tok.num(this.value)
      : kind = 0,
        text = '';
  _Tok.op(this.text)
      : kind = 1,
        value = 0;
  _Tok.id(this.text)
      : kind = 2,
        value = 0;
  final int kind; // 0 number, 1 operator, 2 identifier
  final String text;
  final double value;
}

/// Shortest readable form of [v]: no trailing zeros, scientific for extremes.
String formatResult(double v) {
  if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
  final a = v.abs();
  if (a != 0 && (a >= 1e12 || a < 1e-6)) return v.toStringAsExponential(8);
  var s = v.toStringAsFixed(10);
  s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  return s;
}
