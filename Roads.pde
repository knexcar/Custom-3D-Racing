//"Roads" file
class Road_straight extends Terrain_obj_straight {
  //Variations: 0=nothing,1=powerline,2=barriers
  Road_straight(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_,12);
    object_type = 11;
    main_color = color(128);
  }
  
  
  
  
  void update() {
    //If the car is on the road, make it have little friction.
    for (int i = 0; i < cars.length; i = i+1) {
      byte car_collide = collide_car_rect(-100, 100, 150, 90, 110, cars[i]);
      if ((car_collide & 1) == 1) {
        //If the left side of the car is on the road...
        cars[i].left_friction = 0.005;
        cars[i].ground_height = 100;
      }
      if ((car_collide & 2) == 2) {
        //If the right side of the car is on the road...
        cars[i].right_friction = 0.005;
        cars[i].ground_height = 100;
      }
    }
  }
  
  void draw_only() {
    //Draw a road — IN 3D!
    int longness_temp = draw_prep(true);
    //If both of the endpoints are out of bounds...
    j3d_obj.persp(0,0,-150,null);
    if (j3d_obj.t.size == 0.01) {
      j3d_obj.persp(0,0,longness_temp,null);
      if (j3d_obj.t.size == 0.01) {
        return;//Stop the function
      }
    }
    fill(main_color);
    //Outside points
    j3d_obj.persp(-100,100,-150,points[0]);//The roadbed
    j3d_obj.persp(-100,100,longness_temp,points[1]);
    j3d_obj.persp(100,100,longness_temp,points[2]);
    j3d_obj.persp(100,100,-150,points[3]);
    //outside lines points.
    j3d_obj.persp(-90,100,-150,points[4]);
    j3d_obj.persp(-90,100,longness_temp,points[5]);
    j3d_obj.persp(90,100,longness_temp,points[6]);
    j3d_obj.persp(90,100,-150,points[7]);
    //Inside Line Points
    j3d_obj.persp(5,100,-150,points[8]);
    j3d_obj.persp(-5,100,-150,points[9]);
    j3d_obj.persp(-5,100,longness_temp,points[10]);
    j3d_obj.persp(5,100,longness_temp,points[11]);
    //j3d_obj.persp(5,100,longness_temp,points[12]);
    //j3d_obj.persp(15,100,longness_temp,points[13]);
    //j3d_obj.persp(15,100,-150,points[14]);
    //j3d_obj.persp(5,100,-150,points[15]);
    //Roadbed
    j3d_obj.quad_oob(points[0], points[1], points[2], points[3]);
    fill(255);//Outside Lines
    j3d_obj.quad_oob(points[0], points[1], points[5], points[4]);
    j3d_obj.quad_oob(points[2], points[3], points[7], points[6]);
    fill(255,255,0);
    j3d_obj.quad_oob(points[8], points[9], points[10], points[11]);
    //j3d_obj.quad_oob(points[12], points[13], points[14], points[15]);
    
    /*
    if (variation == 1) {
      float x_temp;
      float x = 150;
      stroke(255);
      x_temp = x-15;
      j3d_obj.line_perspective(x_temp,-50,-150,x_temp,-25,-75,2);
      j3d_obj.line_perspective(x_temp,-25,-75,x_temp,-25,75,2);
      j3d_obj.line_perspective(x_temp,-25,75,x_temp,-50,150,2);
      x_temp = x-5;
      j3d_obj.line_perspective(x_temp,-50,-150,x_temp,-25,-75,2);
      j3d_obj.line_perspective(x_temp,-25,-75,x_temp,-25,75,2);
      j3d_obj.line_perspective(x_temp,-25,75,x_temp,-50,150,2);
      x_temp = x+5;
      j3d_obj.line_perspective(x_temp,-50,-150,x_temp,-25,-75,2);
      j3d_obj.line_perspective(x_temp,-25,-75,x_temp,-25,75,2);
      j3d_obj.line_perspective(x_temp,-25,75,x_temp,-50,150,2);
      x_temp = x+15;
      j3d_obj.line_perspective(x_temp,-50,-150,x_temp,-25,-75,2);
      j3d_obj.line_perspective(x_temp,-25,-75,x_temp,-25,75,2);
      j3d_obj.line_perspective(x_temp,-25,75,x_temp,-50,150,2);
      stroke(128,128,0);
      j3d_obj.line_perspective(x,100,-150,x,-75,-150,10);
      j3d_obj.line_perspective(x-20,-50,-150,x+20,-150,-75,5);
    } else if (variation == 2) {
      
    }*/
  }
}




