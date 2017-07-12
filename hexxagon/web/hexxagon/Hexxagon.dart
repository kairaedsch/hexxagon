import 'HexxagonMove.dart';

import '../general/Array2D.dart';
import '../general/Board.dart';
import '../general/Move.dart';
import '../general/TilePosition.dart';
import '../general/TileType.dart';
import '../general/GameResult.dart';
import 'package:meta/meta.dart';

class Hexxagon extends Board<Hexxagon>
{
  int _width, _height;

  int get width
  => _width;

  int get height
  => _height;

  Array2D<TileType> _tiles;
  TileType _currentPlayer;

  Hexxagon(int size)
  {
    _width = size + 1;
    _height = (size * 2 + 1) * 2;

    _tiles = new Array2D(_width, _height, TileType.EMPTY);
    _currentPlayer = TileType.PLAYER_ONE;

    TilePosition center = TilePosition.get((size / 2).floor(), (_height / 2).floor());
    for (int x = 0; x < _width; x++)
    {
      for (int y = 0; y < _height; y++)
      {
        TilePosition pos = TilePosition.get(x, y);
        var distance = center.getMaxDistanceTo(pos);
        if (distance > size)
        {
          set(pos, TileType.OUT_OF_FIELD);
        }
      }
    }

    _setStartTiles(size, center, 0, TileType.PLAYER_ONE);
    _setStartTiles(size, center, 1, TileType.PLAYER_TWO);
    _setStartTiles(size, center, 2, TileType.PLAYER_ONE);
    _setStartTiles(size, center, 3, TileType.PLAYER_TWO);
    _setStartTiles(size, center, 4, TileType.PLAYER_ONE);
    _setStartTiles(size, center, 5, TileType.PLAYER_TWO);

    _setStartTiles(1, center, 0, TileType.FORBIDDEN);
    _setStartTiles(1, center, 2, TileType.FORBIDDEN);
    _setStartTiles(1, center, 4, TileType.FORBIDDEN);
  }

  void _setStartTiles(int size, TilePosition center, int direction, TileType tile)
  {
    TilePosition toTarget = center;
    for (int i = 0; i < size; i++)
    {
      toTarget = new TilePosition(toTarget.x + toTarget.neighbourDeltas[direction][0], toTarget.y + toTarget.neighbourDeltas[direction][1]);
    }
    set(toTarget, tile);
  }

  Hexxagon.clone(Hexxagon hexxagon) {
    _width = hexxagon._width;
    _height = hexxagon._height;

    _tiles = new Array2D.empty(_width, _height);
    for (int x = 0; x < _width; x++)
    {
      for (int y = 0; y < _height; y++)
      {
        TilePosition pos = TilePosition.get(x, y);
        _tiles[x][y] = hexxagon.get(pos);
      }
    }
    _currentPlayer = hexxagon.currentPlayer;
  }

  @override
  Hexxagon cloneIt()
  {
    return new Hexxagon.clone(this);
  }

  @override
  void move(Move move)
  {
    if (!isValidMove(move))
    {
      throw new Exception("Invalid move");
    }

    set(move.target, _currentPlayer);
    int distance = move.source.getMaxDistanceTo(move.target);
    if (distance == 2)
    {
      set(move.source, TileType.EMPTY);
    }

    move.target.forEachNeighbour(this, (TilePosition neighbour)
    {
      if (get(neighbour) == notCurrentPlayer)
      {
        set(neighbour, _currentPlayer);
      }
    });

    _currentPlayer = notCurrentPlayer;
  }

  @protected
  bool isValidMove(Move move)
  {
    if (get(move.source) != _currentPlayer || get(move.target) != TileType.EMPTY)
    {
      return false;
    }

    int distance = move.source.getMaxDistanceTo(move.target);
    if (distance != 1 && distance != 2)
    {
      return false;
    }

    return true;
  }

  @protected
  void set(TilePosition position, TileType type)
  {
    _tiles.array[position.x][position.y] = type;
  }

  @override
  TileType get(TilePosition position)
  {
    return _tiles.array[position.x][position.y];
  }

  @override
  List<Move> getPossibleMoves(TilePosition from)
  {
    if (get(from) != _currentPlayer)
    {
      return new List(0);
    }
    List<Move> possibleMoves = [];
    from.forEachNeighbour(this, (neighbour)
    {
      if (get(neighbour) == TileType.EMPTY)
      {
        possibleMoves.add(new HexxagonMove(from, neighbour));
      }
    });
    from.forEachNeighbourSecondRing(this, (neighbour)
    {
      if (get(neighbour) == TileType.EMPTY)
      {
        possibleMoves.add(new HexxagonMove(from, neighbour));
      }
    });
    return possibleMoves;
  }

  @override
  bool couldBeMoved(TilePosition position)
  {
    return get(position) == _currentPlayer;
  }

  @override
  TileType get currentPlayer
  => _currentPlayer;

  @protected
  void set currentPlayer(TileType currentPlayer) {
  _currentPlayer = currentPlayer;
  }

  @override
  bool get isOver
  {
    for (int x = 0; x < _width; x++)
    {
      for (int y = 0; y < _height; y++)
      {
        TilePosition from = TilePosition.get(x, y);
        if (getPossibleMoves(from).isNotEmpty)
        {
          return false;
        }
      }
    }
    return true;
  }

  @override
  TileType get betterPlayer
  {
    int playerOne = 0,
        playerTwo = 0;
    for (int x = 0; x < _width; x++)
    {
      for (int y = 0; y < _height; y++)
      {
        TileType type = get(TilePosition.get(x, y));
        if (type == TileType.PLAYER_ONE)
        {
          playerOne++;
        }
        else if (type == TileType.PLAYER_TWO)
        {
          playerTwo++;
        }
      }
    }
    return playerOne > playerTwo ? TileType.PLAYER_ONE : playerOne < playerTwo ? TileType.PLAYER_TWO : TileType.EMPTY;
  }

  @override
  GameResult getResult(TileType player)
  {
    TileType betterPlayer = this.betterPlayer;
    if (betterPlayer == player)
    {
      return GameResult.WIN;
    }
    else if (betterPlayer == TileType.EMPTY)
    {
      return GameResult.DRAW;
    }
    else
    {
      return GameResult.LOST;
    }
  }

  @override
  int countTilesOfType(TileType player)
  {
    int count = 0;
    for (int x = 0; x < _width; x++)
    {
      for (int y = 0; y < _height; y++)
      {
        TileType type = get(TilePosition.get(x, y));
        if (type == player)
        {
          count++;
        }
      }
    }
    return count;
  }
}