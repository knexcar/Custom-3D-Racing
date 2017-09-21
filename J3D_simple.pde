//"J3D" file
class J3D_simple {
  float fov = 0.5;
  //The coordinates of the "camera"/viewpoint
  float camera_x;
  float camera_y;
  float camera_z;
  float camera_rotate_x;
  float camera_rotate_y;
  float rotate_y;//in radians, applied around origin. Rotates the current polygons.
  float translate_x;//Where to move points after rotation.
  float translate_y;
  float translate_z;
  float xt;//Temporary variables for the perspective function
  float yt;
  float sizet;
  float oob_locking_angle;//If a point is behind the camera, it will be...
  //moved to in front of the camera while locked to this angle.
  int window_xsize;//For split screen and the oob functions.
  int window_xoffset;//The x-offset of the views, for split screen.

  J3D_simple() {
    camera_x = 0;
    camera_y = 0;
    camera_z = 0;
    rotate_y = 0;
    camera_rotate_x = 0;
    camera_rotate_y = 0;
    window_xsize = width;
    window_xoffset = 0;
    reset_transforms();
    xt = 0;
    yt = 0;
    sizet = 0;
    oob_locking_angle = 0;
  }
  
  void reset_transforms() {
    translate_x = 0;
    translate_y = 0;
    translate_z = 0;
    rotate_y = 0;
    return;
  }
  
  //Functions for drawing shapes in 3D.
  void triangle_persp(float x1,float y1,float z1,float x2,float y2,float z2,float x3,float y3,float z3) {
    triangle_oob(persp(x1,y1,z1),yt, persp(x2,y2,z2),yt, persp(x3,y3,z3),yt);
  }
  
  void quad_persp(float x1,float y1,float z1,float x2,float y2,float z2,float x3,float y3,float z3, float x4,float y4,float z4) {
    quad_oob(persp(x1,y1,z1),yt, persp(x2,y2,z2),yt, persp(x3,y3,z3),yt, persp(x4,y4,z4),yt);
  }
  
  void rect_persp_x(float x1,float y1,float z1, float x2,float y2,float z2) {
    //The "y" and "z" are the same number.
    //This polygon rotates on the x-axis.
    quad_oob(persp(x1,y1,z1),yt, persp(x1,y2,z2),yt, persp(x2,y2,z2),yt, persp(x2,y1,z1),yt);
  }
  
  void rect_persp_y(float x1,float y1,float z1, float x2,float y2,float z2) {
    //The "x" and "z" are the same number.
    //This polygon rotates on the y-axis.
    quad_oob(persp(x1,y1,z1),yt, persp(x2,y1,z2),yt, persp(x2,y2,z2),yt, persp(x1,y2,z1),yt);
  }
  
  void rect_persp_z(float x1,float y1,float z1, float x2,float y2,float z2) {
    //The "x" and "z" are the same number.
    //This polygon rotates on the z-axis.
    quad_oob(persp(x1,y1,z1),yt, persp(x2,y2,z1),yt, persp(x2,y2,z2),yt, persp(x1,y1,z2),yt);
  }
  
