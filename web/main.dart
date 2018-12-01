library ld43;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'level.dart';
part 'leveltemplate.dart';

Stage stage;

Future<Null> main() async {
  html.CanvasElement canvas = html.querySelector('#stage');
  stage = new Stage(
    canvas, width: 100, height: 100,
    options: new StageOptions()
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL
      ..inputEventMode = InputEventMode.MouseAndTouch
  );
  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  ResourceManager resourceManager = new ResourceManager();
  //resourceManager.addBitmapData("dart", "images/dart@1x.png");
  await resourceManager.load();
  Level level = LevelTemplate.LVL_TEST.parse();
  stage.addChild(level.sprite);
}
