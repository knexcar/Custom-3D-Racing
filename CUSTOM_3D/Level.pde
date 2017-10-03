//"Level" file
class Level extends Screen {
  Terrain_obj[][] terrain_in_level;
  Finish_line finish_line_var;
  Race_overlay[] race_overlay_var;
  int level_width;
  int level_height;
  int player_numb;
  int winner_numb;//0 = no winner, -1 = before the start.
  int next_place;//1 = no one has one, 2 = one winner, ect.
  
  int music_numb;
  int style;
  
  float timer;
  float[] winning_time;
  float auxillary_timer;//If winner_numb==-1 it is the timer to start the cars.
  String name;
  String file_path;
  //if winner_numb==0 it is the time before removing "GO" from the screen.
  //If winner_numb>1 it is the time before automatically exiting.
  
  Level(int level_width_, int level_height_) {
    level_width = level_width_;
    level_height = level_height_;
    player_numb = 0;
    terrain_in_level = new Terrain_obj[level_width][level_height];
    timer = -1;
    auxillary_timer = -1;
    style = 1;
    name = "Level";
    file_path = "";
  }
  
  void update_and_draw() {
    update();
    draw_only();
  }
  
  void keyPressed(int playern, int buttonn) {
    playern = playern%player_numb;
    if (playern < player_numb) {
      if (buttonn == 1) {
        cars[playern].turnpower = 1;
      } else if (buttonn == 2) {
        cars[playern].turnpower = -1;
      } else if (buttonn == 3) {
        cars[playern].accelpower = 1;
      } else if (buttonn == 4) {
        cars[playern].accelpower = -1;
      }
    }
  }
  
  void keyReleased(int playern, int buttonn) {
    playern = playern%player_numb;
    if (playern < player_numb) {
      if (buttonn == 1) {
        if (cars[playern].turnpower > 0) {
          cars[playern].turnpower = 0;
        }
      } else if (buttonn == 2) {
        if (cars[playern].turnpower < 0) {
          cars[playern].turnpower = 0;
        }
      } else if (buttonn == 3) {
        if (cars[playern].accelpower > 0) {
          cars[playern].accelpower = 0;
        }
      } else if (buttonn == 4) {
        if (cars[playern].accelpower < 0) {
          cars[playern].accelpower = 0;
        }
      }
    }
  }
  
  void mousePressed() {
    if (race_overlay_var != null) {
      for (int i=0; i<race_overlay_var.length; i++) {
        if (race_overlay_var[i].return_to_menu.mouse_over) {
          reset_for_not_racing();
          return;
        }
      }
    }
  }
  
  void update() {
    //Update cars and terrain
    for (int i = 0; i < cars.length; i = i+1) {
      //Style 1 = dirt, 2 = grass, 3 = snow, 4 = water, 5 = sunset, 6 = night, 7 = sky, 8 = bowser, 9 = rainbow road
      cars[i].update();
      if (style == 3) {//Snow style
        cars[i].left_friction = 0.05;
        cars[i].right_friction = 0.05;
        cars[i].ground_height = 100;
      } else if (style == 4) {//Water style
        cars[i].left_friction = 0.03;
        cars[i].right_friction = 0.03;
        cars[i].ground_height = 10000;
      } else if (style == 7) {//Sky style
        cars[i].left_friction = 0.03;
        cars[i].right_friction = 0.03;
        cars[i].ground_height = 10000;
      } else if (style == 9) {//Rainbow Road style
        cars[i].left_friction = 0.03;
        cars[i].right_friction = 0.03;
        cars[i].ground_height = 10000;
      } else {//All others
        cars[i].left_friction = 0.03;
        cars[i].right_friction = 0.03;
        cars[i].ground_height = 100;
      }
    }
    for (int i = 0; i < level_width; i = i+1) {
      for (int j = 0; j < level_height; j = j+1) {
        if (terrain_in_level[i][j] != null) {
          terrain_in_level[i][j].update();
        }
      }
    }
    
    //Update the race timer and before race things.
    if (winner_numb >= 0) {
      timer += change_in_time/60;
    }
    if (auxillary_timer != -1) {
      auxillary_timer -= change_in_time/60;
      
      if (winner_numb == -1) {//If it is before the race
        for (int i=0; i<race_overlay_var.length; i++) {
          race_overlay_var[i].center_text =  str(int(auxillary_timer)+1);
          race_overlay_var[i].center_text_size = (1-auxillary_timer%1)*48;
        }
        if (auxillary_timer <= 0) {//If the timer "rings"...
          go();//GO!
        }
      }
      if (winner_numb == 0) {//If it is during the race
        if (auxillary_timer > 1) {//Only make it expand in the first second.
          for (int i=0; i<race_overlay_var.length; i++) {
            race_overlay_var[i].center_text_size = (2-auxillary_timer)*48;
          }
        }
        if (auxillary_timer <= 0) {//If the timer "rings"...
          auxillary_timer = -1;
          for (int i=0; i<race_overlay_var.length; i++) {
            race_overlay_var[i].center_text = "";
            race_overlay_var[i].display_center_text = false;
          }
        }
      }
    }
    for (int i=0; i<race_overlay_var.length; i++) {
      race_overlay_var[i].update();
    }
  }
  
