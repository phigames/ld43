part of ld43;

class LevelTemplate {

  static const int START_HORIZONTAL = 60; // '<'
  static const int START_VERTICAL = 94; // '^'
  static const int MIDDLE = 46; // '.'
  static const int END = 35; // '#'
  //static const int EMPTY = 32; // ' '

  static final LevelTemplate LVL_TEST = new LevelTemplate(
    '  ^  ' +
    '  .  ' +
    '  #  ' +
    '<..# ' +
    '     ',
    5, 5
  );

  String code;
  int width, height;

  LevelTemplate(this.code, this.width, this.height);

  Level parse() {
    if (code.length != width * height) {
      throw('level parse error: level code has wrong length');
    }
    Level level = new Level.empty(width, height);
    for (int i = 0; i < code.runes.length; i++) {
      int x = i % width;
      int y = i ~/ width;
      switch (code.runes.elementAt(i)) {
        case START_HORIZONTAL:
          level.addCar(x, y, Direction.horizontal, _parseHorizontalCarLength(i));
          break;
        case START_VERTICAL:
          level.addCar(x, y, Direction.vertical, _parseVerticalCarLength(i));
          break;
      }
    }
    return level;
  }

  int _parseHorizontalCarLength(int startIndex) {
    int length = 1;
    int i = startIndex;
    int char;
    while (char != END) {
      length++;
      i++;
      char = code.runes.elementAt(i);
      if (char != MIDDLE && char != END) {
        throw('car parse error: unexpected rune ${char} at (${i % width}, ${i ~/ width})');
      }
    }
    return length;
  }

  int _parseVerticalCarLength(int startIndex) {
    int length = 1;
    int i = startIndex;
    int char;
    while (char != END) {
      length++;
      i += width;
      char = code.runes.elementAt(i);
      if (char != MIDDLE && char != END) {
        throw('car parse error: unexpected rune ${char} at (${i % width}, ${i ~/ width})');
      }
    }
    return length;
  }

}