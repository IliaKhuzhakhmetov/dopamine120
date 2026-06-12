/// How ready the user feels to choose a useful action over autopilot scrolling.
class ActionReadiness {
  const ActionReadiness(this.score)
    : assert(score >= minScore && score <= maxScore);

  const ActionReadiness.neutral() : score = neutralScore;

  static const minScore = 0;
  static const maxScore = 10;
  static const neutralScore = 5;

  final int score;
}
