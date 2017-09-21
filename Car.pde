//"Car" file
class Car {
  float x;
  float y;
  float z;
  float xprevious;
  float zprevious;
  float car_width;

  float speed;
  float speed_direction;
  float vspeed;
  float facing_direction;
  float facing_direction_speed;
  
  color car_color;
  float accelpower;
  float max_accel;
  
  //These variables involve the "wheels".
  float wheel_speed;
  float max_speed;
  float turnpower;
  float turndirection;
  
  float left_friction;
  float right_friction;
  Jvect2 top_left_corner;
  Jvect2 top_right_corner;
  int numb_of_laps;
  boolean can_move;
  boolean skidding;
  float ground_height;
  
  Jvect2_ext[] points;
  Finish_line respawn;
  
  Car(float x_, float z_, color car_color_) {
    x = x_;
    y = 100;
    z = z_;
    car_width = 20;
    speed = 0;
    vspeed = 0;
    max_speed = 10;
    max_accel = 0.1;
    car_color = car_color_;
    speed_direction = HALF_PI;
    facing_direction = HALF_PI;
    accelpower = 0;
    turnpower = 0;
    turndirection = 0;
    numb_of_laps = 0;
    can_move = false;
    skidding = false;
    top_left_corner = new Jvect2(0,0);
    top_right_corner = new Jvect2(0,0);
    points = new Jvect2_ext[16];
    for (int i=0; i<16;i=i+1) {
      points[i] = new Jvect2_ext(0,0,1);
    }
    ground_height = 100;
  }
  
  void update() {
    //Code for controlling the car via arrow keys.
    if (can_move) {
      //Code for the wheel speed...
      if (accelpower > 0) {//Acceleration at a given speed is a linerar funciton, y=mx+b=(-b/max_speed)x+b
        wheel_speed += accelpower*(-max_accel/max_speed*speed+max_accel)*change_in_time;
        if (wheel_speed > max_speed) {
          wheel_speed = max_speed;
        }
      } else {
        wheel_speed += accelpower*0.1;
        if (wheel_speed < 0) {
          wheel_speed = 0;
        }
      }
      
      //Code for the wheel direction...
      float return_speed = 0.0005;
      float max_turning = 0.0005*(15-wheel_speed);
      turndirection += turnpower*(0.00002*(15-wheel_speed)+return_speed)*change_in_time;
      if (turndirection > max_turning) {
        turndirection = max_turning;
      } else if (turndirection < -max_turning) {
        turndirection = -max_turning;
      }
      if (turndirection > return_speed) {
        turndirection -= return_speed;
      } else if (turndirection < -return_speed) {
        turndirection += return_speed;
      } else {
        turndirection = 0;
      }
      //println(dist(wheel_speed,0,cos(turndirection*10)*wheel_speed, sin(turndirection*10)*wheel_speed));
      /*if (dist(wheel_speed,0,cos(turndirection*10)*wheel_speed, sin(turndirection*10)*wheel_speed) > 0.3) {//If the car skids...
        skidding = true;
      } */
      if (speed == 0) {
        skidding = false;
      }
      if (!skidding) {
        speed = wheel_speed;
        facing_direction_speed = turndirection*speed;
      }
      
      if (y < ground_height) {
        vspeed = vspeed+0.1*change_in_time;
        y = y+vspeed*change_in_time;
        if (y > 500) {
          respawn.respawn_car(this);
        }
      } else {
        y = ground_height;
        vspeed = 0;
      }
    }
    
    //Code to slow the car due to friction.
    float total_friction = (left_friction+right_friction)/2;
    if (skidding) {//If it is skidding, there is more friction.
      total_friction = 0.05+total_friction/2;
    }
    speed -= total_friction*sqrt(speed)*change_in_time;
    if (speed < 0) {speed = 0;}
    if (!skidding) {
      speed_direction = facing_direction;
    } else {//If the catr is skidding, the facing_direction slows down.
      if (facing_direction_speed > total_friction/100) {
        facing_direction_speed -= total_friction/100;
      } else if (facing_direction_speed < -total_friction/100) {
        facing_direction_speed += total_friction/100;
      } else {
        facing_direction_speed = 0;
      }
    }
    wheel_speed = speed;
    
    //Add stuff to the speeds, update the final physics stuff. 
    xprevious = x;
    zprevious = z;
    x += speed*cos(speed_direction)*change_in_time;
    z += speed*sin(speed_direction)*change_in_time;
    facing_direction += facing_direction_speed*change_in_time;
    //Thses are the corners for which the friction is calculated.
    //As for now, they are in the center, rather than the top.
    j3d_obj.rotate_point(25,car_width,facing_direction,top_left_corner);
    top_left_corner.add(x,z);
    j3d_obj.rotate_point(25,-car_width,facing_direction,top_right_corner);
    top_right_corner.add(x,z);
  }
  void update_camera() {
    j3d_obj.camera.set(x-150*cos(speed_direction), 0, z-150*sin(speed_direction));
    j3d_obj.camera_rotate_y = HALF_PI-speed_direction;
  }
  
  void draw_only() {
    j3d_obj.translate.set(x,y,z);
    j3d_obj.rotate_y = facing_direction;
    j3d_obj.oob_locking_angle = -1;
    
    j3d_obj.persp(-20,-5,-car_width,points[0]);//Body Bottom corners
    j3d_obj.persp(-20,-5,car_width,points[1]);
    j3d_obj.persp(70,-5,-car_width,points[2]);
    j3d_obj.persp(70,-5,car_width,points[3]);
    j3d_obj.persp(-20,-15,-car_width,points[4]);//Body Top corners
    j3d_obj.persp(-20,-15,car_width,points[5]);
    j3d_obj.persp(70,-15,-car_width,points[6]);
    j3d_obj.persp(70,-15,car_width,points[7]);
    j3d_obj.persp(50,-15,-car_width,points[8]);//Cab Bottom corners
    j3d_obj.persp(50,-15,car_width,points[9]);
    j3d_obj.persp(0,-15,-car_width,points[10]);
    j3d_obj.persp(0,-15,car_width,points[11]);
    j3d_obj.persp(45,-25,-car_width,points[12]);//Cab Top corners
    j3d_obj.persp(45,-25,car_width,points[13]);
    j3d_obj.persp(5,-25,-car_width,points[14]);
    j3d_obj.persp(5,-25,car_width,points[15]);
    
    noStroke();
    fill(car_color);
    j3d_obj.quad_oob(points[0], points[2], points[6], points[4]);//Left Side
    j3d_obj.quad_oob(points[1], points[3], points[7], points[5]);//Right Side
    j3d_obj.quad_oob(points[0], points[1], points[5], points[4]);//Back
    j3d_obj.quad_oob(points[2], points[3], points[7], points[6]);//Front
    j3d_obj.quad_oob(points[4], points[5], points[7], points[6]);//Top
    fill(192,255,255);
    j3d_obj.quad_oob(points[8], points[10], points[14], points[12]);//Left Side
    j3d_obj.quad_oob(points[9], points[11], points[15], points[13]);//Right Side
    j3d_obj.quad_oob(points[8], points[9], points[13], points[12]);//Back
    j3d_obj.quad_oob(points[10], points[11], points[15], points[14]);//Front
    fill(car_color);
    j3d_obj.quad_oob(points[12], points[13], points[15], points[14]);//Top
  }
}