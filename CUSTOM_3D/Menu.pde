//"Menu" file
class Screen {//This is an item used to "control" the game. For instance, the "level", when controlling the game, will do stuff.
  float x; float y;
  Screen() {
    x = 0; y = 0;
  }
  
  void update_and_draw() {}
  void keyPressed(int playern, int buttonn/*0=left,1=right,2=up,3=down,0=none*/) {}
  void keyReleased(int playern, int buttonn) {}
  void mousePressed() {}
}





class Main_menu extends Screen {
  Menu_button button1;
  Menu_button button2;
  Menu_button button3;
  Main_menu() {
    super();
    button1 = new Menu_button(0.5,"Play");
    button2 = new Menu_button(0.65,"Level Editor");
    button3 = new Menu_button(0.8,"Quit");
  }
  
  void update_and_draw() {
    j3d_obj.reset_transforms();
    j3d_obj.camera.set(0,-300,0);
    j3d_obj.camera_rotate_x = HALF_PI/4;
    j3d_obj.camera_rotate_y = HALF_PI/2;
    level_var.draw_only();//Make sure the level is drawn
    button1.update();
    button2.update();
    button3.update();
    button1.draw_only();
    button2.draw_only();
    button3.draw_only();
  }
  void mousePressed() {
    if (button1.mouse_over) {
      screen_in_control = new Character_select();
    } else if (button2.mouse_over) {
      screen_in_control = new Builder(level_var);
    } else if (button3.mouse_over) {
      exit();
    }
  }
}





class Character_select extends Screen {
  Sub_character_select[] select_objs;
  Button[] buttons;
  int numb_of_players;
  Character_select() {
    super();
    select_objs = new Sub_character_select[4];
    select_objs[0] = new Sub_character_select(0.25,0.25,0,true);
    select_objs[0].joined = true;
    select_objs[1] = new Sub_character_select(0.75,0.25,1,false);
    select_objs[2] = new Sub_character_select(0.25,0.65,2,true);
    select_objs[3] = new Sub_character_select(0.75,0.65,3,false);
    buttons = new Button[2];
    buttons[0] = new Button(0.25,0.9,0.1,0.05,"Back");
    buttons[1] = new Button(0.75,0.9,0.1,0.05,"Next");
    numb_of_players = 1;
  }
  
  void update_and_draw() {
    j3d_obj.reset_transforms();
    j3d_obj.camera.set(0,-300,0);
    j3d_obj.camera_rotate_x = HALF_PI/4;
    j3d_obj.camera_rotate_y = HALF_PI/2;
    level_var.draw_only();//Make sure the level is drawn
    for (int i=0; i<select_objs.length;i++) {
      select_objs[i].update();
      select_objs[i].draw_only();
    }
    for (int i=0; i<buttons.length;i++) {
      buttons[i].update();
      buttons[i].draw_only();
    }
  }
  
  void mousePressed() {
    if (buttons[0].mouse_over) {
      screen_in_control = new Main_menu();
    } else if (buttons[1].mouse_over) {
      cars = new Car[numb_of_players];
      for (int i=0; i<numb_of_players; i++) {
        cars[i] = select_objs[i].car_for_show;
      }
      screen_in_control = new Level_select(this);
    } else {
      for (int i=0; i<select_objs.length; i++) {
        if (i <= numb_of_players) {
          if (select_objs[i].mousePressed()) {
            if (numb_of_players == i) {
              numb_of_players = i+1;
            }
          }
        }
      }
    }
  }
  
  void keyPressed(int playern, int buttonn) {
    if (playern <= numb_of_players) {
      if (select_objs[playern].keyPressed(buttonn)) {
        if (numb_of_players == playern) {
          numb_of_players = playern+1;
        }
      }
    }
  }
  
  class Sub_character_select extends Menu_item {
    boolean joined;
    boolean on_right;
    int char_selected_x;
    int char_selected_y;
    float car_spin_timer;
    int player_numb;
    Button[][] character_buttons;
    Car car_for_show;
    
