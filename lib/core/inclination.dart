import 'dart:math' as math;

/// Tilt of the phone from an accelerometer reading (m/s², device axes).
/// [flat] is true when the phone lies face up: returns the pitch and roll
/// in degrees. Used by the digital level.
class Tilt {
  const Tilt(this.pitch, this.roll);
  final double pitch;
  final double roll;

  /// Total angle from horizontal when lying flat.
  double get flatAngle => math.sqrt(pitch * pitch + roll * roll);
}

/// Angle (degrees) the phone's edge makes with the horizontal, when held
/// upright against a surface. Positive tilts one way, negative the other.
/// Uses the screen's x/y plane: 0° when y points straight up.
double edgeInclinationDeg(double x, double y) =>
    math.atan2(x, y) * 180 / math.pi;

/// Pitch/roll when the phone lies on a surface (z axis ≈ gravity).
Tilt flatTilt(double x, double y, double z) {
  final pitch = math.atan2(y, math.sqrt(x * x + z * z)) * 180 / math.pi;
  final roll = math.atan2(x, math.sqrt(y * y + z * z)) * 180 / math.pi;
  return Tilt(pitch, roll);
}

/// Slope in percent for an angle in degrees: tan(angle)·100.
double slopePercent(double deg) => math.tan(deg * math.pi / 180) * 100;