  void draw_only() {
    if (player_numb == 0) {
      j3d_obj.window_xsize = width;
      j3d_obj.window_xoffset = 0;
      j3d_obj.window_ysize = height;
      j3d_obj.window_yoffset = 0;
      imageMode(CORNER);
      clip(j3d_obj.window_xoffset,j3d_obj.window_yoffset,j3d_obj.window_xsize,j3d_obj.window_ysize);
      j3d_obj.reset_transforms();
      draw_terrain_pass();
    } else {
      noClip();
      background(0);
      if (cars.length > 2) {//IF there are 3+ cars, stack them in 2 columns.
        j3d_obj.window_xsize = width/ceil(float(cars.length)/2);
        j3d_obj.window_ysize = height/2;
      } else {
        j3d_obj.window_xsize = width/cars.length;
        j3d_obj.window_ysize = height;
      }
      for (int i = cars.length-1; i >= 0; i = i-1) {
        j3d_obj.reset_transforms();
        //println(ceil(float(cars.length)/2));
        if (cars.length > 2 && 2*i+1 > cars.length) {
          j3d_obj.window_xoffset = j3d_obj.window_xsize*(((i)%ceil(float(cars.length)/2))+0);
          j3d_obj.window_yoffset = j3d_obj.window_ysize;
        } else {
          j3d_obj.window_xoffset = j3d_obj.window_xsize*i;
          j3d_obj.window_yoffset = 0;
        }
        imageMode(CORNER);
        clip(j3d_obj.window_xoffset,j3d_obj.window_yoffset,j3d_obj.window_xsize,j3d_obj.window_ysize);
        cars[i].update_camera();
        draw_terrain_pass();
        for (int j = 0; j < cars.length; j = j+1) {
          cars[j].draw_only();
        }
        noClip();
        if (race_overlay_var != null) {
          if (winning_time[i] < 0.5) {
            race_overlay_var[i].draw_only(timer);
          } else {
            race_overlay_var[i].draw_only(winning_time[i]);
          }
        }
      }
    }
  }
  
