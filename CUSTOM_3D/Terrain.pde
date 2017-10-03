//"Terrain" file
class Terrain_obj {//Combines roads, hills, and other features.
  int x_tile;//Each "Tile" is 150 meters across.
  int z_tile;
  int longness;
  float direction;
  int variation;//0=nothing
  color main_color;
  
  boolean has_been_drawn;
  int object_type;
  //1 = hill_straight, 2 = hill_corner, 4 = hill_end,
  //11 = road_straight, 12 = road_curved, 13 = road_T, 16 = finish_line
  //21 = mud_pit
  Jvect2_ext[] points;
  
  Terrain_obj(int x_tile_, int z_tile_, int longness_, float direction_, int variation_, int pointnumb) {
    x_tile = x_tile_;
    z_tile = z_tile_;
    direction = direction_;
    longness = longness_;
    variation = variation_;
    object_type = 0;
    points = new Jvect2_ext[pointnumb];
    for (int i=0; i<pointnumb;i=i+1) {
      points[i] = new Jvect2_ext(0,0,1);
    }
  }
  
  byte collide_car_rect(float boundL, float boundR, float boundH, float boundY1, float boundY2, Car car_obj) {
    //This function uses the position/rotation of the object itself.
    //It returns 1 if it hit the left, 2 if it hit the right, and 3 for hitting both.
    float xbound1; float zbound1;//Bottom left (negatives)
    float xbound2; float zbound2;//Top right (positives)
    byte what_to_return = 0;
    if (car_obj.y < boundY1 || car_obj.y > boundY2) {
      //If it is higher than the high bound or lower than the low bound...
      //Return that it doesn't collide.
      return what_to_return;
    }
    if (direction == HALF_PI) {//If it is horizontal, set collision accordingly
      xbound1 = boundH-300*longness; xbound2 = boundH;
      zbound1 = boundL; zbound2 = boundR;
    } else if (direction == PI) {
      xbound1 = -boundR; xbound2 = -boundL;
      zbound1 = -300*(longness-1)-boundH; zbound2 = boundH;
    } else if (direction == PI+HALF_PI) {
      xbound1 = -boundH; xbound2 = boundH+300*(longness-1);
      zbound1 = -boundR; zbound2 = -boundL;
    } else {//If it is vertical, set collision accordingly
      xbound1 = boundL; xbound2 = boundR;
      zbound1 = -boundH; zbound2 = 300*(longness-1)+boundH;
    }
    //Move the bounds to align w/ the object's position.
    xbound1 += x_tile*300+150; xbound2 += x_tile*300+150;
    zbound1 += z_tile*300+150; zbound2 += z_tile*300+150;
    if (car_obj.top_left_corner.u > xbound1 && car_obj.top_left_corner.u < xbound2 && car_obj.top_left_corner.v > zbound1 && car_obj.top_left_corner.v < zbound2) {
      //If the left side of the car is touching the object...
      what_to_return += 1;
    }
    if (car_obj.top_right_corner.u > xbound1 && car_obj.top_right_corner.u < xbound2 && car_obj.top_right_corner.v > zbound1 && car_obj.top_right_corner.v < zbound2) {
      //If the left side of the car is touching the object...
      what_to_return += 2;
    }
    if (car_obj.z-zbound1 > (zbound2-zbound1)*(car_obj.x-xbound1)/(xbound2-xbound1)) {
      //If the car is in the top left
      what_to_return += 4;
    }
    if (car_obj.z-zbound2 > (zbound1-zbound2)*(car_obj.x-xbound1)/(xbound2-xbound1)) {
      //If the car is in the top right
      what_to_return += 8;
    }
    return what_to_return;
  }
  