    Sub_character_select(float x_fraction_, float y_fraction_, int player_numb_, boolean on_right_) {
      super(x_fraction_, y_fraction_, 0.25, 0.2);
      char_selected_x = 0;
      char_selected_y = 0;
      player_numb = player_numb_;
      joined = false;
      on_right = on_right_;
      car_spin_timer = 0;
      switch (player_numb) {
        case 0: car_for_show = new Car(0,0,color(192,0,0)); char_selected_x = 0; char_selected_y = 0; break;
        case 1: car_for_show = new Car(0,0,color(0,192,0)); char_selected_x = 0; char_selected_y = 1; break;
        case 2: car_for_show = new Car(0,0,color(192,192,0)); char_selected_x = 1; char_selected_y = 0; break;
        case 3: car_for_show = new Car(0,0,color(0,0,192)); char_selected_x = 1; char_selected_y = 1; break;
      }
      
      character_buttons = new Button[2][3];
      float temp_flip;
      if (on_right) {
        temp_flip = 1;
      } else {
        temp_flip = -1;
      }
      float temp_width = 0.25;
      for (int i=0; i<character_buttons.length; i++) {//i is left-right
        for (int j=0; j<character_buttons[i].length; j++) {//j is up-down
          String button_text;
          switch (i+character_buttons.length*j+1) {
            case 1: button_text = "Red"; break;
            case 2: button_text = "Yellow"; break;
            case 3: button_text = "Green"; break;
            case 4: button_text = "Blue"; break;
            case 5: button_text = "Purple"; break;
            case 6: button_text = "Black"; break;
            default: button_text = "Error"; break;
          }
          character_buttons[i][j] = new Button(x_fraction_+temp_flip*temp_width/2*1/character_buttons.length+
            temp_flip*float(i)*temp_width/character_buttons.length,
            y_fraction_-0.2+0.1/character_buttons[i].length+float(j)*0.4/character_buttons[i].length,
            temp_width/2*1/float(character_buttons.length)-0.01, 0.2/float(character_buttons[i].length)-0.01, button_text);
        }
      }
      character_buttons[char_selected_x][char_selected_y].highlighted = true;
      
    }
    
    boolean mousePressed() {
      if (joined) {
        for (int i=0; i<character_buttons.length; i++) {//i is left-right
          for (int j=0; j<character_buttons[i].length; j++) {//j is up-down
            if (character_buttons[i][j].mouse_over) {
              char_selected_x = i;
              char_selected_y = j;
            }
            character_buttons[i][j].highlighted = false;
          }
        }
        character_buttons[char_selected_x][char_selected_y].highlighted = true;
        switch (char_selected_x+character_buttons.length*char_selected_y+1) {
          case 1: car_for_show = new Car(0,0,color(192,0,0)); break;
          case 2: car_for_show = new Car(0,0,color(192,192,0)); break;
          case 3: car_for_show = new Car(0,0,color(0,192,0)); break;
          case 4: car_for_show = new Car(0,0,color(0,0,192)); break;
          case 5: car_for_show = new Car(0,0,color(192,0,192)); break;
          case 6: car_for_show = new Car(0,0,color(0,0,0)); break;
        }
        return true;
      } else {
        if (mouse_over) {
          joined = true;
          return true;
        } else {
          return false;
        }
      }
    }
    