class Road_curved extends Terrain_obj_curved {
  int numb_of_segments = 4;
  Road_curved(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_,6*(4+1));
    object_type = 12;
    main_color = color(128);
  }
  
  void update() {
    for (int i = 0; i < cars.length; i = i+1) {
      int car_collide = collide_car_arc(50+300*longness-300, 250+300*longness-300, 90, 110, cars[i]);
      if ((car_collide&1) == 1) {
        //If the left side of the car is on the road...
        cars[i].left_friction = 0.005;
        cars[i].ground_height = 100;
      }
      if ((car_collide&2) == 2) {
        //If the right side of the car is on the road...
        cars[i].right_friction = 0.005;
        cars[i].ground_height = 100;
      }
    }
  }
  
  void draw_only() {
    //Draw a road — IN 3D!
    int longness_temp = 300*longness-300;
    j3d_obj.translate.set(x_tile*300+150+(150+longness_temp)*sqrt(2)*cos(direction+5*PI/4),0,z_tile*300+150+(150)*sqrt(2)*sin(direction+5*PI/4));
    j3d_obj.rotate_y = 0;
    j3d_obj.oob_locking_angle = -1;
    //If the center is out of bounds... (only for small curves)
    if (longness == 1) {
      if (j3d_obj.persp(0,0,0,null).size == 0.01) {
        return;//Stop the function
      }
    }
    float direction_addition = HALF_PI/numb_of_segments;
    curved_points(direction, 0, longness_temp, direction_addition);
    for (int i=1; i<=numb_of_segments; i=i+1) {
      int six_i = 6*i;
      curved_points(direction+direction_addition*i, six_i, longness_temp, direction_addition);
      fill(main_color);
      j3d_obj.quad_oob(points[six_i],points[six_i+1],points[six_i-5],points[six_i-6]);//Roadbed
      fill(255);
      j3d_obj.quad_oob(points[six_i],points[six_i+2],points[six_i-4],points[six_i-6]);//Inside Line
      j3d_obj.quad_oob(points[six_i+1],points[six_i+3],points[six_i-3],points[six_i-5]);//Outside Line
      fill(255,255,0);
      j3d_obj.quad_oob(points[six_i+4],points[six_i+5],points[six_i-1],points[six_i-2]);//Center Line
      /*j3d_obj.translate.x = j3d_obj.camera.x;
      j3d_obj.translate.z = j3d_obj.camera.z;
      stroke(255,0,0);
      //line(j3d_obj.persp(0,100,0,null).u,j3d_obj.t.v,j3d_obj.persp(250*cos(j3d_obj.oob_locking_angle),100,250*sin(j3d_obj.oob_locking_angle),null).u,j3d_obj.t.v);
      //j3d_obj.line_perspective(250,100,250,250+250*cos(j3d_obj.oob_locking_angle),100,250+250*sin(j3d_obj.oob_locking_angle),5);
      noStroke();
      j3d_obj.translate.set(x_tile*300+150+(150+longness_temp)*sqrt(2)*cos(direction+5*PI/4),0,z_tile*300+150+(150)*sqrt(2)*sin(direction+5*PI/4));*/
    }
  }
  void curved_points(float angle, int index_to_start, float longness_temp, float direction_addition) {
    //See if the camera is coming one way or the other down the road (as out-of-bound points depend on this to align to the correct polygon)
    float difference_in_angle = abs((j3d_obj.camera_rotate_y%TWO_PI+TWO_PI)%TWO_PI+angle)%TWO_PI;
    if (difference_in_angle < HALF_PI || difference_in_angle > HALF_PI*3) { 
      j3d_obj.oob_locking_angle = angle+(direction_addition/2);
    } else j3d_obj.oob_locking_angle = angle-(direction_addition/2);
    float cos1 = cos(angle); float sin1 = sin(angle);
    j3d_obj.persp((50+longness_temp)*cos1,100,(50+longness_temp)*sin1,points[index_to_start]);//Inner Side
    j3d_obj.persp((250+longness_temp)*cos1,100,(250+longness_temp)*sin1,points[index_to_start+1]);//Outer Side
    j3d_obj.persp((60+longness_temp)*cos1,100,(60+longness_temp)*sin1,points[index_to_start+2]);//Inner Whiteness
    j3d_obj.persp((240+longness_temp)*cos1,100,(240+longness_temp)*sin1,points[index_to_start+3]);//Outer Whiteness
    j3d_obj.persp((145+longness_temp)*cos1,100,(145+longness_temp)*sin1,points[index_to_start+4]);//Inner Center
    j3d_obj.persp((155+longness_temp)*cos1,100,(155+longness_temp)*sin1,points[index_to_start+5]);//Outer Center
    //if (points[index_to_start+4].size == 0.01 && (points[max(index_to_start-2,2)].size != 0.01 || points[min(index_to_start+10,numb_of_segments*6-2)].size != 0.01)) {
    //  println(angle+" vs "+(j3d_obj.camera_rotate_y%TWO_PI+TWO_PI)%TWO_PI+" = "+abs((j3d_obj.camera_rotate_y%TWO_PI+TWO_PI)%TWO_PI+angle));
    //}
  }
}