  byte collide_car_arc(float boundL, float boundR, float boundY1, float boundY2, Car car_obj) {
    //This function uses the position/rotation of the object itself.
    //It returns 1 if it hit the left, 2 if it hit the right, and 3 for hitting both.
    float xbound1; float zbound1;//Bottom left (negatives)
    float xbound2; float zbound2;//Top right (positives)
    float xorigin; float zorigin;//These variables are the "center" of the arc.
    byte what_to_return = 0;
    if (car_obj.y < boundY1 || car_obj.y > boundY2) {
      //If it is higher than the high bound or lower than the low bound...
      //Return that it doesn't collide.
      return what_to_return;
    }
    //find the "center".
    float longness_temp = 300*longness-300;
    xorigin = x_tile*300+150+(150+longness_temp)*sqrt(2)*cos(direction+5*PI/4);
    zorigin = z_tile*300+150+150*sqrt(2)*sin(direction+5*PI/4);
    //Set the bounds to the square made by the arc.
    if (direction == HALF_PI) {
      xbound1 = (x_tile)*300; xbound2 = (x_tile+longness)*300;
      zbound1 = (z_tile)*300; zbound2 = (z_tile+longness)*300;
    } else if (direction == PI) {
      xbound1 = (x_tile)*300; xbound2 = (x_tile+longness)*300;
      zbound1 = (z_tile-longness+1)*300; zbound2 = (z_tile+1)*300;
    } else if (direction == PI+HALF_PI) {
      xbound1 = (x_tile-longness+1)*300; xbound2 = (x_tile+1)*300;
      zbound1 = (z_tile-longness+1)*300; zbound2 = (z_tile+1)*300;
    } else {
      xbound1 = (x_tile-longness+1)*300; xbound2 = (x_tile+1)*300;
      zbound1 = (z_tile)*300; zbound2 = (z_tile+longness)*300;
    }
    //If the left side of the car is in the square...
    if (car_obj.top_left_corner.u > xbound1 && car_obj.top_left_corner.u < xbound2 && car_obj.top_left_corner.v > zbound1 && car_obj.top_left_corner.v < zbound2) {
      //If the left side of the car is within the circle...
      float dist_temp = dist(car_obj.top_left_corner.u,car_obj.top_left_corner.v,xorigin,zorigin);
      if (dist_temp > boundL && dist_temp < boundR) {
        what_to_return += 1;
      }
    }
    if (car_obj.top_right_corner.u > xbound1 && car_obj.top_right_corner.u < xbound2 && car_obj.top_right_corner.v > zbound1 && car_obj.top_right_corner.v < zbound2) {
      //If the left side of the car is within the circle...
      float dist_temp = dist(car_obj.top_right_corner.u,car_obj.top_right_corner.v,xorigin,zorigin);
      if (dist_temp > boundL && dist_temp < boundR) {
        what_to_return += 2;
      }
    }
    return what_to_return;
  }
  
  void update() {
  }
  
  int draw_prep(boolean lock_angle) {
    j3d_obj.translate.set(x_tile*300+150,0,z_tile*300+150);
    j3d_obj.rotate_y = direction;
    if (lock_angle) {
      j3d_obj.oob_locking_angle = direction;
    } else {
      j3d_obj.oob_locking_angle = -1;
    }
    return 300*longness-150;
  }
  
  void draw_only() {
    int longness_temp = draw_prep(true);
  }
  
  void place_in_level(Level level_to_place_in) {
    level_to_place_in.terrain_in_level[x_tile][z_tile] = this;
  }
  
  void move(int x_tile_, int z_tile_) {//Used to allow more functionality when moving (for finish line).
    x_tile = x_tile_;
    z_tile = z_tile_;
  }
  
  void save_item(PrintWriter file_to_save) {
    file_to_save.println(object_type+","+x_tile+","+z_tile+","+longness+","+direction+","+variation+","+main_color);
  }
}



class Terrain_obj_straight extends Terrain_obj {
  Terrain_obj_straight(int x_tile_, int z_tile_, int longness_, float direction_, int variation_, int pointnumb) {
    super(x_tile_, z_tile_, longness_, direction_, variation_, pointnumb);
  }
  
  //This will someday be used to give the object multiple places in the array.
  /*void place_in_level(Level level_to_place_in) {
    int x_multiplier = 0;
    int y_multiplier = 0;
    if (direction == HALF_PI) {x_multiplier = -1;//Going left
    } else if (direction == PI) {y_multiplier = -1;//Going down
    } else if (direction == PI+HALF_PI) {x_multiplier = 1;//Going right
    } else {y_multiplier = 1;}//Going up
    for (int i=0; i<longness-1; i++) {
      level_to_place_in.terrain_in_level[x_tile+i*x_multiplier][z_tile+i*y_multiplier] = this;
    }
  }*/
}



class Terrain_obj_curved extends Terrain_obj {
  Terrain_obj_curved(int x_tile_, int z_tile_, int longness_, float direction_, int variation_, int pointnumb) {
    super(x_tile_, z_tile_, longness_, direction_, variation_, pointnumb);
  }
}




class Hill_straight extends Terrain_obj_straight {
  Hill_straight (int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_, 6);
    object_type = 1;
    main_color = color(0,128,0);
  }
  
  void update() {
    //If the car is touching the hill, push it back to previous position.
    for (int i = 0; i < cars.length; i = i+1) {
      int car_collide = collide_car_rect(-150, 150, 150, -100, 110, cars[i]);
      if (car_collide%4 > 0) {
        //If the car is touching the hill...
        if (((car_collide&4) == 4) != ((car_collide&8) == 8)) {
          //If it is in the top left but not top right or vice versa
          //It must be on the left or right
          cars[i].x = cars[i].xprevious;
        } else {
          //If it is in the top left and top right or vice versa
          //It must be on the top (or vice versa)
          cars[i].z = cars[i].zprevious;
        }
        cars[i].left_friction = 0.07;
        cars[i].right_friction = 0.07;
      }
    }
  }
  
  void draw_only() {
    int longness_temp = draw_prep(true);
    j3d_obj.persp(0,-100,longness_temp,points[0]);//The top part
    j3d_obj.persp(0,-100,-150,points[1]);
    
    j3d_obj.persp(-150,100,-150,points[2]);//The sides
    j3d_obj.persp(-150,100,longness_temp,points[3]);
    
    j3d_obj.persp(150,100,-150,points[4]);
    j3d_obj.persp(150,100,longness_temp,points[5]);
    fill(main_color);
    j3d_obj.quad_oob(points[0],points[1],points[2],points[3]);
    j3d_obj.quad_oob(points[0],points[1],points[4],points[5]);
    if (variation == 1) {
      fill(128,0,128);
      //rect_persp_x();
    }
  }
}


