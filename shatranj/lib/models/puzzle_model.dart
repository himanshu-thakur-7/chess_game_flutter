class Puzzle {
  final String title;
  final String FEN;
  final String SolnPGN;
  final List<String> myMovesSol;
  final List<String> computerMoves;

  Puzzle(
      {required this.title,
      required this.FEN,
      required this.SolnPGN,
      required this.computerMoves,
      required this.myMovesSol});
}
