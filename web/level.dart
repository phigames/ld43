part of ld43;

class Level {

  final int FIELD_X = 1, FIELD_Y = 3;
  final int BOMB_X = 7, BOMB_Y = 11;

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
    
    // border
    sprite.graphics.beginPath();
    sprite.graphics.rect(FIELD_X - 1, FIELD_Y - 1, width + 2, 1); // top border
    sprite.graphics.rect(FIELD_X - 1, FIELD_Y + height, width + 2, 1); // bottom border
    sprite.graphics.rect(FIELD_X - 1, FIELD_Y, 1, height); // left border
    sprite.graphics.rect(FIELD_X + width, FIELD_Y, 1, height); // right border
    sprite.graphics.fillColor(Color.Blue);

    fieldSprite = new Sprite();
    // background
    fieldSprite.graphics.beginPath();
    fieldSprite.graphics.rect(0, 0, width, height);
    fieldSprite.graphics.fillColor(Color.White);
    // exit
    fieldSprite.graphics.beginPath();
    fieldSprite.graphics.rect(exitX, exitY, 1, 1);
    fieldSprite.graphics.fillColor(Color.Green);

    bombSprite = new Sprite();
    bombSprite.graphics.beginPath();
    bombSprite.graphics.circle(0.5, 0.5, 0.5);
    bombSprite.graphics.fillColor(Color.DarkGray);

    fieldSprite.x = FIELD_X;
    fieldSprite.y = FIELD_Y;
    sprite.addChild(fieldSprite);
    bombSprite.pivotX = bombSprite.pivotY = 0.5;
    bombSprite.x = BOMB_X;
    bombSprite.y = BOMB_Y;
    bombSprite.onMouseDown.listen((e) => _startBombDrag());
    bombSprite.onMouseUp.listen((e) => _stopBombDrag());
    sprite.addChild(bombSprite);
    stage.addChild(
      new TextField(tutorialText, new TextFormat('Share, sans-serif', 5, 0x000000, align: 'center', verticalAlign: 'bottom', leading: -3))
        ..width = 100
        ..height = 23
        ..x = 0
        ..y = 3
        ..wordWrap = true
    );
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
