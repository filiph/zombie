library zombie_details;

import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'dart:async';

/**
 * The game object. Takes [Canvas] and a list of [Entity] instances.
 */
class Game {
  CanvasElement canvas;
  Stage stage;
  RenderLoop renderLoop;
  Iterable<Entity> entities;
  
  Game(this.canvas, this.entities) {
    stage = new Stage('myStage', canvas);
    canvas.focus();
    renderLoop = new RenderLoop();
    renderLoop.addStage(stage);
    entities.forEach((entity) => stage.addChild(entity));
    if (entities.isNotEmpty) {
      stage.focus = entities.first;
    }
    _onEnterFrame = stage.onEnterFrame;
  }
  
  void over() {
    entities.forEach((entity) => entity.removeFromParent());
    var textFormat = new TextFormat("Impact", 100, Color.Red,
        align: "center");
    var gameover = new TextField("GAME OVER", textFormat)
        ..y = canvas.height / 2
        ..width = canvas.width;
    stage.addChild(gameover);
  }
  
  EventStream<EnterFrameEvent> _onEnterFrame;
  EventStream<EnterFrameEvent> get onEnterFrame => _onEnterFrame;
  
  Future<bool> get ready => Future.wait(entities.map((entity) => entity.ready))
      .then((List<bool> doneList) => doneList.every((bool done) => done));
}


abstract class Entity extends DisplayObjectContainer {
  int SPEED = 10;

  Entity(String imgPath) {
    var completer = new Completer<bool>();
    ready = completer.future;
    
    BitmapData.load(imgPath).then((BitmapData bmpData) {
      _bitmap = new Bitmap(bmpData);
      pivotX = _bitmap.width / 2;
      pivotY = _bitmap.height / 2;
      addChild(_bitmap);
      completer.complete(true);
    });
    
    x = 200;
    y = 200;
    
    if (this is KeyboardInput) {
      onKeyDown.listen((this as KeyboardInput).wsadListener);
    }
    if (this is ZombieBrain) {
      onEnterFrame.listen((this as ZombieBrain).followTargetListener);
    }
  }

  Future<bool> ready;
  Bitmap _bitmap;
  
  moveLeft() {
    x -= SPEED;
    scaleX = -1.0;
  }
  
  moveRight() {
    x += SPEED;
    scaleX = 1.0;
  }
  
  moveUp() {
    y -= SPEED;
  }
  
  moveDown() {
    y += SPEED;
  }
}

class KeyboardInput {
  void wsadListener(var event) {
    assert(this is Entity);
    Entity entity = this as Entity;
    switch(event.keyCode) {
      case 87: // W
        entity.moveUp();
        break;
      case 83: // S
        entity.moveDown();
        break;
      case 65: // A
        entity.moveLeft();
        break;
      case 68: // D
        entity.moveRight();
        break;
      default:
        break;
    }
  }
}

class ZombieBrain {
  DisplayObject target;
  
  followTargetListener(EnterFrameEvent e) {
    assert(this is Entity);
    Entity entity = this as Entity;
    
    if (target != null) {
      if (target.x > entity.x) {
        entity.moveRight();
      } else if (target.x < entity.x) {
        entity.moveLeft();
      }
      if (target.y > entity.y) {
        entity.moveDown();
      } else if (target.y < entity.y) {
        entity.moveUp();
      }
    }
  }
}