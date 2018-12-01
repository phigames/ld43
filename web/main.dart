library ld43;

import 'dart:async';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math';

part 'level.dart';

Future<Null> main() async {
  var canvas = html.querySelector('#stage');
  var stage = new Stage(
    canvas, width: 100, height: 100,
    options: new StageOptions()
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL
  );
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  var resourceManager = new ResourceManager();
  //resourceManager.addBitmapData("dart", "images/dart@1x.png");
  await resourceManager.load();
  Level level = new Level();
  stage.addChild(level.sprite);
}