  void line_perspective(float x1, float y1, float z1,float x2, float y2, float z2, float size) {
    persp(x1,y1,z1);
    strokeWeight(sizet*size);
    line_oob(xt,yt,persp(x2,y2,z2),yt);
  }
  
  
  //This function takes a 3D point, and interpolates it onto the 2D screen.
  float persp(float x, float y, float z) {//Returns the 2D X value of the point, sets temp vars to y and size.
    float zdiff = 0;
    if (rotate_y != 0) {
      x = rotate_point(x,z,rotate_y);
      z = yt;
    }
    x = x+translate_x-camera_x;
    y = y+translate_y-camera_y;
    z = z+translate_z-camera_z;
    if (camera_rotate_y != 0) {
      x = rotate_point(x,z,camera_rotate_y);
      z = yt;
    }
    if (camera_rotate_x != 0) {
      y = rotate_point(y,z,camera_rotate_x);
      z = yt;
    }
    sizet = fov/(z)*window_xsize;
    //If the point is behind the camera...
    if (z <= 0) {
      //Move the point to 1 unit in front of the camera
      zdiff = 1-z;
      sizet = fov*window_xsize*z;
      z = 1;
      //This code will make the point move on the oob_locking_angle.
      if (oob_locking_angle != -1) {
        x = x+zdiff*tan(oob_locking_angle + camera_rotate_y);
      }
    }
    sizet = fov/(z)*height;
    yt = ((y)*sizet+height/2);
    xt = window_xoffset+((x)*sizet+window_xsize/2);
    if (z == 1) {
      sizet = 0.01;
    }
    return xt;
  }
  
  
  void line_oob(float x1,float y1,float x2,float y2) {
    //A function to draw a line that, if it crosses a vertical line, is drawn in such a way that nothing
    //is drawn on the other side. 
    boolean error1 = false;
    boolean error2 = false;
    float xtemp; float ytemp; boolean errortemp;
    float window_border = window_xsize+window_xoffset;
    //Make the problem points easy to access
    if (x1 > window_border) {error1 = true;}
    if (x2 > window_border) {error2 = true;}
    if (error1 && error2) {
      return;//If it is completely out of bounds, stop the function.
    }
    if (!error1 && !error2) {
      line(x1,y1,x2,y2);
      return;//If it is completely in bounds, draw and stop the function.
    }
    //"Move" the points so error1 is always true, and error2 is alway false.
    if (!error1) {//Move the points one to the left
      xtemp=x1; ytemp=y1; x1=x2; y1=y2; x2=xtemp; y2=ytemp;
      errortemp=error1; error1=error2; error2=errortemp;
    }
    //Assuming error1 is true, and error3 is false
    if (error1) {
      //If one point (1) is in error...
      //Create a triangle
      line(x2,y2,window_border,intersect_lwv(x1,x2,y1,y2,window_border));
    }
  }
  
  void triangle_oob(float x1,float y1,float x2,float y2,float x3,float y3) {
    //A function to draw a triangle that, if it crosses a line, is drawn in such a way that nothing
    //is drawn on the other side. 
    boolean error1 = false;
    boolean error2 = false;
    boolean error3 = false;
    float xtemp; float ytemp; boolean errortemp;
    float window_border = window_xsize+window_xoffset;
    //Make the problem points easy to access
    if (x1 > window_border) {error1 = true;}
    if (x2 > window_border) {error2 = true;}
    if (x3 > window_border) {error3 = true;}
    if (error1 && error2 && error3) {
      return;//If it is completely out of bounds, stop the function.
    }
    if (!error1 && !error2 && !error3) {
      triangle(x1,y1,x2,y2,x3,y3);
      return;//If it is completely in bounds, draw and stop the function.
    }
    //"Move" the points so error1 is always true, and error3 is alway false.
    if (!error1) {//Move the points one to the left
      xtemp=x1; ytemp=y1; x1=x2; y1=y2; x2=x3; y2=y3; x3=xtemp; y3=ytemp;
      errortemp=error1; error1=error2; error2=error3; error3=errortemp;
    }
    if (!error1) {//Move the points one to the left
      xtemp=x1; ytemp=y1; x1=x2; y1=y2; x2=x3; y2=y3; x3=xtemp; y3=ytemp;
      errortemp=error1; error1=error2; error2=error3; error3=errortemp;
    }
    if (error3) {//Move the points one to the right
      xtemp=x3; ytemp=y3; x3=x2; y3=y2; x2=x1; y2=y1; x1=xtemp; y1=ytemp;
      errortemp=error3; error3=error2; error2=error1; error1=errortemp;
    }
    //Assuming error1 is true, and error3 is false
    if (error2) {
      //If two points (1,2) are in error...
      //Create a triangle
      triangle(window_border,intersect_lwv(x1,x3,y1,y3,window_border), window_border,intersect_lwv(x2,x3,y2,y3,window_border), x3,y3);
    } else {//If one point (1) is in error...
      //Draw a quad
      quad(window_border,intersect_lwv(x1,x2,y1,y2,window_border), window_border,intersect_lwv(x1,x3,y1,y3,window_border), x3,y3, x2,y2);
    }
  }
  