class Hill_corner extends Terrain_obj_straight {
  Hill_corner(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_, 7);
    object_type = 2;
    main_color = color(0,128,0);
  }
  
  void update() {
    //If the car is touching the hill, push it back to previous position.
    longness = 1;
    for (int i = 0; i < cars.length; i = i+1) {
      int car_collide = collide_car_rect(-150, 150, 150, -100, 110, cars[i]);
      if (car_collide%4 > 0) {
        //If the car is touching the hill...
        if (((car_collide&4) == 4) != ((car_collide&8) == 8)) {
          //If it is in the top left but not top right or vice versa
          //It must be on the left or right
          cars[i].x = cars[i].xprevious;
        } else {
          //If it is in the top left and top right or vice versa
          //It must be on the top (or vice versa)
          cars[i].z = cars[i].zprevious;
        }
        cars[i].left_friction = 0.07;
        cars[i].right_friction = 0.07;
      }
    }
  }
  
  void draw_only() {
    int longness_temp = draw_prep(false);
    if (j3d_obj.persp(0,0,0,null).size == 0.01) {
      return;
    }
    j3d_obj.persp(0,-100,0,points[0]);//Top center
    j3d_obj.persp(0,-100,-150,points[1]);
    j3d_obj.persp(-150,-100,0,points[2]);
    j3d_obj.persp(-150,100,-150,points[3]);//Inner corner
    j3d_obj.persp(150,100,-150,points[4]);
    j3d_obj.persp(150,100,150,points[5]);//Outer center corner
    j3d_obj.persp(-150,100,150,points[6]);
    fill(main_color);
    j3d_obj.quad_oob(points[0],points[1],points[4],points[5]);
    j3d_obj.quad_oob(points[0],points[2],points[6],points[5]);
    j3d_obj.quad_oob(points[0],points[1],points[3],points[3]);
    j3d_obj.quad_oob(points[0],points[2],points[3],points[3]);
    if (variation == 1) {
      
    }
  }
}


class Hill_end extends Terrain_obj_straight {
  Hill_end(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_,6);
    object_type = 4;
    main_color = color(0,128,0);
  }
  
  void update() {
    //If the car is touching the hill, push it back to previous position.
    longness = 1;
    for (int i = 0; i < cars.length; i = i+1) {
      int car_collide = collide_car_rect(-150, 150, 150, -100, 110, cars[i]);
      if (car_collide%4 > 0) {
        //If the car is touching the hill...
        if (((car_collide&4) == 4) != ((car_collide&8) == 8)) {
          //If it is in the top left but not top right or vice versa
          //It must be on the left or right
          cars[i].x = cars[i].xprevious;
        } else {
          //If it is in the top left and top right or vice versa
          //It must be on the top (or vice versa)
          cars[i].z = cars[i].zprevious;
        }
        cars[i].left_friction = 0.07;
        cars[i].right_friction = 0.07;
      }
    }
  }
  
  void draw_only() {
    int longness_temp = draw_prep(false);
    if (j3d_obj.persp(0,0,0,null).size == 0.01) {
      return;
    }
    j3d_obj.persp(0,-100,longness_temp-150,points[0]);//The top part
    j3d_obj.persp(0,-100,-150,points[1]);
    
    j3d_obj.persp(-150,100,-150,points[2]);//The sides
    j3d_obj.persp(-150,100,longness_temp,points[3]);
    
    j3d_obj.persp(150,100,-150,points[4]);
    j3d_obj.persp(150,100,longness_temp,points[5]);
    fill(main_color);
    j3d_obj.quad_oob(points[0],points[1],points[2],points[3]);
    j3d_obj.quad_oob(points[0],points[1],points[4],points[5]);
    j3d_obj.quad_oob(points[1],points[1],points[3],points[5]);
    //j3d_obj.triangle_persp(-150,100,150, 0,-100,0, 150,100,150);//The inner corner
    //The sides
    //j3d_obj.quad_persp(150,100,-150, 0,-100,-150, 0,-100,0, 150,100,150);
    //j3d_obj.quad_persp(-150,100,-150, 0,-100,-150, 0,-100,0, -150,100,150);
    if (variation == 1) {
    }
  }
}