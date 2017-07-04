import '../../../general/Move.dart';
import '../../../general/Intelligence.dart';
import '../../../general/TileType.dart';
import '../ArtificialIntelligence.dart';
import '../../Hexxagon.dart';

typedef double Heuristic(Hexxagon hexxagon, TileType player);

class MinMaxAI extends ArtificialIntelligence
{
  int treeDepth;

  String get name
  => "Min Max Player level $strength";

  int get strength => (treeDepth - 1);

  MinMaxAI(this.treeDepth);

  void moveKI(Hexxagon hexxagon, MoveCallback moveCallback)
  {
    List<Move> allPossibleMoves = hexxagon.getAllPossibleMoves();

    Move bestMove = null;
    double bestValue = double.NEGATIVE_INFINITY;
    for (Move move in allPossibleMoves)
    {
      Hexxagon childHexxagon = new Hexxagon.clone(hexxagon);
      childHexxagon.move(move.source, move.target);
      double childValue = minimax(childHexxagon, treeDepth, heuristic, hexxagon.currentPlayer, bestValue);
      if (childValue > bestValue)
      {
        bestValue = childValue;
        bestMove = move;
      }
    }

    moveCallback(bestMove);
  }

  double heuristic(Hexxagon hexxagon, TileType player)
  {
    return hexxagon.countTilesOfType(player).roundToDouble();
  }

  double minimax(Hexxagon hexxagon, int depth, Heuristic heuristic, TileType player, double bestNeighbour)
  {
    if (depth == 0)
    {
      return heuristic(hexxagon, player);
    }

    List<Move> allPossibleMoves = hexxagon.getAllPossibleMoves();
    if (allPossibleMoves.length == 0)
    {
      return heuristic(hexxagon, player);
    }

    if (hexxagon.currentPlayer == player)
    {
      double bestValue = double.NEGATIVE_INFINITY;
      for (Move move in allPossibleMoves)
      {
        Hexxagon childHexxagon = new Hexxagon.clone(hexxagon);
        childHexxagon.move(move.source, move.target);
        double childValue = minimax(childHexxagon, depth - 1, heuristic, player, bestValue);
        if (childValue > bestValue)
        {
          bestValue = childValue;
        }
        if (bestValue > bestNeighbour)
        {
          return bestValue;
        }
      }

      return bestValue;
    }
    else
    {
      double bestValue = double.INFINITY;
      for (Move move in allPossibleMoves)
      {
        Hexxagon childHexxagon = new Hexxagon.clone(hexxagon);
        childHexxagon.move(move.source, move.target);
        double childValue = minimax(childHexxagon, depth - 1, heuristic, player, bestValue);
        if (childValue < bestValue)
        {
          bestValue = childValue;
        }
        if (bestValue < bestNeighbour)
        {
          return bestValue;
        }
      }

      return bestValue;
    }
  }
}