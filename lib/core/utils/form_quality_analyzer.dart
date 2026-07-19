class FormQualityAnalyzer {
  /// Default form quality when user doesn't self-report
  static const double defaultQuality = 0.7;

  /// Minimum acceptable form quality
  static const double minimumQuality = 0.3;

  /// Perfect form threshold
  static const double perfectQuality = 0.95;

  /// Label for a given form quality value
  static String qualityLabel(double quality) {
    if (quality >= 0.95) return 'Perfect';
    if (quality >= 0.85) return 'Excellent';
    if (quality >= 0.75) return 'Great';
    if (quality >= 0.65) return 'Good';
    if (quality >= 0.50) return 'Decent';
    if (quality >= 0.35) return 'Fair';
    return 'Needs Work';
  }

  /// Color for form quality display
  static int qualityColor(double quality) {
    if (quality >= 0.85) return 0xFF44FF44; // Green
    if (quality >= 0.65) return 0xFF4488FF; // Blue
    if (quality >= 0.45) return 0xFFFF8800; // Orange
    return 0xFFFF4444; // Red
  }

  /// Validate form quality is within range
  static double clampQuality(double value) {
    return value.clamp(0.0, 1.0);
  }

  /// Calculate average form quality from a list
  static double averageForm(List<double> qualities) {
    if (qualities.isEmpty) return defaultQuality;
    return qualities.reduce((a, b) => a + b) / qualities.length;
  }

  /// Format tips based on quality
  static List<String> formTips(double quality) {
    if (quality >= 0.85) {
      return ['Perfect form! Keep it up.'];
    }
    if (quality >= 0.65) {
      return [
        'Good form. Focus on controlled movements.',
        'Try slowing down for better control.',
      ];
    }
    return [
      'Reduce speed and focus on technique.',
      'Check your posture and alignment.',
      'Consider lowering weight/reps for better form.',
    ];
  }
}