  void quad_oob(float x1,float y1,float x2,float y2,float x3,float y3,float x4,float y4) {
    //A function to draw a quad that, if it crosses a line, is drawn in such a way that nothing
    //is drawn on the other side. 
    boolean error1 = false;
    boolean error2 = false;
    boolean error3 = false;
    boolean error4 = false;
    float xtemp; float ytemp; boolean errortemp;
    float window_border = window_xsize+window_xoffset;
    //Make the problem points easy to access
    if (x1 > window_border) {error1 = true;}
    if (x2 > window_border) {error2 = true;}
    if (x3 > window_border) {error3 = true;}
    if (x4 > window_border) {error4 = true;}
    if (error1 && error2 && error3 && error4) {
      return;//If it is completely out of bounds, stop the function.
    }
    if (!error1 && !error2 && !error3 && !error4) {
      quad(x1,y1,x2,y2,x3,y3,x4,y4);
      return;//If it is completely in bounds, draw and stop the function.
    }
    //"Move" the points so error1 is always true, and error4 is alway false.
    if (!error1) {//Move the points one to the left
      xtemp=x1; ytemp=y1; x1=x2; y1=y2; x2=x3; y2=y3; x3=x4; y3=y4; x4=xtemp; y4=ytemp;
      errortemp=error1; error1=error2; error2=error3; error3=error4; error4=errortemp;
    }
    if (!error1) {//Move the points one to the left
      xtemp=x1; ytemp=y1; x1=x2; y1=y2; x2=x3; y2=y3; x3=x4; y3=y4; x4=xtemp; y4=ytemp;
      errortemp=error1; error1=error2; error2=error3; error3=error4; error4=errortemp;
    }
    if (!error1) {//Move the points one to the left
      xtemp=x1; ytemp=y1; x1=x2; y1=y2; x2=x3; y2=y3; x3=x4; y3=y4; x4=xtemp; y4=ytemp;
      errortemp=error1; error1=error2; error2=error3; error3=error4; error4=errortemp;
    }
    if (error4) {//Move the points one to the right
      xtemp=x4; ytemp=y4; x4=x3; y4=y3; x3=x2; y3=y2; x2=x1; y2=y1; x1=xtemp; y1=ytemp;
      errortemp=error4; error4=error3; error3=error2; error2=error1; error1=errortemp;
    }
    if (error4) {//Move the points one to the right
      xtemp=x4; ytemp=y4; x4=x3; y4=y3; x3=x2; y3=y2; x2=x1; y2=y1; x1=xtemp; y1=ytemp;
      errortemp=error4; error4=error3; error3=error2; error2=error1; error1=errortemp;
    }
    //Assuming error1 is true, and error4 is false
    if (error2) {
      if (error3) {//If three points (1,2,3) are in error...
        //Create a triangle
        triangle(window_border,intersect_lwv(x1,x4,y1,y4,window_border), window_border,intersect_lwv(x3,x4,y3,y4,window_border), x4,y4);
      } else {//If two points (1, 2) are in error...
        //Draw a quad
        quad(window_border,intersect_lwv(x1,x4,y1,y4,window_border), window_border,intersect_lwv(x2,x3,y2,y3,window_border), x3,y3, x4,y4);
      }
    } else {//If only one point (1) is in error...
      //Draw a pentagon using a quad and triangle
      ytemp = intersect_lwv(x1,x2,y1,y2,window_border);
      quad(window_border,ytemp, x2,y2, x3,y3, x4,y4);
      triangle(window_border,ytemp, window_border,intersect_lwv(x1,x4,y1,y4,window_border), x4,y4);
    }
  }
  
