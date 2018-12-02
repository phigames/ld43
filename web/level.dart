part of ld43;

class Level {

  static final int FIELD_X = 1, FIELD_Y = 3;
  static final int BOMB_X = 7, BOMB_Y = 11;

  int width, height;
  int exitX, exitY;
  List<Car> cars;
  String tutorialText;
  bool won;
  Sprite sprite, fieldSprite, bombSprite;

  Level.empty(this.width, this.height, [this.tutorialText = '']) {
    exitX = width;
    exitY = (height - 1) ~/ 2;
    cars = new List<Car>();
    won = false;
    sprite = new Sprite()
      ..scaleX = 100 / (width + 2)
      ..scaleY = 100 / (height + 2);

    // field
    fieldSprite = new Sprite();
    fieldSprite.graphics.beginPath();
    fieldSprite.graphics.rect(0, 0, width, height);
    fieldSprite.graphics.fillColor(0xFFCCCCCC);
    fieldSprite.x = FIELD_X;
    fieldSprite.y = FIELD_Y;
    sprite.addChild(fieldSprite);

    // exit
    fieldSprite.addChild(
      new Bitmap(resourceManager.getBitmapData('exit'))
        ..x = exitX
        ..y = exitY
        ..width = 1
        ..height = 1
    );
    
    // border
    for (int i = FIELD_X - 1; i <= FIELD_X + width; i++) {
      sprite.addChild(
        new Bitmap(resourceManager.getBitmapData('border'))
          ..x = i
          ..y = FIELD_Y - 1
          ..width = 1
          ..height = 1
      );
      sprite.addChild(
        new Bitmap(resourceManager.getBitmapData('border'))
          ..x = i
          ..y = FIELD_Y + height
          ..width = 1
          ..height = 1
      );
    }
    for (int j = FIELD_Y; j < FIELD_Y + height; j++) {
      sprite.addChild(
        new Bitmap(resourceManager.getBitmapData('border'))
          ..x = FIELD_X - 1
          ..y = j
          ..width = 1
          ..height = 1
      );
      if (j != FIELD_Y + exitY) {
        sprite.addChild(
          new Bitmap(resourceManager.getBitmapData('border'))
            ..x = FIELD_X + width
            ..y = j
            ..width = 1
            ..height = 1
        );
      }
    }

    // bomb
    bombSprite = new Sprite();
    bombSprite.addChild(
      new Bitmap(resourceManager.getBitmapData('grenade'))
        ..width = 1
        ..height = 1
    );
    bombSprite.pivotX = bombSprite.pivotY = 0.5;
    bombSprite.x = BOMB_X;
    bombSprite.y = BOMB_Y;
    bombSprite.onMouseDown.listen((e) => _startBombDrag());
    bombSprite.onTouchBegin.listen((e) => _startBombDrag());
    bombSprite.onMouseUp.listen((e) => _stopBombDrag());
    bombSprite.onTouchEnd.listen((e) => _stopBombDrag());
    sprite.addChild(bombSprite);
  }

  void addCar(int x, int y, Direction direction, int length, [bool player = false]) {
    Car car = new Car(this, x, y, direction, length, player);
    cars.add(car);
    fieldSprite.addChild(car.sprite);
  }

  void explodeCar(Car car) {
    car.animateExplode(() {
      cars.remove(car);
      fieldSprite.removeChild(car.sprite);
      if (car.player) {
        onLost();
      }
    });
    game.onDestroyedCar();
  }

  bool isOccupied(int x, int y) {
    if (!(x == exitX && y == exitY) && (x < 0 || x >= width || y < 0 || y >= height)) {
      return true;
    }
    if (getOccupyingCar(x, y) != null) {
      return true;
    }
    return false;
  }

  Car getOccupyingCar(int x, int y) {
    for (Car car in cars) {
      if (car.occupies(x, y)) {
        return car;
      }
    }
    return null;
  }

  void checkWon(Car car) {
    if (!won) {
      if (car.player && car.occupies(exitX, exitY)) {
        won = true;
        car.animateWon(onWon);
      }
    }
  }

  void onWon() {
    game.nextLevel();
  }

  void onLost() {
    print('lost');
  }

  void _startBombDrag() {
    stage.juggler.addTween(bombSprite, 0.1)
      ..animate.scaleX.to(1.2)
      ..animate.scaleY.to(1.2);
    bombSprite.startDrag(true);
  }
  
  void _stopBombDrag() {
    Point dropPoint = fieldSprite.globalToLocal(sprite.localToGlobal(Point(bombSprite.x, bombSprite.y)));
    Car dropCar = getOccupyingCar(dropPoint.x.floor(), dropPoint.y.floor());
    if (dropCar != null) {
      // drop the bomb
      stage.juggler.addTween(bombSprite, 0.4, Transition.easeInQuadratic)
        ..animate.scaleX.to(0.3)
        ..animate.scaleY.to(0.3)
        ..onComplete = () {
          explodeCar(dropCar);
          bombSprite.x = BOMB_X;
          bombSprite.y = BOMB_Y;
          bombSprite.scaleX = bombSprite.scaleY = 0;
          stage.juggler.addTween(bombSprite, 0.2, Transition.easeInOutQuadratic)
            ..animate.scaleX.to(1)
            ..animate.scaleY.to(1);
        };
    } else {
      // reset the bomb
      stage.juggler.addTween(bombSprite, 0.2, Transition.easeInOutQuadratic)
        ..animate.x.to(BOMB_X)
        ..animate.y.to(BOMB_Y)
        ..animate.scaleX.to(1)
        ..animate.scaleY.to(1);
    }
    bombSprite.stopDrag();
  }

}
