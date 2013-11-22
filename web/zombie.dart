library zombie;

import 'dart:html';
import 'details.dart';

class Player extends Entity with KeyboardInput {
  int SPEED = 100;
  Player() : super("img/brain.png");
}

class Clown extends Entity with ZombieBrain {
  int SPEED = 1;
  Clown() : super("img/clown.png");
}

void main() {
  var textEl = querySelector("#text");
  var canvas = querySelector("#stage");
  
  var brain = new Player();
  var clown = new Clown();
  clown.target = brain;
  clown.x = 500;
  clown.y = 500;
  
  var game = new Game(canvas, [brain, clown]);
  game.ready.then((_) => textEl.text = "Game started!");
  game.onEnterFrame.listen((event) {
    if (brain.hitTestObject(clown)) {
      game.over();
    }
  });
}