  void draw_terrain_pass() {//Done once for each player...
    for (int i = 0; i < level_width; i = i+1) {//Set the "has-been-drawn" var to false.
      for (int j = 0; j < level_height; j = j+1) {
        if (terrain_in_level[i][j] != null) {
          terrain_in_level[i][j].has_been_drawn = false;
        }
      }
    }
    
    //Draw the background based on the style
    noStroke();
    if (style == 2) {//Style 2 = grass
      draw_background(#50AA4A, #00FFFF);
    } else if (style == 3) {//Style 3 = snow
      draw_background(#C0D6DB, #66FFFF);
    } else if (style == 4) {//Style 4 = water
      draw_background(#0033FF, #00FFFF);
    } else if (style == 5) {//Style 5 = sunset
      draw_background(#FFD276, #B4693E);
    } else if (style == 6) {//Style 6 = night
      draw_background(#7F693B, #000033);
    } else if (style == 7) {//Style 7 = sky
      draw_background(#00FFFF, #00FFFF);
    } else if (style == 8) {//Style 8 = bowser
      draw_background(#888888, #444444);
    } else if (style == 9) {//Style 9 = rainbow road
      draw_background(#000033, #000033);
    } else {//Style 1 = dirt
      draw_background(#FFD276, #00FFFF);
    }
    
    //This function works by going...
    int origin_x = int(j3d_obj.camera.x/300);
    int origin_z = int(j3d_obj.camera.z/300);
    //print(origin_x); print(","); println(origin_z);
    //Radius used to become the largest distance from the origin to the border.
    int radius = level_width-origin_x;
    if (level_height-origin_z > radius) {radius = level_height-origin_z;}
    if (origin_x > radius) {radius = origin_x;}
    if (origin_z > radius) {radius = origin_z;}
    //These variables are absolute.
    int current_x = origin_x-radius;//Start at the left/top
    int current_z = origin_z-radius;
    int status = 0;//0=top-down, 1=bottom-up, 2=left-right, 3=right-left
    boolean on_right = false;
    
    for (; radius != 0;) {
      //Draw the current tile
      if (current_x >= 0 && current_x < level_width && current_z >= 0 && current_z < level_height) {
        if (terrain_in_level[current_x][current_z] != null) {
          if (terrain_in_level[current_x][current_z].has_been_drawn == false) {
            terrain_in_level[current_x][current_z].draw_only();
            terrain_in_level[current_x][current_z].has_been_drawn = true;
          }
        }
      }
      //println("("+current_x+","+current_z+") - "+radius+", Dir: "+status+", "+on_right);
      
      //Top-down
      if (status == 0) {
        current_z += 1;
        if (current_z == origin_z+1) {//If it is past the center
          if (on_right) {//If it is on the right
            status = 1;//Go to the next status...
            current_x = origin_x-radius; current_z = origin_z+radius;//Left/Bottom
          } else {//If it is on the left...
            current_x = origin_x+radius; current_z = origin_z-radius;//Right/top
          }
          on_right = !on_right;//Change sides
        }
      //Bottom-up
      } else if (status == 1) {
        current_z -= 1;
        if (current_z == origin_z) {//If it is at the center
          if (on_right) {//If it is on the right
            status = 2;//Go to the next status...
            current_x = origin_x-radius; current_z = origin_z-radius;//Left/Top
          } else {//If it is on the left...
            current_x = origin_x+radius; current_z = origin_z+radius;//Right/Bottom
          }
          on_right = !on_right;//Change sides
        }
      //Left-right
      } else if (status == 2) {
        current_x += 1;
        if (current_x == origin_x+1) {//If it is past the center
          if (on_right) {//If it is on the bottom
            status = 3;//Go to the next status...
            current_x = origin_x+radius; current_z = origin_z-radius;//Right/Top
          } else {//If it is on the top...
            //Go to bottom.
            current_x = origin_x-radius; current_z = origin_z+radius;//Left/Bottom
          }
          on_right = !on_right;//Change sides
        }
      //Right-left
      } else if (status == 3) {
        current_x -= 1;
        if (current_x == origin_x) {//If it is at the center
          if (on_right) {//If it is on the bottom
            radius -= 1;//Decrease the radius
            status = 0;//Loop to the first status...
            current_x = origin_x-radius; current_z = origin_z-radius;//Left/Top
          } else {//If it is on the top...
            //Go to bottom
            current_x = origin_x+radius; current_z = origin_z+radius;//Right/Bottom
          }
          on_right = !on_right;//Change sides
        }
      }
    }
    if (origin_x >= 0 && origin_x < level_width) {
      if (origin_z >= 0 && origin_z < level_height) {
        if (terrain_in_level[origin_x][origin_z] != null) {
          if (terrain_in_level[origin_x][origin_z].has_been_drawn == false) {
            terrain_in_level[origin_x][origin_z].draw_only();
            terrain_in_level[origin_x][origin_z].has_been_drawn = true;
          }
        }
      }
    }
  }
  
  //Used to draw the backgound in a vartiey of colors
  void draw_background(color color1, color color2) {
    fill(color1);
    rect(j3d_obj.window_xoffset,j3d_obj.window_yoffset,j3d_obj.window_xsize,j3d_obj.window_ysize);
    fill(color2);
    rect(j3d_obj.window_xoffset,j3d_obj.window_yoffset,j3d_obj.window_xsize,j3d_obj.window_ysize/2-j3d_obj.window_ysize*sin(j3d_obj.camera_rotate_x)/2);
  }
  
  
  void prepare_for_racing() {
    player_numb = cars.length;
    winner_numb = -1;
    next_place = 1;
    timer = 0;
    winning_time = new float[player_numb];
    for (int i=0; i<winning_time.length; i++) {
      winning_time[i] = 0;
    }
    auxillary_timer = 3;
    race_overlay_var = new Race_overlay[player_numb];
    float temp_xsize; float temp_ysize;
    float temp_xoff; float temp_yoff;
    if (player_numb > 2) {//IF there are 3+ cars, stack them in 2 columns.
      temp_xsize = 1/float(ceil(float(cars.length)/2));
      temp_ysize = 1.0/2.0;
    } else {
      temp_xsize = 1.0/float(cars.length);
      temp_ysize = 1;
    }
    for (int i=0; i<player_numb; i++) {
      j3d_obj.reset_transforms();
      if (player_numb > 2 && 2*i+1 > player_numb) {
        temp_xoff = temp_xsize*float(((i)%ceil(float(cars.length)/2))+0);
        temp_yoff = temp_ysize;
      } else {
        temp_xoff = temp_xsize*i;
        temp_yoff = 0;
      }
      race_overlay_var[i] = new Race_overlay("3",temp_xoff,temp_xsize,temp_yoff,temp_ysize);
    }
    finish_line_var.prepare_cars();
    j3d_obj.camera_rotate_x = 0;
    for (int i=0; i<race_overlay_var.length; i++) {
      race_overlay_var[i].display_center_text = true;
      if (style == 9 || style == 6) {
        race_overlay_var[i].colors[0] = color(255);
      }
    }
    music.close();
    music = minim_obj.loadFile("music/song_"+music_numb+".mp3");
    sound_fx[0].trigger();
  }
  
  
  void go() {//Called on "go".
    for (int i = 0; i < cars.length; i = i+1) {
      cars[i].can_move = true;
    }
    auxillary_timer = 2;
    for (int i=0; i<race_overlay_var.length; i++) {
      race_overlay_var[i].center_text = "GO!";
      race_overlay_var[i].center_text_size = 0;
      race_overlay_var[i].display_score = true;
    }
    winner_numb = 0;
    music.loop();
  }
  
  
  void win(int win_numb_temp) {
    if (winning_time[win_numb_temp] != 0) return;//Prevent it from going twice.
    if (winner_numb == 0) {
      winner_numb = win_numb_temp+1;
    }
    music.pause();
    sound_fx[1].trigger();
    race_overlay_var[win_numb_temp].display_center_text = true;
    race_overlay_var[win_numb_temp].display_win_overlay = true;
    winning_time[win_numb_temp] = timer;
    if (next_place == 1) {
      race_overlay_var[win_numb_temp].center_text = "1st Place";
    } else if (next_place == 2) {
      race_overlay_var[win_numb_temp].center_text = "2nd Place";
    } else if (next_place == 3) {
      race_overlay_var[win_numb_temp].center_text = "3rd Place";
    } else if (next_place == 4) {
      race_overlay_var[win_numb_temp].center_text = "4th Place";
    } else {
      race_overlay_var[win_numb_temp].center_text = next_place+"th Place";
    }
    race_overlay_var[win_numb_temp].return_to_menu = new Button(race_overlay_var[win_numb_temp].x_pos/width,(race_overlay_var[win_numb_temp].y_pos)/height+0.5*race_overlay_var[win_numb_temp].y_size/height,
      0.7*race_overlay_var[win_numb_temp].x_size/width,0.08*race_overlay_var[win_numb_temp].y_size/height,"Return to Menu");
    //race_overlay_var[i].return_to_menu = new Menu_button(0.7,"Return to Menu");
    next_place += 1;
  }
  
  
  void reset_for_not_racing() {
    timer = -1;
    cars = null;
    j3d_obj.window_xsize = width;
    player_numb = 0;
    winner_numb = -1;
    race_overlay_var = null;
    screen_in_control = new Main_menu();
    music.close();
    music = minim_obj.loadFile("music/song_0.mp3");
    music.loop();
  }
}










//Used for the level editing interface.
class Builder extends Screen {
  Jvect3 position;
  float xpower;
  float zpower;
  int current_tile_x;
  int current_tile_z;
  byte current_level_file_number;
  Terrain_obj current_object;
  boolean painting;
  Level level_to_edit;
  Button_group placing_buttons;
  Button_group transform_buttons;
  Button_group level_buttons;
  Button_group save_buttons;
  Color_picker paint_pick;
  
  
  Builder(Level level_to_edit_) {
    super();
    level_to_edit = level_to_edit_;
    position = new Jvect3(level_to_edit.level_width*150,-2000,level_to_edit.level_height*150);
    xpower = 0;
    zpower = 0;
    j3d_obj.camera_rotate_y = 0;
    j3d_obj.camera_rotate_x = HALF_PI;
    j3d_obj.camera = position;
    current_object = null;
    painting = false;
    paint_pick = new Color_picker(0.9, 0.5, "Painting");
    current_level_file_number = 1;
  
    Menu_item[] sub_group_temp = new Button_group[3];
    Menu_item[] buttons_temp = new Button[4];
    buttons_temp[0] = new Button(0, 0, 0.02, 0.02, "Str");
    buttons_temp[1] = new Button(0, 0, 0.02, 0.02, "Cor");
    buttons_temp[2] = new Button(0, 0, 0.02, 0.02, "T Junc");
    buttons_temp[3] = new Button(0, 0, 0.03, 0.02, "Finish");
    sub_group_temp[0] = new Button_group(0, 0,buttons_temp,"Roads");
  
    buttons_temp = new Button[3];
    buttons_temp[0] = new Button(0, 0, 0.02, 0.02, "Str");
    buttons_temp[1] = new Button(0, 0, 0.02, 0.02, "Cor");
    buttons_temp[2] = new Button(0, 0, 0.02, 0.02, "End");
    sub_group_temp[1] = new Button_group(0, 0,buttons_temp,"Hills");
  
    buttons_temp = new Button[1];
    buttons_temp[0] = new Button(0, 0, 0.035, 0.02, "Mud Pit");
    sub_group_temp[2] = new Button_group(0, 0,buttons_temp,"Obstacles");
    
    placing_buttons = new Button_group(0.27, 0.07,sub_group_temp,"");
  
    buttons_temp = new Button[6];
    buttons_temp[0] = new Button(0, 0, 0.015, 0.02, "+");
    buttons_temp[1] = new Button(0, 0, 0.03, 0.02, "Song "+level_to_edit.music_numb);
    buttons_temp[2] = new Button(0, 0, 0.015, 0.02, "-");
    buttons_temp[3] = new Button(0, 0, 0.015, 0.02, "+");
    buttons_temp[4] = new Button(0, 0, 0.03, 0.02, "Style "+level_to_edit.style);
    buttons_temp[5] = new Button(0, 0, 0.015, 0.02, "-");
    level_buttons = new Button_group(0.8, 0.07,buttons_temp,"Level Properties");
  
    buttons_temp = new Button[5];
    buttons_temp[0] = new Button(0, 0, 0.04, 0.02, "Longer");
    buttons_temp[1] = new Button(0, 0, 0.04, 0.02, "Shorter");
    buttons_temp[2] = new Button(0, 0, 0.04, 0.02, "Rotate");
    buttons_temp[3] = new Button(0, 0, 0.04, 0.02, "Paint");
    buttons_temp[4] = new Button(0, 0, 0.04, 0.02, "Menu");
    transform_buttons = new Button_group(0.25, 0.2,buttons_temp,"");
  
    buttons_temp = new Menu_item[3];
    buttons_temp[0] = new Button(0, 0, 0.03, 0.02, "Save");
    buttons_temp[1] = new Button(0, 0, 0.03, 0.02, "Save As");
    buttons_temp[2] = new Button(0, 0, 0.03, 0.02, "Load");
    //buttons_temp[5] = new Slider(0, 0, 0.03, 0.02, -1);
    save_buttons = new Button_group(0.75, 0.2,buttons_temp,"");
  }
  
  void update_and_draw() {
    //"Update" portion
    position.x += xpower*20*change_in_time;
    position.z += zpower*20*change_in_time;
    j3d_obj.camera = position;
    
    float xtemp; float ztemp; float sizetemp;
    sizetemp = j3d_obj.fov/(-100+j3d_obj.camera.y)*height;
    ztemp = (mouseY-height/2)/sizetemp;
    xtemp = -(mouseX-j3d_obj.window_xoffset-j3d_obj.window_xsize/2)/sizetemp;
    xtemp = xtemp+j3d_obj.camera.x;
    ztemp = ztemp+j3d_obj.camera.z;
    current_tile_x = int(xtemp/300);
    current_tile_z = int(ztemp/300);
    if (current_tile_x > level_to_edit.level_width-1) {
      current_tile_x = level_to_edit.level_width-1;
    }
    if (current_tile_x < 0) {current_tile_x = 0;
    }
    if (current_tile_z > level_to_edit.level_height-1) {
      current_tile_z = level_to_edit.level_height-1;
    }
    if (current_tile_z < 0) {current_tile_z = 0;
    }
    if (current_object != null) {
      current_object.move(current_tile_x, current_tile_z);
    }
    
    placing_buttons.update();
    transform_buttons.update();
    level_buttons.update();
    save_buttons.update();
    if (painting) {paint_pick.update();}
    
    //This lets the user know that they can preview the song
    if (level_buttons.buttons[1].mouse_over) {
      level_buttons.buttons[1].text = "Preview";
    } else {
      level_buttons.buttons[1].text = "Song "+level_to_edit.music_numb;
    }
    
    //Draw the level it edits to make it better.
    level_to_edit.draw_only();
    
    //"Draw" portion
    j3d_obj.reset_transforms();
    j3d_obj.oob_locking_angle = -1;
    stroke(255,0,0);
    j3d_obj.line_perspective(0,100,0,0,100,300*level_to_edit.level_height,10);
    j3d_obj.line_perspective(0,100,0,300*level_to_edit.level_width,100,0,10);
    j3d_obj.line_perspective(300*level_to_edit.level_width,100,0,300*level_to_edit.level_width,100,300*level_to_edit.level_height,10);
    j3d_obj.line_perspective(0,100,300*level_to_edit.level_height,300*level_to_edit.level_width,100,300*level_to_edit.level_height,10);
    noStroke();
    if (current_object != null) {
      current_object.draw_only();
    }
    placing_buttons.draw_only();
    transform_buttons.draw_only();
    level_buttons.draw_only();
    save_buttons.draw_only();
    if (painting) {paint_pick.draw_only();}
  }
  void keyPressed(int playern, int buttonn) {
    if (buttonn == 1) {
      xpower = -1;
    } else if (buttonn == 2) {
      xpower = 1;
    } else if (buttonn == 3) {
      zpower = 1;
    } else if (buttonn == 4) {
      zpower = -1;
    } else {
      if (key == 'r') {
        rotate_ninety();
      } else if (key == 'e') {
        change_length(1);
      } else if (key == 'd') {
        change_length(-1);
      }
    }
  }
  void keyReleased(int playern, int buttonn) {
    if (buttonn == 1) {
      xpower = 0;
    } else if (buttonn == 2) {
      xpower = 0;
    } else if (buttonn == 3) {
      zpower = 0;
    } else if (buttonn == 4) {
      zpower = 0;
    }
  }
  void mousePressed() {
    if (placing_buttons.mouse_over) {
      if ( ((Button_group) placing_buttons.buttons[0]).buttons[0].mouse_over) {
        current_object = new Road_straight(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[0]).buttons[1].mouse_over) {
        current_object = new Road_curved(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[0]).buttons[2].mouse_over) {
        current_object = new Road_T(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[0]).buttons[3].mouse_over) {
        current_object = new Finish_line(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[1]).buttons[0].mouse_over) {
        current_object = new Hill_straight(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[1]).buttons[1].mouse_over) {
        current_object = new Hill_corner(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[1]).buttons[2].mouse_over) {
        current_object = new Hill_end(0,0,1,0,0);
      } else if ( ((Button_group) placing_buttons.buttons[2]).buttons[0].mouse_over) {
        current_object = new Mud_pit(0,0,1,0,0);
      }
      if (current_object != null && painting) {
        current_object.main_color = paint_pick.color_selected;
      }
    } else if (level_buttons.mouse_over) {
      if (level_buttons.buttons[0].mouse_over) {
        level_to_edit.music_numb += 1;
        if (level_to_edit.music_numb > 9) {
          level_to_edit.music_numb = 1;
        }
        //level_buttons.buttons[1].text = "Song "+level_to_edit.music_numb;
      } else if (level_buttons.buttons[1].mouse_over) {
        music.close();
        println("music closed");
        music = minim_obj.loadFile("music/song_"+level_to_edit.music_numb+".mp3");
        println("new music loaded");
        music.loop();
        println("new music looping");
      } else if (level_buttons.buttons[2].mouse_over) {
        level_to_edit.music_numb -= 1;
        if (level_to_edit.music_numb < 1) {
          level_to_edit.music_numb = 9;
        }
        //level_buttons.buttons[1].text = "Song "+level_to_edit.music_numb;
      } else if (level_buttons.buttons[3].mouse_over) {
        level_to_edit.style += 1;
        if (level_to_edit.style > 9) {
          level_to_edit.style = 1;
        }
        level_buttons.buttons[4].text = "Style "+level_to_edit.style;
      } else if (level_buttons.buttons[4].mouse_over) {
      } else if (level_buttons.buttons[5].mouse_over) {
        level_to_edit.style -= 1;
        if (level_to_edit.style < 1) {
          level_to_edit.style = 9;
        }
        level_buttons.buttons[4].text = "Style "+level_to_edit.style;
      }
    } else if (transform_buttons.mouse_over) {
      if (transform_buttons.buttons[0].mouse_over) {
        change_length(1);
      } else if (transform_buttons.buttons[1].mouse_over) {
        change_length(-1);
      } else if (transform_buttons.buttons[2].mouse_over) {
        rotate_ninety();
      } else if (transform_buttons.buttons[3].mouse_over) {
        painting = !painting;
        transform_buttons.buttons[3].highlighted = painting;
        if (current_object != null && painting) {
          //current_object.main_color = paint_pick.color_selected;
        }
      } else if (transform_buttons.buttons[4].mouse_over) {
        screen_in_control = new Main_menu();
      }
    } else if (save_buttons.mouse_over) {
      if (save_buttons.buttons[2].mouse_over) {//Load the level
        selectInput("Load level:","load_level_builder");
      } else if (save_buttons.buttons[0].mouse_over) {//Save the level
        if (level_to_edit.file_path != "") {
          save_level(level_to_edit.file_path, level_to_edit);
        } else {
          selectOutput("Save level:","save_level_builder");
        }
      } else if (save_buttons.buttons[1].mouse_over) {//Save the level as
        selectOutput("Save level:","save_level_builder");
      }
    } else if (paint_pick.mouse_over) {
      //Do nothing - the paint picker takes care of it. Don't do stuff under it, though.
    } else {//If no button is pressed...
      if (level_to_edit.terrain_in_level[current_tile_x][current_tile_z] != level_to_edit.finish_line_var) {//If it is the only finish line, it can't be deleted.
        if (!painting || current_object != null) {
          level_to_edit.terrain_in_level[current_tile_x][current_tile_z] = current_object;
        }
      }
      if (current_object != null) {
        if (current_object.object_type == 16) {//If it is a finish line
          level_to_edit.finish_line_var = (Finish_line) current_object;
        }
      } else {
        if (painting) {
          if (level_to_edit.terrain_in_level[current_tile_x][current_tile_z] != null) {
            level_to_edit.terrain_in_level[current_tile_x][current_tile_z].main_color = paint_pick.color_selected;
          }
        }
      }
      current_object = null;
    }
  }
  
  void change_length(int length_to_change) {
    if (current_object != null) {
      current_object.longness += length_to_change;
      if (current_object.longness > 10) {
        current_object.longness = 1;
      }
      if (current_object.longness < 1) {
        current_object.longness = 1;
      }
    }
  }
  void rotate_ninety() {
    if (current_object != null) {
      if (current_object.object_type == 16) {//If it is a finish line
        return;//These can't be rotated.
      }
      current_object.direction += HALF_PI;
      if (current_object.direction > TWO_PI-0.1) {
        current_object.direction = 0;
      }
    }
  }
}

void save_level_builder(File filename) {
  Builder builder_var = (Builder) screen_in_control;
  save_level(filename.getAbsolutePath(), builder_var.level_to_edit);
  builder_var.level_to_edit.file_path = filename.getAbsolutePath();
}

void load_level_builder(File filename) {
  Builder builder_var = (Builder) screen_in_control;
  builder_var.level_to_edit = load_level(filename.getAbsolutePath());
  level_var = builder_var.level_to_edit;
}

void load_level_select(File filename) {
  level_var = load_level(filename.getAbsolutePath());
}









void save_level(String level_name, Level level_temp) {
  PrintWriter output = createWriter(level_name);
  output.println(level_temp.level_width+","+level_temp.level_height+","+
    level_temp.music_numb+","+level_temp.style);
  level_temp.finish_line_var.save_item(output);
  for (int i = 0; i < level_temp.level_width; i = i+1) {
    for (int j = 0; j < level_temp.level_height; j = j+1) {
      if (level_temp.terrain_in_level[i][j] != null) {
        level_temp.terrain_in_level[i][j].has_been_drawn = false;
      }
    }
  }
  for (int i = 0; i < level_temp.level_width; i = i+1) {
    for (int j = 0; j < level_temp.level_height; j = j+1) {
      if (level_temp.terrain_in_level[i][j] != null) {
        if (level_temp.terrain_in_level[i][j].has_been_drawn == false) {
          level_temp.terrain_in_level[i][j].save_item(output);
          level_temp.terrain_in_level[i][j].has_been_drawn = true;
        }
      }
    }
  }
  output.flush();//Writes the remaining data to the file
  output.close();//Finishes the file
}

Level load_level(String level_name) {
  String[] items = loadStrings(level_name);
  if (items == null) {
    return null;
  }
  String[] level_data = split(items[0],",");//Width, height,
  Level level_temp = new Level(int(level_data[0]),int(level_data[1]));
  level_temp.file_path = level_name;
  if (level_data.length > 2) {
    level_temp.music_numb = int(level_data[2]);
    level_temp.style = int(level_data[3]);
  } else {
    level_temp.music_numb = 1;
    level_temp.style = 1;
  }
  String[] finish_line_data = split(items[1],",");
  level_temp.finish_line_var = new Finish_line(int(finish_line_data[1]),int(finish_line_data[2]),int(finish_line_data[3]),float(finish_line_data[4]),int(finish_line_data[5]));
  for (int i = 2; i < items.length; i = i+1) {
    String[] object_data = split(items[i],",");
    Terrain_obj current_item = null;
    //1 = hill_straight, 2 = hill_corner, 4 = hill_end,
    //11 = road_straight, 12 = road_curved, 16 = finish_line
    //21 = mud_pit
    int current_item_type = int(object_data[0]);
    if (current_item_type == 1) {
      current_item = new Hill_straight(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 2) {
      current_item = new Hill_corner(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 4) {
      current_item = new Hill_end(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 11) {
      current_item = new Road_straight(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 12) {
      current_item = new Road_curved(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 13) {
      current_item = new Road_T(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 16) {
      current_item = new Finish_line(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    } else if (current_item_type == 21) {
      current_item = new Mud_pit(int(object_data[1]),int(object_data[2]),int(object_data[3]),float(object_data[4]),int(object_data[5]));
    }
    if (current_item != null) {
      if (object_data.length > 6) {//Set the color if it was saved...
        current_item.main_color = int(object_data[6]);
      }
      level_temp.terrain_in_level[current_item.x_tile][current_item.z_tile] = current_item;
    }
  }
  return level_temp;
}
