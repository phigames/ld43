part of ld43;

class Game {

  int levelNumber;
  Level level;

  Game() {
    levelNumber = 0;
    startLevel();
  }

  void startLevel() {
    stage.removeChildren();
    level = LevelTemplate.LVL_RH1.parse();
    stage.addChild(level.sprite);
  }

  void nextLevel() {
    levelNumber++;
    startLevel();
  }

}