class Road_T extends Terrain_obj_curved {
  int numb_of_segments = 4;
  Road_T(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_,6*(4+1));
    object_type = 13;
    main_color = color(128);
  }
  
  void update() {
    for (int i = 0; i < cars.length; i = i+1) {
      byte car_collide = collide_car_rect(-150, 100, 150, 90, 110, cars[i]);
      if ((car_collide&1) == 1) {
        //If the left side of the car is on the road...
        cars[i].left_friction = 0.005;
        cars[i].ground_height = 100;
        //println("Car colliding left");
      }
      if ((car_collide&2) == 2) {
        //If the right side of the car is on the road...
        cars[i].right_friction = 0.005;
        cars[i].ground_height = 100;
        //println("Car colliding right");
      }
      if (car_collide == 0) {
        //println("No collision");
      }
    }
  }
  
  void draw_only() {
    //Draw a road — IN 3D!
    
    //First, draw the straight section
    int longness_temp = draw_prep(false);
    //j3d_obj.translate.set(x_tile*300+150,0,z_tile*300+150);
    //j3d_obj.rotate_y = 0;
    //j3d_obj.oob_locking_angle = -1;
    //If the center is out of bounds... (only for small curves)
    if (longness == 1) {
      if (j3d_obj.persp(0,0,0,null).size == 0.01) {
        return;//Stop the function
      }
    }
    fill(main_color);
    //2+3n are the points that can be used
    j3d_obj.persp(-100,100,-150,points[2]);//The roadbed
    j3d_obj.persp(-100,100,longness_temp,points[5]);
    j3d_obj.persp(100,100,longness_temp,points[8]);
    j3d_obj.persp(100,100,-150,points[11]);
    j3d_obj.quad_oob(points[2], points[5], points[8], points[11]);
    //outside lines points.
    j3d_obj.persp(90,100,longness_temp,points[14]);
    j3d_obj.persp(90,100,-150,points[17]);
    fill(255);//Outside Lines
    j3d_obj.quad_oob(points[8], points[11], points[17], points[14]);
    
    
    
    //Second find the points of the 1st curve:
    j3d_obj.reset_transforms();
    longness_temp = 300*longness-300;//Prepares the variable for curve drawing.
    j3d_obj.translate.set(x_tile*300+150+(150+longness_temp)*sqrt(2)*cos(direction+5*PI/4),0,z_tile*300+150+(150)*sqrt(2)*sin(direction+5*PI/4));
    float direction_addition = HALF_PI/numb_of_segments;
    //curved_points(direction, 0, longness_temp, direction_addition);
    for (int i=0; i<=numb_of_segments; i=i+1) {
      int six_i = 6*i;
      curved_points(direction+direction_addition*i, six_i, longness_temp, direction_addition);
    }
    
    //Third, find the points of the 2nd curve:
    j3d_obj.translate.set(x_tile*300+150+(150+longness_temp)*sqrt(2)*cos(direction+5*PI/4-HALF_PI),0,z_tile*300+150+(150)*sqrt(2)*sin(direction+5*PI/4-HALF_PI));
    //curved_points(direction+HALF_PI, 3, longness_temp, direction_addition);
    for (int i=0; i<=numb_of_segments; i=i+1) {
      int six_i = 6*i;
      curved_points(direction-direction_addition*i, 3+six_i, longness_temp, -direction_addition);
    }
    
    //Finally, draw both points together to make the outlet.
    for (int i=1; i<=numb_of_segments; i=i+1) {
      int six_i = 6*i;
      fill(main_color);
      j3d_obj.quad_oob(points[six_i],points[six_i+3],points[six_i-3],points[six_i-6]);//Roadbed
      fill(255);
      j3d_obj.quad_oob(points[six_i],points[six_i+1],points[six_i-5],points[six_i-6]);//Line 1
      j3d_obj.quad_oob(points[six_i+3],points[six_i+4],points[six_i-2],points[six_i-3]);//Line 2
    }
  }
  
  void curved_points(float angle, int index_to_start, float longness_temp, float direction_addition) {
    //See if the camera is coming one way or the other down the road (as out-of-bound points depend on this to align to the correct polygon)
    float difference_in_angle = abs((j3d_obj.camera_rotate_y%TWO_PI+TWO_PI)%TWO_PI+angle)%TWO_PI;
    if (difference_in_angle < HALF_PI || difference_in_angle > HALF_PI*3) { 
      j3d_obj.oob_locking_angle = angle+(direction_addition/2);
    } else j3d_obj.oob_locking_angle = angle-(direction_addition/2);
    float cos1 = cos(angle); float sin1 = sin(angle);
    j3d_obj.persp((50+longness_temp)*cos1,100,(50+longness_temp)*sin1,points[index_to_start]);//Inner Side
    j3d_obj.persp((60+longness_temp)*cos1,100,(60+longness_temp)*sin1,points[index_to_start+1]);//Inner Whiteness
    //j3d_obj.persp((250+longness_temp)*cos1,100,(250+longness_temp)*sin1,points[index_to_start+1]);//Outer Side
    //j3d_obj.persp((240+longness_temp)*cos1,100,(240+longness_temp)*sin1,points[index_to_start+3]);//Outer Whiteness
    //j3d_obj.persp((145+longness_temp)*cos1,100,(145+longness_temp)*sin1,points[index_to_start+4]);//Inner Center
    //j3d_obj.persp((155+longness_temp)*cos1,100,(155+longness_temp)*sin1,points[index_to_start+5]);//Outer Center
    //if (points[index_to_start+4].size == 0.01 && (points[max(index_to_start-2,2)].size != 0.01 || points[min(index_to_start+10,numb_of_segments*6-2)].size != 0.01)) {
    //  println(angle+" vs "+(j3d_obj.camera_rotate_y%TWO_PI+TWO_PI)%TWO_PI+" = "+abs((j3d_obj.camera_rotate_y%TWO_PI+TWO_PI)%TWO_PI+angle));
    //}
  }
}




