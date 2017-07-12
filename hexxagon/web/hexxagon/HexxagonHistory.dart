import '../general/Move.dart';
import '../general/TilePosition.dart';
import '../general/TileType.dart';
import 'Hexxagon.dart';

class HexxagonHistory extends Hexxagon
{
  List<List<TilePosition>> _history;

  HexxagonHistory.clone(Hexxagon hexxagon) : super.clone(hexxagon)
  {
    _history = [];
  }

  @override
  void move(Move move)
  {
    if (!isValidMove(move))
    {
      throw new Exception("Invalid move");
    }

    List<TilePosition> changed = [];

    set(move.target, currentPlayer);
    changed.add(move.target);
    int distance = move.source.getMaxDistanceTo(move.target);
    if (distance == 2)
    {
      set(move.source, TileType.EMPTY);
      changed.add(move.source);
    }

    move.target.forEachNeighbour(this, (TilePosition neighbour)
    {
      if (get(neighbour) == notCurrentPlayer)
      {
        set(neighbour, currentPlayer);
        changed.add(neighbour);
      }
    });

    _history.add(changed);
    currentPlayer = notCurrentPlayer;
  }

  void undoLastMove()
  {
    if (_history.isEmpty)
    {
      throw new Exception();
    }

    List<TilePosition> changes = _history.removeLast();

    set(changes[0], TileType.EMPTY);
    for (int i = 1; i < changes.length; i++)
    {
      TilePosition change = changes[i];
      if (get(change) == TileType.EMPTY)
      {
        set(change, notCurrentPlayer);
      }
      else if (get(change) == notCurrentPlayer)
      {
        set(change, currentPlayer);
      }
      else
      {
        throw new Exception();
      }
    }

    currentPlayer = notCurrentPlayer;
  }
}