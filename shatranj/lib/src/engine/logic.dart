import "package:bishop/bishop.dart" as bishop;
import "package:flutter/foundation.dart";

bishop.Game? game;
bishop.Engine? engine;

Future<String> getEngineMove(String? fen) async {
  game = bishop.Game(variant: bishop.Variant.standard(), fen: fen);

  bishop.EngineResult result = await compute(engineSearch, game!);
  if (result.hasMove) {
    print("best move: ${formatResult(result)}");
    String san = game!.toSan(result.move!);
    print(san);
    return san;
  }
  return "";
}

String formatResult(bishop.EngineResult res) {
  if (game == null) return 'No Game';
  if (!res.hasMove) return 'No Move';
  String san = game!.toSan(res.move!);
  return '$san (${res.eval}) [depth ${res.depth}]';
}

Future<bishop.EngineResult> engineSearch(bishop.Game game) async {
  return await bishop.Engine(game: game)
      .search(timeLimit: 1000, timeBuffer: 500);
}
