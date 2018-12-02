part of ld43;

class Level {

  static final int FIELD_X = 1, FIELD_Y = 3;
  static final int BOMB_X = 7, BOMB_Y = 11;

  int width, height;
  int exitX, exitY;
  List<Car> cars;
  String tutorialText;
  Function onWon, onLost;
  bool won;
  Sprite sprite, fieldSprite, bombSprite;

  Level.menu() {
    this.width = 6;
    this.height = 6;
    this.onWon = game.startLevel;
    this.onLost = game.startMenu;
    build();
    fieldSprite.addChild(
      new Bitmap(resourceManager.getBitmapData('start'))
        ..x = exitX - 2
        ..y = exitY
        ..width = 2
        ..height = 1
    );
    Car startCar = addCar(0, 2, Direction.horizontal, 2, true);
    Car ldCar = new Car.LD(this, 1, 4);
    cars.add(ldCar);
    ldCar.sprite.onMouseClick.listen((e) => html.window.open('https://ldjam.com/', '_blank'));
    ldCar.sprite.onTouchTap.listen((e) => html.window.open('https://ldjam.com/', '_blank'));
    fieldSprite.addChild(ldCar.sprite);
  }

  Level.end() {
    width = 6;
    height = 6;
    onWon = game.startLevel;
    onLost = game.startMenu;
    int destroyedNeeded = 9;
    if (game.destroyedCount > destroyedNeeded) {
      tutorialText = 'You killed ${game.destroyedCount - destroyedNeeded} more than needed. Shame on you.';
    } else {
      tutorialText = 'You killed no more than needed. Impressive!';
    }
    tutorialText += '\n\nThank you for playing!\nmusic by sophiakene\ncode & graphics by phi';
    build();
    Car ldCar = new Car.LD(this, 1, 4);
    cars.add(ldCar);
    ldCar.sprite.onMouseClick.listen((e) => html.window.open('https://ldjam.com/', '_blank'));
    ldCar.sprite.onTouchTap.listen((e) => html.window.open('https://ldjam.com/', '_blank'));
    fieldSprite.addChild(ldCar.sprite);
  }

  Level.empty(this.width, this.height, this.onWon, this.onLost, [this.tutorialText = '']) {
    build();
  }

  void build() {
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

  Car addCar(int x, int y, Direction direction, int length, [bool player = false]) {
    Car car = new Car(this, x, y, direction, length, player);
    cars.add(car);
    fieldSprite.addChild(car.sprite);
    return car;
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
      resourceManager.getSound('grenade').play();
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
