part of ld43;

class Level {

  int width, height;
  int exitX, exitY;
  List<Car> cars;
  Sprite sprite, fieldSprite;

  Level.test() {
    width = 10;
    height = 10;
    exitX = width;
    exitY = (height - 1) ~/ 2;
    cars = new List<Car>()
      ..add(new Car(this, 1, 0, Direction.vertical, 3, false))
      ..add(new Car(this, 3, 3, Direction.horizontal, 2, true));
    sprite = new Sprite()
      ..scaleX = 100 / (width + 2)
      ..scaleY = 100 / (height + 2);
    for (Car car in cars) {
      sprite.addChild(car.sprite);
    }
    sprite.graphics.rect(0, 0, width + 2, 1); // top border
    sprite.graphics.rect(0, height + 1, width + 2, 1); // bottom border
    sprite.graphics.rect(0, 1, 1, height); // left border
    sprite.graphics.rect(width + 1, 1, 1, height); // right border
    sprite.graphics.fillColor(Color.Blue);
    sprite.graphics.rect(exitX, exitY, 1, 1);
    sprite.graphics.fillColor(Color.Green);
  }

  Level.empty(this.width, this.height) {
    exitX = width;
    exitY = (height - 1) ~/ 2;
    cars = new List<Car>();
    sprite = new Sprite()
      ..scaleX = 100 / (width + 2)
      ..scaleY = 100 / (height + 2);
    sprite.graphics.beginPath();
    sprite.graphics.rect(0, 0, width + 2, 1); // top border
    sprite.graphics.rect(0, height + 1, width + 2, 1); // bottom border
    sprite.graphics.rect(0, 1, 1, height); // left border
    sprite.graphics.rect(width + 1, 1, 1, height); // right border
    sprite.graphics.fillColor(Color.Blue);
    sprite.graphics.beginPath();
    fieldSprite = new Sprite();
    fieldSprite.graphics.rect(exitX, exitY, 1, 1);
    fieldSprite.graphics.fillColor(Color.Green);
    fieldSprite.x = fieldSprite.y = 1;
    sprite.addChild(fieldSprite);
  }

  void addCar(int x, int y, Direction direction, int length, [bool player = false]) {
    Car car = new Car(this, x, y, direction, length, player);
    cars.add(car);
    fieldSprite.addChild(car.sprite);
  }

  bool isOccupied(int x, int y) {
    if ((x != exitX && y != exitY) && (x < 0 || x >= width || y < 0 || y >= height)) {
      return true;
    }
    for (Car car in cars) {
      if (car.occupies(x, y)) {
        return true;
      }
    }
    return false;
  }

  void checkWon(Car car) {
    if (car.occupies(exitX, exitY)) {
      car.animateWon();
    }
  }

}

class Car {

  Level _level;
  int x, y;
  Direction direction;
  int length;
  bool player;
  double _dragStart;
  Sprite sprite;

  Car(this._level, this.x, this.y, this.direction, this.length, this.player) {
    sprite = new Sprite()
      ..graphics.rect(0, 0, getWidth(), getHeight())
      ..graphics.fillColor(player ? Color.Red : Color.Gray);
    updateSprite();
    if (direction == Direction.horizontal) {
      sprite.onMouseDown.listen((e) => startDrag(e.localX));
      sprite.onTouchBegin.listen((e) => startDrag(e.localX));
      sprite.onMouseMove.listen((e) => drag(e.localX));
      sprite.onTouchMove.listen((e) => drag(e.localX));
      sprite.onMouseOut.listen((e) => drag(e.localX, true));
      sprite.onTouchOut.listen((e) => drag(e.localX, true));
    } else {
      sprite.onMouseDown.listen((e) => startDrag(e.localY));
      sprite.onTouchBegin.listen((e) => startDrag(e.localY));
      sprite.onMouseMove.listen((e) => drag(e.localY));
      sprite.onTouchMove.listen((e) => drag(e.localY));
      sprite.onMouseOut.listen((e) => drag(e.localY, true));
      sprite.onTouchOut.listen((e) => drag(e.localY, true));
    }
    sprite.onMouseUp.listen((e) => stopDrag());
    sprite.onTouchEnd.listen((e) => stopDrag());
  }

  void updateSprite() {
    sprite.x = x;
    sprite.y = y;
  }

  void move(int amount) {
    // int correctedAmount = amount;
    if (direction == Direction.horizontal) {
      // correctedAmount = amount < 0 ? max(amount, -x) : min(amount, _level.width - (x + length));
      // x += correctedAmount;
      while (amount != 0 && !_level.isOccupied(x + (amount > 0 ? length - 1 : 0) + amount.sign, y)) {
        x += amount.sign;
        amount -= amount.sign;
      }
    } else {
      // correctedAmount = amount < 0 ? max(amount, -y) : min(amount, _level.height - (y + length));
      // y += correctedAmount;
      while (amount != 0 && !_level.isOccupied(x, y + (amount > 0 ? length - 1 : 0) + amount.sign)) {
        y += amount.sign;
        amount -= amount.sign;
      }
    }
    updateSprite();
    _level.checkWon(this);
  }

  void animateWon() {
    stage.juggler.add(
      new Tween(sprite, 0.5, Transition.easeInOutQuadratic)
        ..animate.x.by(5)
        ..animate.alpha.to(0)
    );
  }

  bool occupies(int x, int y) {
    if (direction == Direction.horizontal) {
      return y == this.y && x >= this.x && x < this.x + this.length;
    } else {
      return x == this.x && y >= this.y && y < this.y + this.length;
    }
  }

  void startDrag(double location) {
    _dragStart = location;
  }

  void stopDrag() {
    _dragStart = null;
  }

  void drag(double location, [bool out = false]) {
    if (_dragStart != null) {
      // TODO stop drag when out on wrong side
      if (out) {
        if (location > _dragStart) move(1);
        else if (location < _dragStart) move(-1);
        else stopDrag();
      } else {
        // double distance = location - _dragStart;
        // print(distance);
        // while (distance > 1) {
        //   move(1);
        //   _dragStart++;
        //   distance = location - _dragStart;
        // }
        // while (distance < -1) {
        //   move(-1);
        //   _dragStart--;
        //   distance = location - _dragStart;
        // }
      }
    }
  }

  int getWidth() {
    switch (direction) {
      case Direction.horizontal:
        return length;
      case Direction.vertical:
        return 1;
    }
  }

  int getHeight() {
    switch (direction) {
      case Direction.horizontal:
        return 1;
      case Direction.vertical:
        return length;
    }
  }

}

enum Direction {
  horizontal,
  vertical
}