    boolean keyPressed(int buttonn) {
      if (joined) {
        if (buttonn == 1) {
          char_selected_x -= 1;
          if (char_selected_x < 0) {
            char_selected_x = character_buttons.length-1;
          }
        } else if (buttonn == 2) {
          char_selected_x += 1;
          if (char_selected_x > character_buttons.length-1) {
            char_selected_x = 0;
          }
        } else if (buttonn == 3) {
          char_selected_y -= 1;
          if (char_selected_y < 0) {
            char_selected_y = character_buttons[0].length-1;
          }
        } else if (buttonn == 4) {
          char_selected_y += 1;
          if (char_selected_y > character_buttons[0].length-1) {
            char_selected_y = 0;
          }
        }
        for (int i=0; i<character_buttons.length; i++) {//i is left-right
          for (int j=0; j<character_buttons[i].length; j++) {//j is up-down
            character_buttons[i][j].highlighted = false;
          }
        }
        character_buttons[char_selected_x][char_selected_y].highlighted = true;
        switch (char_selected_x+character_buttons.length*char_selected_y+1) {
          case 1: car_for_show = new Car(0,0,color(192,0,0)); break;
          case 2: car_for_show = new Car(0,0,color(192,192,0)); break;
          case 3: car_for_show = new Car(0,0,color(0,192,0)); break;
          case 4: car_for_show = new Car(0,0,color(0,0,192)); break;
          case 5: car_for_show = new Car(0,0,color(192,0,192)); break;
          case 6: car_for_show = new Car(0,0,color(0,0,0)); break;
        }
      } else {
        joined = true;
      }
      return true;
    }
    
    void update() {
      super.update();
      for (int i=0; i<character_buttons.length; i++) {
        for (int j=0; j<character_buttons[i].length; j++) {
          character_buttons[i][j].update();
        }
      }
    }
    
    void draw_only() {
      if (joined) {
        car_spin_timer += change_in_time;
        j3d_obj.reset_transforms();
        j3d_obj.camera.set(0,50,-80);
        j3d_obj.camera_rotate_x = HALF_PI/4;
        j3d_obj.camera_rotate_y = 0;
        j3d_obj.window_xsize = width/4;
        if (on_right) {
          j3d_obj.window_xoffset = int(x_pos-width/4);
        } else {
          j3d_obj.window_xoffset = int(x_pos);
        }
        j3d_obj.window_ysize = int(height*0.4);
        j3d_obj.window_yoffset = int(y_pos-height*0.2);
        car_for_show.facing_direction = car_spin_timer/10;
        car_for_show.x = -25*cos(car_for_show.facing_direction);
        car_for_show.z = -25*sin(car_for_show.facing_direction);
        car_for_show.draw_only();
        
        for (int i=0; i<character_buttons.length; i++) {
          for (int j=0; j<character_buttons[i].length; j++) {
            character_buttons[i][j].draw_only();
          }
        }
      } else {
        fill(0);
        textSize(24);
        switch (player_numb) {
          case 0: text("Press arrows to join", x_pos,y_pos); break;
          case 1: text("Press wasd to join",x_pos,y_pos); break;
          case 2: text("Press okl; to join",x_pos,y_pos); break;
          case 3: text("Press 8456 to join",x_pos,y_pos); break;
        }
      }
    }
  }
}





class Level_select extends Screen {
  Sub_level_select select_obj;
  Button[] buttons;
  int numb_of_players;
  Screen prev_screen;
  
  Level_select(Screen prev_screen_) {
    super();
    prev_screen = prev_screen_;
    select_obj = new Sub_level_select(0.5,0.5,0);
    buttons = new Button[2];
    buttons[0] = new Button(0.25,0.9,0.1,0.05,"Back");
    buttons[1] = new Button(0.75,0.9,0.1,0.05,"Go");
  }
  
  void update_and_draw() {
    j3d_obj.reset_transforms();
    j3d_obj.camera.set(0,-300,0);
    j3d_obj.camera_rotate_x = HALF_PI/4;
    j3d_obj.camera_rotate_y = HALF_PI/2;
    level_var.draw_only();//Make sure the level is drawn
    select_obj.update();
    select_obj.draw_only();
    for (int i=0; i<buttons.length;i++) {
      buttons[i].update();
      buttons[i].draw_only();
    }
  }
  
  void mousePressed() {
    if (buttons[0].mouse_over) {
      screen_in_control = prev_screen;
    } else if (buttons[1].mouse_over) {
      screen_in_control = level_var;
      level_var.prepare_for_racing();
    } else {
      select_obj.mousePressed();
    }
  }
  
