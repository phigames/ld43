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
Game game;

Future<Null> main() async {
  html.CanvasElement canvas = html.querySelector('#stage');
  stage = new Stage(
    canvas, width: 100, height: 150,
    options: new StageOptions()
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL
      ..inputEventMode = InputEventMode.MouseAndTouch
  );
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  ResourceManager resourceManager = new ResourceManager();
  await resourceManager.load();
  game = new Game();
}