class Finish_line extends Terrain_obj_straight {
  Road_straight my_road;
  
  Finish_line(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_,4);
    object_type = 16;
    main_color = color(128);
    my_road = new Road_straight(x_tile,z_tile,1,direction,variation);
  }
  
  void prepare_cars() {
    for (int i = 0; i < cars.length; i = i+1) {
      cars[i].x = x_tile*300+100+100*(i%2);
      cars[i].z = z_tile*300+50-100*floor(i/2);
      cars[i].facing_direction = direction+HALF_PI;
      cars[i].numb_of_laps = 0;
      cars[i].respawn = this;
    }
  }
  
  void respawn_car(Car silly_loser) {
    silly_loser.x = x_tile*300+150;
    silly_loser.y = 75;
    silly_loser.z = z_tile*300+50;
    silly_loser.facing_direction = direction+HALF_PI;
    silly_loser.speed = 0;
    silly_loser.vspeed = 0;
    silly_loser.numb_of_laps -= 1;
  }
  
  void update() {
    float xbound1; float zbound1;//Bottom left (negatives)
    float xbound2; float zbound2;//Top right (positives)
    //Set the bounds to the basic square.
    xbound1 = x_tile*300; xbound2 = x_tile*300+300;
    zbound1 = z_tile*300; zbound2 = z_tile*300+300;
    //If the car is within the finish line...
    for (int i = 0; i < cars.length; i = i+1) {
      if (cars[i].x > xbound1 && cars[i].x < xbound2 && cars[i].z > zbound1 && cars[i].z < zbound2) {
        if (cars[i].z > zbound1+150 && cars[i].zprevious < zbound1+150) {
          cars[i].numb_of_laps += 1;
          cars[i].respawn = this;
        }
        if (cars[i].z < zbound1+150 && cars[i].zprevious > zbound1+150) {
          cars[i].numb_of_laps -= 1;
        }
      }
      //If there is a winner...
      if (cars[i].numb_of_laps > 3) {
        level_var.win(i);
      }
    }
    my_road.update();
  }
  
  void draw_only() {
    draw_only(true);
  }
  
  void draw_only(boolean draw_road) {
    if (draw_road) {
      my_road.main_color = main_color;
      my_road.draw_only();
    }
    draw_prep(false);
    stroke(0);//The posts
    j3d_obj.line_perspective(-150,100,0,-150,-130,0,5);
    j3d_obj.line_perspective(150,100,0,150,-130,0,5);
    
    j3d_obj.persp(-150,-70,0,points[0]);
    j3d_obj.persp(150,-70,0,points[1]);
    j3d_obj.persp(150,-130,0,points[2]);
    j3d_obj.persp(-150,-130,0,points[3]);
    //for (int i=1; i<=10; i=i+1) {}
    
    fill(255);//the flag
    noStroke();
    j3d_obj.quad_oob(points[0],points[1],points[2],points[3]);
    
    fill(0);//The checkers
    /*j3d_obj.rect_persp_x(-150,-70,0,-120,-100,0);
    j3d_obj.rect_persp_x(-90,-70,0,-60,-100,0);
    j3d_obj.rect_persp_x(-30,-70,0,0,-100,0);
    j3d_obj.rect_persp_x(30,-70,0,60,-100,0);
    j3d_obj.rect_persp_x(90,-70,0,120,-100,0);
    
    j3d_obj.rect_persp_x(-120,-100,0,-90,-130,0);
    j3d_obj.rect_persp_x(-60,-100,0,-30,-130,0);
    j3d_obj.rect_persp_x(0,-100,0,30,-130,0);
    j3d_obj.rect_persp_x(60,-100,0,90,-130,0);
    j3d_obj.rect_persp_x(120,-100,0,150,-130,0);
    */
  }
  
  void move(int x_tile_, int z_tile_) {//Used to allow more functionality when moving (for finish line).
    x_tile = x_tile_;
    z_tile = z_tile_;
    my_road.move(x_tile, z_tile);
  }
}