  void keyPressed(int playern, int buttonn) {
    select_obj.keyPressed(buttonn);
  }
  
  class Sub_level_select extends Menu_item {
    int char_selected_x;
    int char_selected_y;
    Button[][] character_buttons;
    
    Sub_level_select(float x_fraction_, float y_fraction_, int player_numb_) {
      super(x_fraction_, y_fraction_, 0.5, 0.4);
      char_selected_x = -1;
      char_selected_y = 0;
      
      character_buttons = new Button[2][3];
      for (int i=0; i<character_buttons.length; i++) {//i is left-right
        for (int j=0; j<character_buttons[i].length; j++) {//j is up-down
          String button_text;
          switch (i+character_buttons.length*j+1) {
            case 1: button_text = "Default"; break;
            case 2: button_text = "Plains"; break;
            case 3: button_text = "Snow"; break;
            case 4: button_text = "Complex"; break;
            case 5: button_text = "Rainbow Road"; break;
            case 6: button_text = "Load Custom"; break;
            default: button_text = "Error"; break;
          }
          character_buttons[i][j] = new Button(x_fraction_-0.4+
            (float(i)+0.5)*0.8/character_buttons.length,
            y_fraction_-0.2+0.1/character_buttons[i].length+float(j)*0.4/character_buttons[i].length,
            0.3/float(character_buttons.length)-0.01, 0.2/float(character_buttons[i].length)-0.01, button_text);
        }
      }
      //character_buttons[char_selected_x][char_selected_y].highlighted = true;
      
    }
    
    boolean mousePressed() {
      for (int i=0; i<character_buttons.length; i++) {//i is left-right
        for (int j=0; j<character_buttons[i].length; j++) {//j is up-down
          if (character_buttons[i][j].mouse_over) {
            char_selected_x = i;
            char_selected_y = j;
          }
          character_buttons[i][j].highlighted = false;
        }
      }
      if (char_selected_x >= 0) {
        character_buttons[char_selected_x][char_selected_y].highlighted = true;
        switch (char_selected_x+character_buttons.length*char_selected_y+1) {
          case 1: level_var = load_level("levels/default.txt"); break;
          case 2: level_var = load_level("levels/plains.txt"); break;
          case 3: level_var = load_level("levels/snow.txt"); break;
          case 4: level_var = load_level("levels/complex.txt"); break;
          case 5: level_var = load_level("levels/rainbow_road.txt"); break;
          case 6: selectInput("Load level:","load_level_select"); break;
        }
      }
      return true;
    }
    
    void keyPressed(int buttonn) {
      if (buttonn == 1) {
        char_selected_x -= 1;
        if (char_selected_x < 0) {
          char_selected_x = character_buttons.length-1;
        }
      } else if (buttonn == 2) {
        char_selected_x += 1;
        if (char_selected_x > character_buttons.length-1) {
          char_selected_x = 0;
        }
      } else if (buttonn == 3) {
        char_selected_y -= 1;
        if (char_selected_y < 0) {
          char_selected_y = character_buttons[0].length-1;
        }
      } else if (buttonn == 4) {
        char_selected_y += 1;
        if (char_selected_y > character_buttons[0].length-1) {
          char_selected_y = 0;
        }
      }
      for (int i=0; i<character_buttons.length; i++) {//i is left-right
        for (int j=0; j<character_buttons[i].length; j++) {//j is up-down
          character_buttons[i][j].highlighted = false;
        }
      }
      character_buttons[char_selected_x][char_selected_y].highlighted = true;
      switch (char_selected_x+character_buttons.length*char_selected_y+1) {
        case 1: level_var = load_level("levels/default.txt"); break;
        case 2: level_var = load_level("levels/plains.txt"); break;
        case 3: level_var = load_level("levels/snow.txt"); break;
        case 4: level_var = load_level("levels/complex.txt"); break;
        case 5: level_var = load_level("levels/rainbow_road.txt"); break;
        case 6: selectInput("Load level:","load_level_select"); break;
      }
    }
    
