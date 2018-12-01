part of ld43;

class LevelTemplate {

  static const int START_HORIZONTAL = 60; // '<'
  static const int START_VERTICAL = 94; // '^'
  static const int MIDDLE = 46; // '.'
  static const int END_PLAYER = 36; // '$'
  static const int END_OTHER = 35; // '#'
  //static const int EMPTY = 32; // ' '

  static final LevelTemplate LVL_TEST = new LevelTemplate(
    r'  ^  ' +
    r'  #  ' +
    r'<$   ' +
    r' <#  ' +
    r'     ',
    5, 5
  );
  static final LevelTemplate LVL_RH1 = new LevelTemplate(
    r'<#   ^' +
    r'^  ^ .' +
    r'.<$. #' +
    r'#  #  ' +
    r'^   <#' +
    r'# <.# ',
    6, 6
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
          int length = _parseHorizontalCarLength(i);
          level.addCar(x, y, Direction.horizontal, length.abs(), length < 0);
          break;
        case START_VERTICAL:
          int length = _parseVerticalCarLength(i);
          level.addCar(x, y, Direction.vertical, length.abs(), length < 0);
          break;
      }
    }
    return level;
  }

  int _parseHorizontalCarLength(int startIndex) {
    int length = 1;
    int i = startIndex;
    int char;
    while (char != END_PLAYER && char != END_OTHER) {
      length++;
      i++;
      char = code.runes.elementAt(i);
      if (char != MIDDLE && char != END_PLAYER && char != END_OTHER) {
        throw('car parse error: unexpected rune ${char} at (${i % width}, ${i ~/ width})');
      }
    }
    return length * (char == END_PLAYER ? -1 : 1); // negative if player, positive otherwise
  }

  int _parseVerticalCarLength(int startIndex) {
    int length = 1;
    int i = startIndex;
    int char;
    while (char != END_PLAYER && char != END_OTHER) {
      length++;
      i += width;
      char = code.runes.elementAt(i);
      if (char != MIDDLE && char != END_PLAYER && char != END_OTHER) {
        throw('car parse error: unexpected rune ${char} at (${i % width}, ${i ~/ width})');
      }
    }
    return length * (char == END_PLAYER ? -1 : 1); // negative if player, positive otherwise
  }

}