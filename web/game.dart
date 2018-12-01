part of ld43;

class Game {

  int levelNumber;
  Level level;
  int destroyedCount;
  TextField destroyedNumberField, destroyedTextField;

  Game() {
    levelNumber = 0;
    destroyedCount = 0;
    startLevel();
  }

  void startLevel() {
    stage.removeChildren();
    level = LevelTemplate.LD_LEVELS[levelNumber].parse();
    stage.addChild(level.sprite);
    destroyedNumberField = new TextField(destroyedCount.toString(), new TextFormat('Share, sans-serif', 12, 0x000000))
        ..width = 50
        ..x = 5
        ..y = 130;
    stage.addChild(destroyedNumberField);
    destroyedNumberField = new TextField('vehicles\ndestroyed', new TextFormat('Share, sans-serif', 5, 0x000000, leading: -4))
        ..width = 50
        ..x = 12
        ..y = 132;
    stage.addChild(destroyedNumberField);
  }

  void nextLevel() {
    levelNumber++;
    if (levelNumber >= LevelTemplate.LD_LEVELS.length) {
      print('game over');
    } else {
      startLevel();
    }
  }

  void onDestroyedCar() {
    destroyedCount++;
  }

}