    void update() {
      super.update();
      for (int i=0; i<character_buttons.length; i++) {
        for (int j=0; j<character_buttons[i].length; j++) {
          character_buttons[i][j].update();
        }
      }
    }
    
    void draw_only() {
      for (int i=0; i<character_buttons.length; i++) {
        for (int j=0; j<character_buttons[i].length; j++) {
          character_buttons[i][j].draw_only();
        }
      }
    }
  }
}





class Start_screen extends Screen {
  Car car_for_show;
  Jvect2_ext title_location;//Used to make the title on the finish line.
  float car_spin_timer;
  color title_text_color;
  boolean has_focus;//Used so when it is first created, it takes two clicks to continue.
  Start_screen() {
    car_for_show = new Car(0,0,color(192,0,0));
    title_location = new Jvect2_ext(0,0,1);
    car_spin_timer = 0;
    has_focus = false;
    title_text_color = color(0,0,128);
  }
  
  void update_and_draw() {
    car_spin_timer += change_in_time;
    
    j3d_obj.reset_transforms();
    j3d_obj.camera.set(level_var.finish_line_var.x_tile*300+150,0,level_var.finish_line_var.z_tile*300);
    j3d_obj.camera_rotate_x = 0;
    j3d_obj.camera_rotate_y = 0;
    //This sets the text to the finish line flag's position.
    j3d_obj.persp(level_var.finish_line_var.x_tile*300+150,-100,level_var.finish_line_var.z_tile*300+150,title_location);
    level_var.draw_only();//Make sure the level is drawn
    
    fill(255,128);
    noStroke();
    rect(0,0,width,height);
    j3d_obj.camera.set(0,50,-80);
    j3d_obj.camera_rotate_x = HALF_PI/4;
    j3d_obj.camera_rotate_y = 0;
    
    car_for_show.facing_direction = car_spin_timer/10;
    car_for_show.x = -25*cos(car_for_show.facing_direction);
    car_for_show.z = -25*sin(car_for_show.facing_direction);
    car_for_show.draw_only();
    
    textAlign(CENTER,CENTER);
    textFont(title_font,64+16*sin(car_spin_timer/10));
    fill(title_text_color);
    text("Racing 3D",title_location.u,title_location.v);
    textFont(main_font, 24-8*sin(car_spin_timer/10));
    fill(0,192-64*sin(car_spin_timer/10));
    text("Click to start!",width/2,height*7/8);
  }
  void mousePressed() {
    if (has_focus) {
      screen_in_control = new Main_menu();
    } else {
      has_focus = true;
    }
  }
}



class Menu_item {
  float x_pos;//Center
  float y_pos;
  float x_size;//Radius
  float y_size;
  boolean mouse_over;
  boolean highlighted;
  String text;
  color[] colors;
  
  Menu_item(float x_fraction_, float y_fraction_, float x_size_frac, float y_size_frac) {
    y_pos = height*y_fraction_;
    x_pos = width*x_fraction_;
    //x_pos = (width-height)/2+height*x_fraction_;
    x_size = width*x_size_frac;
    y_size = height*y_size_frac;
    highlighted = false;
    mouse_over = false;
  }
  
  void update() {
    if (mouseX > x_pos-x_size && mouseX < x_pos+x_size && mouseY > y_pos-y_size && mouseY < y_pos+y_size) {
      //If the mouse is within the object;
      mouse_over = true;
    } else {
      mouse_over = false;
    }
  }
  
  void set_position(float x_, float y_) {
    x_pos = x_; y_pos = y_;
  }
  
  void draw_only() {
  }
}

class Button extends Menu_item {
  
  Button(float x_fraction_, float y_fraction_, float x_size_frac, float y_size_frac, String text_) {
    super(x_fraction_,y_fraction_,x_size_frac,y_size_frac);
    text = text_;
    colors = new color[3];
    colors[0] = color(192);
    colors[1] = color(255);
    colors[2] = color(128);
  }
  
