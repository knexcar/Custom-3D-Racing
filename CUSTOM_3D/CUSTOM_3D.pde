//import ddf.minim.spi.*;
//import ddf.minim.signals.*;
import ddf.minim.*;
import java.util.Collections;
//import ddf.minim.analysis.*;
//import ddf.minim.ugens.*;
//import ddf.minim.effects.*;

/* Final Code Assignment "3D Racing"

Use the menu to select whather to race or to edit a level.
RACE MODE:
 Player 1 (who is red and on the left) controls using the arrow keys.
 Player 2 (who is green and on the right) controls using the wasd keys.
 The goal is to complete three laps as quickly as possible. 
 Note that you must be moving to turn (unless you are stuck on a hill). Don't turn too fast, or your car will spin out.
EDIT MODE:
 Use the arrow keys to move the view.
 Click a tile to delete it.
 Use the "Longer" and "Shorter" buttons to increase the length of straight tiles.
  These buttons can also increase the size of the curved road segments.
 Use the "Save" or "Save as" button to save your level, and the "Load" button to load a saved level.
  There are no warnings when overwriting a level.

*/

Screen screen_in_control;
J3D j3d_obj;
Minim minim_obj;
float change_in_time;//Used to prevent car slowdown when there is lag.
Level level_var;
Car[] cars;
PFont title_font;
PFont main_font;
AudioPlayer music;
AudioSample[] sound_fx;

void setup() {
  size(1280,720);
  //frame.setResizable(true);
  j3d_obj = new J3D();
  minim_obj = new Minim(this);
  screen_in_control = new Start_screen();
  level_var = new Level(15,15);
  level_var.music_numb = 1;
  
  music = minim_obj.loadFile("music/song_0.mp3");
  music.loop();
  sound_fx = new AudioSample[2];
  for (int i=0; i<sound_fx.length; i++) {
    sound_fx[i] = minim_obj.loadSample("sounds/sound_"+i+".mp3");
  }
  
  //println(PFont.list());
  title_font = createFont("Comic Sans MS",64,false);
  main_font = createFont("Times New Roman",16,false);
  
  
  int offsetx = 0; int offsetz = 0;
  /*for (int i=0; i<15; i++) {//Debug code to create a level with only squares, for draw purposes.
    for (int j=0; j<15; j++) {
      level_var.terrain_in_level[i][j] = new Mud_pit(i,j,1,0,0);
    }
  }
  level_var.finish_line_var = new Finish_line(offsetx+4,offsetz+2,1,0,0);*/
  new Road_straight(offsetx+3,offsetz+1,2,HALF_PI,0).place_in_level(level_var);
  new Road_straight(offsetx+4,offsetz+3,5,0,0).place_in_level(level_var);
  new Road_straight(offsetx+3,offsetz+8,2,HALF_PI,0).place_in_level(level_var);
  new Road_straight(offsetx+1,offsetz+2,1,0,0).place_in_level(level_var);
  new Road_straight(offsetx+2,offsetz+4,2,0,0).place_in_level(level_var);
  new Road_straight(offsetx+1,offsetz+7,1,0,0).place_in_level(level_var);
  new Road_curved(offsetx+4,offsetz+8,1,0,0).place_in_level(level_var);
  new Road_curved(offsetx+1,offsetz+8,1,HALF_PI,0).place_in_level(level_var);
  new Road_curved(offsetx+1,offsetz+6,1,PI,0).place_in_level(level_var);
  new Road_curved(offsetx+2,offsetz+6,1,0,0).place_in_level(level_var);
  new Road_curved(offsetx+2,offsetz+3,1,HALF_PI+PI,0).place_in_level(level_var);
  new Road_curved(offsetx+1,offsetz+3,1,HALF_PI,0).place_in_level(level_var);
  new Road_curved(offsetx+1,offsetz+1,1,PI,0).place_in_level(level_var);
  new Road_curved(offsetx+4,offsetz+1,1,HALF_PI+PI,0).place_in_level(level_var);
  level_var.finish_line_var = new Finish_line(offsetx+4,offsetz+2,1,0,0);
  level_var.finish_line_var.place_in_level(level_var);
  new Mud_pit(offsetx+1,offsetz+4,2,0,0).place_in_level(level_var);
  new Hill_straight(offsetx+3,offsetz+3,4,0,0).place_in_level(level_var);
  new Hill_corner(offsetx+3,offsetz+7,1,0,0).place_in_level(level_var);
  new Hill_corner(offsetx+3,offsetz+2,1,PI+HALF_PI,0).place_in_level(level_var);
  new Hill_end(offsetx+2,offsetz+7,1,HALF_PI,0).place_in_level(level_var);
  new Hill_end(offsetx+2,offsetz+2,1,HALF_PI,0).place_in_level(level_var);
}

