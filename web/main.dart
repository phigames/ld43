library ld43;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'game.dart';
part 'level.dart';
part 'leveltemplate.dart';
part 'car.dart';

Stage stage;
ResourceManager resourceManager;
Random random;
Game game;

Future<Null> main() async {
  html.CanvasElement canvas = html.querySelector('#stage');
  stage = new Stage(
    canvas, width: 100, height: 150,
    options: new StageOptions()
      ..backgroundColor = 0xFFCCCCCC
      ..renderEngine = RenderEngine.WebGL
      ..inputEventMode = InputEventMode.MouseAndTouch
  );
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  resourceManager = new ResourceManager();
  resourceManager.addBitmapData('car_player', 'res/images/car_player.png');
  for (String s1 in ['car', 'truck']) {
    for (String s2 in ['h', 'v']) {
      for (int s3 in [1, 2]) {
        resourceManager.addBitmapData('${s1}_${s2}${s3}', 'res/images/${s1}_${s2}${s3}.png');
      }
    }
  }
  resourceManager.addBitmapData('grenade', 'res/images/grenade.png');
  resourceManager.addBitmapData('border', 'res/images/border.png');
  resourceManager.addBitmapData('exit', 'res/images/exit.png');
  await resourceManager.load();
  random = new Random();
  game = new Game();
}