  void draw_only() {
    rectMode(RADIUS);
    if (mouse_over) {
      fill(colors[1]);
      stroke(0);
      strokeWeight(3);
    } else if (highlighted) {
      fill(colors[2]);
      stroke(0);
      strokeWeight(2);
    } else {
      fill(colors[0]);
      stroke(0);
      strokeWeight(2);
    }
    rect(x_pos,y_pos,x_size,y_size);
    fill(0);
    textFont(main_font);
    textAlign(CENTER,CENTER);
    text(text, x_pos,y_pos);
    rectMode(CORNER);
    noStroke();
  }
}

class Menu_button extends Button {
  //The size is always 1/24th the height, and the width is 8 times this. This is only half the size.
  Menu_button(float y_fraction_, String text_) {
    super(0.5,y_fraction_,0.25, 0.04166666666, text_);
  }
}

class Button_group extends Menu_item {
  Menu_item[] buttons;
  float padding;
  float text_space;
  
  Button_group(float x_fraction_, float y_fraction_, Menu_item[] buttons_, String text_) {
    super(x_fraction_,y_fraction_,0,0);
    buttons = buttons_;
    padding = height*0.015;
    colors = new color[1];
    colors[0] = color(256,0,0);
    //Set the sizes correctly.
    text = text_;
    for (int i = 0; i < buttons.length; i = i+1) {
      if (buttons[i].y_size > y_size) {
        y_size = buttons[i].y_size;
      }
      x_size += buttons[i].x_size+padding/2;
    }
    x_size += padding/2;
    if (text != "") {
      text_space = height*0.015;
      y_size += padding+text_space;
    } else {
      y_size += padding;
    }
    set_button_positions();
  }
  
  void set_position(float x_, float y_) {//To change the positions of sub-items when its own position is changed.
    super.set_position(x_, y_);
    set_button_positions();
  }
  
  void set_button_positions() {
    //float theoretical_delta_x = ((x_size-padding)*2)/buttons.length;
    //float x_current = x_pos-theoretical_delta_x*(buttons.length-1)/2;//-padding*(buttons.length-1);
    float x_current = x_pos-x_size;//-padding*(buttons.length-1);
    float y_current = y_pos+text_space;
    for (int i = 0; i < buttons.length; i = i+1) {
      x_current += padding+buttons[i].x_size;//Increments it a little.
      buttons[i].set_position(x_current,y_current);//I use this function in case another group is embedded.
      x_current += buttons[i].x_size;//Increments it a little.
    }
  }
  
  void update() {
    super.update();
    for (int i = 0; i < buttons.length; i = i+1) {
      buttons[i].update();
    }
  }
  
  void draw_only() {
    rectMode(RADIUS);
    fill(colors[0]);
    stroke(red(colors[0])/2,green(colors[0])/2,blue(colors[0])/2,alpha(colors[0]));
    strokeWeight(2);
    rect(x_pos,y_pos,x_size,y_size);
    fill(0);
    textAlign(CENTER,TOP);
    textFont(main_font);
    text(text,x_pos,y_pos-y_size+padding/2);
    rectMode(CORNER);
    noStroke();
    for (int i = 0; i < buttons.length; i = i+1) {
      buttons[i].draw_only();
    }
  }
}

class Slider extends Menu_item {
  float value;//From -1 to 1;
  
  Slider(float x_fraction_, float y_fraction_, float x_size_frac, float y_size_frac, float default_value) {
    super(x_fraction_,y_fraction_,x_size_frac,y_size_frac);
    value = default_value;
  }
  
  void update() {
    x_size += y_size/2;
    x_size -= y_size/2;
    if (mousePressed) {
      if (mouse_over) {
        value = (mouseX-x_pos)/x_size;
        if (value > 1) value = 1;
        if (value < -1) value = -1;
      }
    } else {
      super.update();
    }
    //Set the mouse position
  }
  