  void polygon_oob(float[] xa, float[] ya) {
    //A function to draw a polygon that, if it crosses a line, is drawn in such a way that nothing
    //is drawn on the other side.
    boolean[] error = new boolean[xa.length];
    float xtemp; float ytemp; boolean errortemp;
    float window_border = window_xsize+window_xoffset;
    int number_of_true_points = 0;
    for (int i = 0; i < xa.length; i = i+1) {//Check each error...
      if (xa[i] > window_border) {
        error[i] = true;
      } else {
        error[i] = false;
        number_of_true_points += 1;
      }
    }
    if (number_of_true_points == 0) {return;}
    if (number_of_true_points == xa.length) {
      beginShape();
      for (int i = 0; i < xa.length; i = i+1) {//For each point...
        vertex(xa[i],ya[i]);
      }
      endShape();
      return;
    }
    
    //"Move" the points so error[0] is always true, and error[i] is alway false.
    //First, find out how much to move them.
    int how_much_to_move = 0;
    for (int i = 0; i < xa.length-1; i = i+1) {//Check each error...
      if (!error[0]) {
        //Move them to the left.
        xtemp=xa[0]; ytemp=ya[0]; errortemp=error[0];
        for (int j = 0; j < xa.length-1; j = j+1) {
          xa[j] = xa[j+1]; ya[j] = ya[j+1]; error[j] = error[j+1];
        }
        xa[xa.length-1]=xtemp; ya[ya.length-1]=ytemp;
        error[error.length-1]=errortemp;
      }
    }
    for (int i = 0; i < xa.length-2; i = i+1) {//Check each error...
      if (error[error.length-1]) {
        //Move them to the right.
        xtemp=xa[xa.length-1];
        ytemp=ya[ya.length-1];
        errortemp=error[error.length-1];
        for (int j = xa.length-1; j > 0; j = j-1) {
          xa[j] = xa[j-1]; ya[j] = ya[j-1]; error[j] = error[j-1];
        }
        xa[0]=xtemp; ya[0]=ytemp; error[0]=errortemp;
      }
    }
    beginShape();
    //Find the intersection using the first error.
    vertex(window_border,intersect_lwv(xa[0],xa[xa.length-1],ya[0],ya[ya.length-1],window_border));
    //Find the intersection using the last error.
    vertex(window_border,intersect_lwv(xa[number_of_true_points],xa[number_of_true_points-1],ya[number_of_true_points],ya[number_of_true_points-1],window_border));
    for (int i = number_of_true_points; i < xa.length; i = i+1) {//For each point after all the false ones...
      vertex(xa[i],ya[i]);
    }
    endShape();
    return;
  }
  
  float rotate_point(float x, float y, float radians) {
    float distance = dist(0,0,x,y);
    if (distance > 0) {  
      float angle = acos(x/distance);
      if (y < 0) {
        angle = TWO_PI-angle;
      }
      xt = distance*cos(angle+radians);
      yt = distance*sin(angle+radians);
      return xt;
    } else {
      xt = x; yt = y;
      return xt;
    }
  }
  
  float intersect_lwv(float x1, float x2, float y1, float y2, float vertical_line) {
    //Takes a line from 2 points, and an x-value of a vertical line, and intersects them.
    //It returns the y-value of the intersect point.
    return ((y2-y1)/ (x2-x1)*(vertical_line-x1)+y1);
  }
}




//Diamond code for level drawing
/*//This function works by going in a diamond shape. Starting from the left, it goes CLOCKWISE. At the far left, it gones one in to complete a smaller diamond.
    int origin_x = int(j3d_obj.camera.x/300);
    int origin_z = int(j3d_obj.camera.z/300);
    //print(origin_x); print(","); println(origin_z);
    int radius = 8;//Draw Distance
    //Radius used to become the largest distance from the origin to the border.
    //These variables are absolute.
    int current_x = origin_x-radius;//Start at the left
    int current_z = origin_z;
    //+- is down/up, 2=right, 3=left
    int direction = -2;//Go up/right.
    
    for (; radius > 0;) {
      //print(current_x); print(","); print(current_z); print(","); println(radius);
      if (current_x >= 0 && current_x < level_width) {
        if (current_z >= 0 && current_z < level_height) {
          if (terrain_in_level[current_x][current_z] != null) {
            terrain_in_level[current_x][current_z].draw_only();
          }
        }
      }
      current_z += abs(direction)/direction;
      if (abs(direction) == 2) {
         current_x += 1;//Go right
      } else if (abs(direction) == 3) {
        current_x -= 1;//Go left
      }
      if (abs(current_x-origin_x) == radius) {//At the edge on the side
        if (direction == 2) {//If it is coming down/right
          direction = 3;//Go down/left
        } else {//If it is coming up/left
          direction = -2;
          radius--;//On the far left, the radius is decreased.
          current_x += 1;
        }
      } else if (abs(current_z-origin_z) == radius) {//At the edge on the top/bottom
        direction = -direction;//Reverse the direction
      }
      if (current_x >= 0 && current_x < level_width) {
        if (current_z >= 0 && current_z < level_height) {
          if (terrain_in_level[current_x][current_z] != null) {
            terrain_in_level[current_x][current_z].draw_only();
          }
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
  }*/
