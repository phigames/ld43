part of ld43;

enum Direction {
  horizontal,
  vertical
}

class Car {

  static final List<BitmapData> EXPLOSION_FRAMES = [
    resourceManager.getBitmapData('explosion0'),
    resourceManager.getBitmapData('explosion1'),
    resourceManager.getBitmapData('explosion2'),
    resourceManager.getBitmapData('explosion3'),
  ];

  Level _level;
  int x, y;
  Direction direction;
  int length;
  bool player;
  double _dragStart;
  Sprite sprite;

  Car(this._level, this.x, this.y, this.direction, this.length, this.player) {
    sprite = new Sprite()
      ..x = x
      ..y = y;
    String bitmapName;
    if (player) {
      bitmapName = 'car_player';
    } else {
      bitmapName = '${(length == 2 ? 'car' : 'truck')}' +
                   '_' +
                   '${(direction == Direction.horizontal ? 'h' : 'v')}' +
                   '${[1, 2][random.nextInt(2)]}';
    }
    sprite.addChild(
      new Bitmap(resourceManager.getBitmapData(bitmapName))
        ..width = getWidth()
        ..height = getHeight()
    );
    updateSprite();
    if (direction == Direction.horizontal) {
      sprite.onMouseDown.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
      sprite.onTouchBegin.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
      _level.fieldSprite.onMouseMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
      _level.fieldSprite.onTouchMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
    } else {
      sprite.onMouseDown.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
      sprite.onTouchBegin.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
      _level.fieldSprite.onMouseMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
      _level.fieldSprite.onTouchMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
    }
    stage.onMouseUp.listen((e) => stopDrag());
    stage.onTouchEnd.listen((e) => stopDrag());
    sprite.alpha = 0;
    stage.juggler.add(
      new Tween(sprite, 0.3)
        ..delay = random.nextDouble() * 0.5
        ..animate.alpha.to(1)
    );
  }

  Car.LD(this._level, this.x, this.y) {
    direction = Direction.horizontal;
    length = 4;
    player = false;
    sprite = new Sprite()
      ..x = x
      ..y = y;
    sprite.addChild(
      new Bitmap(resourceManager.getBitmapData('ld'))
        ..width = getWidth()
        ..height = getHeight()
    );
    updateSprite();
    if (direction == Direction.horizontal) {
      sprite.onMouseDown.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
      sprite.onTouchBegin.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
      _level.fieldSprite.onMouseMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
      _level.fieldSprite.onTouchMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).x));
    } else {
      sprite.onMouseDown.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
      sprite.onTouchBegin.listen((e) => startDrag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
      _level.fieldSprite.onMouseMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
      _level.fieldSprite.onTouchMove.listen((e) => drag(_level.fieldSprite.globalToLocal(Point(e.stageX, e.stageY)).y));
    }
    stage.onMouseUp.listen((e) => stopDrag());
    stage.onTouchEnd.listen((e) => stopDrag());
    sprite.alpha = 0;
    stage.juggler.add(
      new Tween(sprite, 0.3)
        ..delay = random.nextDouble() * 0.5
        ..animate.alpha.to(1)
    );
  }

  void updateSprite() {
    if (sprite.x != x || sprite.y != y) {
      animateMove(x, y);
    }
  }

  void move(int amount) {
    bool moved = false;
    if (direction == Direction.horizontal) {
      while (amount != 0 && !_level.isOccupied(x + (amount > 0 ? length - 1 : 0) + amount.sign, y)) {
        x += amount.sign;
        amount -= amount.sign;
        moved = true;
      }
    } else {
      while (amount != 0 && !_level.isOccupied(x, y + (amount > 0 ? length - 1 : 0) + amount.sign)) {
        y += amount.sign;
        amount -= amount.sign;
        moved = true;
      }
    }
    if (moved) {
      updateSprite();
      _level.checkWon(this);
      resourceManager.getSound('move').play();
    }
  }

  void animateMove(int targetX, int targetY) {
    stage.juggler.add(
      new Tween(sprite, 0.1, Transition.easeInOutQuadratic)
        ..animate.x.to(targetX)
        ..animate.y.to(targetY)
    );
  }

  void animateWon(void then()) {
    stage.juggler.add(
      new Tween(sprite, 0.5, Transition.easeInOutQuadratic)
        ..animate.x.by(5)
        ..animate.alpha.to(0)
        ..onComplete = then
    );
  }

  void animateExplode(void then()) {
    stage.juggler.add(
      new Tween(sprite, 0.5, Transition.easeInOutQuadratic)
        ..delay = 0.3
        ..animate.alpha.to(0)
        ..onComplete = then
    );
    for (int i = 0; i < 4; i++) {
      Bitmap frame = new Bitmap(EXPLOSION_FRAMES[i])
        ..pivotX = 120
        ..pivotY = 120
        ..x = getWidth() / 2
        ..y = getHeight() / 2
        ..width = 2
        ..height = 2
        ..alpha = 0;
      sprite.addChild(frame);
      stage.juggler.add(
        new Tween(frame, 0.1)
          ..delay = i * 0.1
          ..animate.alpha.to(1)
          ..onComplete = () {
            stage.juggler.add(
              new Tween(frame, i * 0.3, Transition.easeOutQuadratic)
                ..animate.alpha.to(0)
            );
          }
      );
    }
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

  void drag(double location) {
    if (_dragStart != null) {
      double distance = location - _dragStart;
      while (distance > 1) {
        move(1);
        _dragStart++;
        distance = location - _dragStart;
      }
      while (distance < -1) {
        move(-1);
        _dragStart--;
        distance = location - _dragStart;
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