  void draw_only() {
    rectMode(RADIUS);
    stroke(0);
    strokeWeight(4);
    line(x_pos-x_size, y_pos, x_pos+x_size, y_pos);//The back
    if (mouse_over) {
      fill(255);
      stroke(0);
      strokeWeight(3);
    } else {
      fill(192);
      stroke(0);
      strokeWeight(2);
    }
    rect(x_pos+value*x_size,y_pos,y_size/2,y_size);
    rectMode(CORNER);
    noStroke();
  }
}

class Color_picker extends Menu_item {
  String text;
  Slider hue; Slider sat; Slider val;
  Button eyedropper_button;
  color color_selected;
  float text_ypos;
  
  Color_picker(float x_fraction_, float y_fraction_,  String text_) {
    super(x_fraction_,y_fraction_,0.08,0.12);//0.1 wide
    hue = new Slider(x_fraction_, y_fraction_-0.05,0.06,0.02,-1);
    sat = new Slider(x_fraction_, y_fraction_+0.00,0.06,0.02,1);
    val = new Slider(x_fraction_, y_fraction_+0.05,0.06,0.02,1);
    eyedropper_button = new Button(x_fraction_, y_fraction_+0.1,0.04,0.018,"");
    text = text_;
    text_ypos = y_pos-0.10*height;
  }
  
  void update() {
    super.update();
    hue.update();
    sat.update();
    val.update();
    eyedropper_button.update();
    colorMode(HSB);
    color_selected = color(hue.value*128+128,sat.value*128+128,val.value*128+128);
    eyedropper_button.colors[0] = color_selected;
    eyedropper_button.colors[1] = color_selected;
    colorMode(RGB);
  }
  
  void draw_only() {
    rectMode(RADIUS);
    fill(255,0,0);
    stroke(0);
    strokeWeight(2);
    rect(x_pos,y_pos,x_size,y_size);
    fill(0);
    textFont(main_font,24);
    textAlign(CENTER,CENTER);
    text(text, x_pos,text_ypos);
    rectMode(CORNER);
    noStroke();
    hue.draw_only();
    sat.draw_only();
    val.draw_only();
    eyedropper_button.draw_only();
  }
}






class Race_overlay extends Menu_item {
  Button return_to_menu;
  boolean display_score;
  String center_text;
  float center_text_size;
  boolean display_center_text;
  boolean display_win_overlay;//Determines if the screen is washed out and the score is in the center or corner.
  
  Race_overlay(String center_text_, float xstart, float xwidth, float ystart, float ywidth) {
    super(xstart+xwidth/2,ystart+ywidth/2,xwidth/2,ywidth/2);
    return_to_menu = new Button(xstart+0.9*xwidth,ystart+0.1*ywidth,0.04*xwidth,0.04*ywidth,"Menu");
    display_score = false;
    center_text = center_text_;
    center_text_size = 0;
    display_center_text = false;
    display_win_overlay = false;
    colors = new color[1];
    colors[0] = color(0);
  }
  
  void update() {
    return_to_menu.update();
  }
  
  void draw_only(float actual_score) {
    //println("Xpos: "+x_pos+", Ypos: "+y_pos+", Xsize: "+x_size+", Ysize: "+y_size);
    if (display_win_overlay) {
      fill(255,128);
      rectMode(RADIUS);
      rect(x_pos,y_pos,x_size,y_size);
      rectMode(CORNER);
      fill(0);
      textSize(36);
      text(actual_score,x_pos,y_pos+y_size*0.2);
    } else {
      fill(colors[0]);
      textSize(24);
      //textAlign(CENTER);
      text(actual_score,x_pos,y_pos-y_size*0.8);
    }
    textAlign(CENTER);
    if (display_center_text) {
      textSize(center_text_size);
      text(center_text,x_pos,y_pos);
    }
    textSize(12);
    return_to_menu.draw_only();
  }
}
