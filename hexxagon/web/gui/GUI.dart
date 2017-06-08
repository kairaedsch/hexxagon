import '../game/Hexxagon.dart';
import '../general/Board.dart';
import '../general/Game.dart';
import '../general/Move.dart';
import '../general/Player.dart';
import '../general/TilePosition.dart';
import '../general/TileType.dart';
import 'GUIState.dart';
import 'GameGUI.dart';
import 'dart:async';
import 'package:optional/optional.dart';
import 'package:tuple/tuple.dart';

class GUI
{
  GUIState _guiState;

  bool get isPlayerSelection
  => _guiState == GUIState.PLAYER_SELECTION;

  bool get isGameRunning
  => _guiState == GUIState.GAME_RUNNING;

  bool get isGameOver
  => _guiState == GUIState.GAME_OVER;

  GameGUI _currentGameGui;

  GameGUI get currentGameGui
  => _currentGameGui;

  List<Function> _stateChangedListener;
  List<Function> _gameChangedListener;

  Player<Hexxagon> playerOne;
  Player<Hexxagon> playerTwo;

  GUI()
  {
    _stateChangedListener = [];
    _gameChangedListener = [];
    _guiState = GUIState.PLAYER_SELECTION;
  }

  void startNewGame()
  {
    if (isPlayerSelection)
    {
      _currentGameGui = new GameGUI(new Game(new Hexxagon(4), playerOne, playerTwo), 0);
      _guiState = GUIState.GAME_RUNNING;
      _currentGameGui.addChangeListener(gameChanged);
      notifyGameChanged();
      notifyStateChanged();
    }
  }

  void gameChanged()
  {
    if (isGameRunning)
    {
      notifyGameChanged();
      if (_currentGameGui.isOver)
      {
        _guiState = GUIState.GAME_OVER;
        notifyStateChanged();
      }
    }
  }

  void selectPlayer()
  {
    _guiState = GUIState.PLAYER_SELECTION;
    notifyStateChanged();
  }

  void notifyStateChanged()
  {
    _stateChangedListener.forEach((f)
    => f());
  }

  void notifyGameChanged()
  {
    _gameChangedListener.forEach((f)
    => f());
  }

  void addStateChangeListener(Function f)
  {
    _stateChangedListener.add(f);
  }

  void addGameChangeListener(Function f)
  {
    _gameChangedListener.add(f);
  }
}