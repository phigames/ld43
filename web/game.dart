part of ld43;

class Game {

  int levelNumber;
  Level level;
  int destroyedCount;
  TextField levelNumberField, levelTextField;
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
    destroyedNumberField = new TextField(destroyedCount.toString(), new TextFormat('Share, sans-serif', 12, 0x000000, align: 'right'))
        ..width = 16
        ..x = 30
        ..y = 130;
    stage.addChild(destroyedNumberField);
    destroyedTextField = new TextField('vehicles\ndestroyed', new TextFormat('Share, sans-serif', 5, 0x000000, leading: -4))
        ..width = 20
        ..x = 47
        ..y = 132;
    stage.addChild(destroyedTextField);
    levelNumberField = new TextField(levelNumber.toString(), new TextFormat('Share, sans-serif', 12, 0x000000))
        ..width = 50
        ..x = 16
        ..y = 130;
    stage.addChild(levelNumberField);
    levelTextField = new TextField('\nlevel', new TextFormat('Share, sans-serif', 5, 0x000000, align: 'right', leading: -4))
        ..width = 15
        ..x = 0
        ..y = 132;
    stage.addChild(levelTextField);
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
    destroyedNumberField.text = destroyedCount.toString();
  }

}