void draw() {
  change_in_time = 60/frameRate;
  screen_in_control.update_and_draw();
}

void keyPressed() {
  if (key == CODED) {//Look at first player's stuff
    if (keyCode == LEFT) {
      screen_in_control.keyPressed(0,1);
    } else if (keyCode == RIGHT) {
      screen_in_control.keyPressed(0,2);
    } else if (keyCode == UP) {
      screen_in_control.keyPressed(0,3);
    } else if (keyCode == DOWN) {
      screen_in_control.keyPressed(0,4);
    }
  } else {//If there is multiplayer
    if (key == 'a') {
      screen_in_control.keyPressed(1,1);
    } else if (key == 'd') {
      screen_in_control.keyPressed(1,2);
    } else if (key == 'w') {
      screen_in_control.keyPressed(1,3);
    } else if (key == 's') {
      screen_in_control.keyPressed(1,4);
    } else if (key == 'k') {
      screen_in_control.keyPressed(2,1);
    } else if (key == ';') {
      screen_in_control.keyPressed(2,2);
    } else if (key == 'o') {
      screen_in_control.keyPressed(2,3);
    } else if (key == 'l') {
      screen_in_control.keyPressed(2,4);
    } else if (key == '4') {
      screen_in_control.keyPressed(3,1);
    } else if (key == '6') {
      screen_in_control.keyPressed(3,2);
    } else if (key == '8') {
      screen_in_control.keyPressed(3,3);
    } else if (key == '5') {
      screen_in_control.keyPressed(3,4);
    } else {
      screen_in_control.keyPressed(0,0);
    }
  }
}

void keyReleased() {
  if (key == CODED) {//Look at first player's stuff
    if (keyCode == LEFT) {
      screen_in_control.keyReleased(0,1);
    } else if (keyCode == RIGHT) {
      screen_in_control.keyReleased(0,2);
    } else if (keyCode == UP) {
      screen_in_control.keyReleased(0,3);
    } else if (keyCode == DOWN) {
      screen_in_control.keyReleased(0,4);
    }
  } else {//If there is multiplayer
    if (key == 'a') {
      screen_in_control.keyReleased(1,1);
    } else if (key == 'd') {
      screen_in_control.keyReleased(1,2);
    } else if (key == 'w') {
      screen_in_control.keyReleased(1,3);
    } else if (key == 's') {
      screen_in_control.keyReleased(1,4);
    } else if (key == 'k') {
      screen_in_control.keyReleased(2,1);
    } else if (key == ';') {
      screen_in_control.keyReleased(2,2);
    } else if (key == 'o') {
      screen_in_control.keyReleased(2,3);
    } else if (key == 'l') {
      screen_in_control.keyReleased(2,4);
    } else if (key == '4') {
      screen_in_control.keyReleased(3,1);
    } else if (key == '6') {
      screen_in_control.keyReleased(3,2);
    } else if (key == '8') {
      screen_in_control.keyReleased(3,3);
    } else if (key == '5') {
      screen_in_control.keyReleased(3,4);
    } else {
      screen_in_control.keyReleased(0,0);
    }
  }
}

void mousePressed() {
  screen_in_control.mousePressed();
}