class Mud_pit extends Terrain_obj_straight {
  Mud_pit(int x_tile_, int z_tile_, int longness_, float direction_, int variation_) {
    super(x_tile_, z_tile_, longness_, direction_, variation_,8);
    object_type = 21;
    main_color = color(128,128,0);
  }
  
  void update() {
    //If the car is in the pit, it gets lots of friction.
    for (int i = 0; i < cars.length; i = i+1) {
      byte car_collide = collide_car_rect(-100, 100, 100, 90, 110, cars[i]);
      if ((car_collide & 1) == 1) {
        //If the left side of the car is on the road...
        cars[i].left_friction = 0.09;
        cars[i].ground_height = 100;
      }
      if ((car_collide & 2) == 2) {
        //If the right side of the car is on the road...
        cars[i].right_friction = 0.09;
        cars[i].ground_height = 100;
      }
    }
  }
  
  void draw_only() {
    int longness_temp = draw_prep(true);
    j3d_obj.persp(-100,100,-100,points[0]);//The pit
    j3d_obj.persp(100,100,-100,points[1]);
    j3d_obj.persp(100,100,longness_temp-50,points[2]);
    j3d_obj.persp(-100,100,longness_temp-50,points[3]);
    
    j3d_obj.persp(-50,100,-50,points[4]);//Center part
    j3d_obj.persp(50,100,-50,points[5]);
    j3d_obj.persp(50,100,longness_temp-100,points[6]);
    j3d_obj.persp(-50,100,longness_temp-100,points[7]);
    fill(main_color);
    j3d_obj.quad_oob(points[0],points[1],points[2],points[3]);
    fill(red(main_color)/2,green(main_color)/2,blue(main_color)/2,alpha(main_color));
    j3d_obj.quad_oob(points[4],points[5],points[6],points[7]);
  }
}