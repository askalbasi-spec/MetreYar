import 'dart:math' as math;

/// One line of a leveling book. A row has a back sight (BS, on a known
/// point), an intermediate sight (IS) or a fore sight (FS, on the next
/// turning point). Each row uses exactly one of them.
class LevelRow {
  LevelRow({this.label = '', this.bs, this.isr, this.fs});
  String label;
  double? bs;
  double? isr;
  double? fs;
}

class LevelResult {
  const LevelResult({
    required this.rl,
    required this.sumBs,
    required this.sumFs,
    required this.firstRl,
    required this.lastRl,
    required this.arithmeticOk,
  });

  /// Reduced level of every row (null when it cannot be known yet).
  final List<double?> rl;
  final double sumBs;
  final double sumFs;
  final double firstRl;
  final double? lastRl;

  /// ΣBS − ΣFS equals last RL − first RL (checks the arithmetic only).
  final bool arithmeticOk;
}

/// Height-of-instrument method.
///
/// [startRl] is the known level of the first row, which must carry a BS.
/// A reading with FS or IS gets RL = HI − reading. A row with a BS starts a
/// new setup on that point: HI = RL(row) + BS. A turning point therefore
/// has both FS (closing the old setup) and BS (opening the next one).
LevelResult reduceLevels(List<LevelRow> rows, double startRl) {
  final rl = List<double?>.filled(rows.length, null);
  double? hi;
  var sumBs = 0.0, sumFs = 0.0;
  for (var i = 0; i < rows.length; i++) {
    final r = rows[i];
    if (i == 0) {
      rl[i] = startRl;
    } else if (hi != null) {
      if (r.fs != null) {
        rl[i] = hi - r.fs!;
      } else if (r.isr != null) {
        rl[i] = hi - r.isr!;
      }
    }
    if (r.fs != null) sumFs += r.fs!;
    if (r.bs != null) {
      sumBs += r.bs!;
      final base = rl[i];
      hi = base == null ? null : base + r.bs!;
    }
  }
  int? lastFs;
  for (var i = rows.length - 1; i > 0; i--) {
    if (rows[i].fs != null && rl[i] != null) {
      lastFs = i;
      break;
    }
  }
  final last = lastFs == null ? null : rl[lastFs];
  // The ΣBS − ΣFS check only holds when the book ends on a closing FS.
  final closes = lastFs != null && rows[lastFs].bs == null;
  final ok = !closes || ((sumBs - sumFs) - (last! - startRl)).abs() < 1e-6;
  return LevelResult(
    rl: rl,
    sumBs: sumBs,
    sumFs: sumFs,
    firstRl: startRl,
    lastRl: last,
    arithmeticOk: ok,
  );
}

/// Allowable misclosure in millimetres: [c] · √K with K in km.
double allowableMisclosureMm(double km, {double c = 10}) =>
    c * math.sqrt(km);

/// Misclosure of a closed loop or a line between two benchmarks:
/// computed final level minus the known final level, in millimetres.
double misclosureMm(double computedFinal, double knownFinal) =>
    (computedFinal - knownFinal) * 1000;

/// Distributes a misclosure equally over the turning points.
/// Returns the correction (metres) to add to each FS-based level, by order.
List<double> equalCorrections(int turningPoints, double misclosureM) {
  if (turningPoints <= 0) return const [];
  final per = -misclosureM / turningPoints;
  return [for (var k = 1; k <= turningPoints; k++) per * k];
}
