//"J3D" file
class J3D {
  float fov = 0.5;
  //The coordinates of the "camera"/viewpoint
  Jvect3 camera;
  float camera_rotate_x;
  float camera_rotate_y;
  float rotate_y;//in radians, applied around origin. Rotates the current polygons.
  Jvect3 translate;//Where to move points after rotation.
  Jvect2_ext t;//Temporary variable for the perspective function
  float oob_locking_angle;//If a point is behind the camera, it will be...
  //moved to in front of the camera while locked to this angle.
  int window_xsize;//For split screen and the oob functions.
  int window_xoffset;//The x-offset of the views, for split screen.
  int window_ysize;//For split screen and the oob functions.
  int window_yoffset;//The x-offset of the views, for split screen.
  boolean use_oob;

  J3D() {
    camera = new Jvect3(0,0,0);
    translate = new Jvect3(0,0,0);
    t = new Jvect2_ext(0,0,1);
    rotate_y = 0;
    camera_rotate_x = 0;
    camera_rotate_y = 0;
    window_xsize = width;
    window_xoffset = 0;
    window_ysize = height;
    window_yoffset = 0;
    reset_transforms();
    oob_locking_angle = 0;
    use_oob = false;
  }
  
  void reset_transforms() {
    translate.set(0,0,0);
    rotate_y = 0;
    return;
  }
  
  void line_perspective(float x1, float y1, float z1,float x2, float y2, float z2, float size) {
    persp(x1,y1,z1,null);
    strokeWeight(t.size*size);
    line_oob(t.u,t.v,persp(x2,y2,z2,null).u,t.v);
  }
  
  
  //This function takes a 3D point, and interpolates it onto the 2D screen.
  Jvect2_ext persp(float x, float y, float z, Jvect2_ext set) {//Returns the 2D X value of the point, sets temp vars to y and size.
    if (set == null) set = t;
    float zdiff = 0;
    if (rotate_y != 0) {
      x = rotate_point(x,z,rotate_y,null).u;
      z = t.v;
    }
    x = x+translate.x-camera.x;
    y = y+translate.y-camera.y;
    z = z+translate.z-camera.z;
    if (camera_rotate_y != 0) {
      x = rotate_point(x,z,camera_rotate_y,null).u;
      z = t.v;
    }
    if (camera_rotate_x != 0) {
      y = rotate_point(y,z,camera_rotate_x,null).u;
      z = t.v;
    }
    set.size = fov/(z)*window_xsize;
    //If the point is behind the camera...
    if (z <= 0) {
      //Move the point to 1 unit in front of the camera
      zdiff = 1-z;
      set.size = fov*window_xsize*z;
      z = 1;
      //This code will make the point move on the oob_locking_angle.
      if (oob_locking_angle != -1) {
        x = x-zdiff*tan(oob_locking_angle + camera_rotate_y);
      }
    }
    set.size = fov/(z)*window_ysize;
    set.v = window_yoffset+((y)*set.size+window_ysize/2);
    set.u = window_xoffset+((x)*set.size+window_xsize/2);
    if (z == 1) {
      set.size = 0.01;
    }
    return set;
  }
  
  
  void line_oob(float x1,float y1,float x2,float y2) {
    if (use_oob) {
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
    } else {
      line(x1,y1,x2,y2);
    }
  }
  
  void quad_oob(Jvect2 v1, Jvect2 v2, Jvect2 v3, Jvect2 v4) {
    if (use_oob) {
      //A function to draw a quad that, if it crosses a line, is drawn in such a way that nothing
      //is drawn on the other side. 
      boolean error1 = false; boolean error2 = false; boolean error3 = false; boolean error4 = false;
      Jvect2 vtemp; boolean errortemp;
      float window_border = window_xsize+window_xoffset;
      //Make the problem points easy to access
      if (v1.u > window_border) {error1 = true;}
      if (v2.u > window_border) {error2 = true;}
      if (v3.u > window_border) {error3 = true;}
      if (v4.u > window_border) {error4 = true;}
      if (error1 && error2 && error3 && error4) {
        return;//If it is completely out of bounds, stop the function.
      }
      if (!error1 && !error2 && !error3 && !error4) {
        quad(v1.u,v1.v,v2.u,v2.v,v3.u,v3.v,v4.u,v4.v);
        return;//If it is completely in bounds, draw and stop the function.
      }
      //"Move" the points so error1 is always true, and error4 is alway false.
      if (!error1) {//Move the points one to the left
        vtemp=v1; v1=v2; v2=v3; v3=v4; v4=vtemp;
        errortemp=error1; error1=error2; error2=error3; error3=error4; error4=errortemp;
      }
      if (!error1) {//Move the points one to the left
        vtemp=v1; v1=v2; v2=v3; v3=v4; v4=vtemp;
        errortemp=error1; error1=error2; error2=error3; error3=error4; error4=errortemp;
      }
      if (!error1) {//Move the points one to the left
        vtemp=v1; v1=v2; v2=v3; v3=v4; v4=vtemp;
        errortemp=error1; error1=error2; error2=error3; error3=error4; error4=errortemp;
      }
      if (error4) {//Move the points one to the right
        vtemp=v4; v4=v3; v3=v2; v2=v1; v1=vtemp;
        errortemp=error4; error4=error3; error3=error2; error2=error1; error1=errortemp;
      }
      if (error4) {//Move the points one to the right
        vtemp=v4; v4=v3; v3=v2; v2=v1; v1=vtemp;
        errortemp=error4; error4=error3; error3=error2; error2=error1; error1=errortemp;
      }
      //Assuming error1 is true, and error4 is false
      if (error2) {
        if (error3) {//If three points (1,2,3) are in error...
          //Create a triangle
          triangle(window_border,intersect_lwv(v1,v4,window_border), window_border,intersect_lwv(v3,v4,window_border), v4.u,v4.v);
        } else {//If two points (1, 2) are in error...
          //Draw a quad
          quad(window_border,intersect_lwv(v1,v4,window_border), window_border,intersect_lwv(v2,v3,window_border), v3.u,v3.v, v4.u,v4.v);
        }
      } else {//If only one point (1) is in error...
        //Draw a pentagon using a quad and triangle
        float ytemp = intersect_lwv(v1,v2,window_border);
        beginShape();
        vertex(window_border,intersect_lwv(v1,v4,window_border));
        vertex(window_border,ytemp);
        vertex(v2.u,v2.v);
        vertex(v3.u,v3.v);
        vertex(v4.u,v4.v);
        endShape();
      }
    } else {
      quad(v1.u,v1.v,v2.u,v2.v,v3.u,v3.v,v4.u,v4.v);
    }
  }
  
  void polygon_oob(Jvect2[] va) {
    if (use_oob) {
      //A function to draw a polygon that, if it crosses a line, is drawn in such a way that nothing
      //is drawn on the other side.
      boolean[] error = new boolean[va.length];
      Jvect2 vtemp; boolean errortemp;
      float window_border = window_xsize+window_xoffset;
      int number_of_true_points = 0;
      for (int i = 0; i < va.length; i = i+1) {//Check each error...
        if (va[i].u > window_border) {
          error[i] = true;
        } else {
          error[i] = false;
          number_of_true_points += 1;
        }
      }
      if (number_of_true_points == 0) {return;}
      if (number_of_true_points == va.length) {
        beginShape();
        for (int i = 0; i < va.length; i = i+1) {//For each point...
          vertex(va[i].u,va[i].v);
        }
        endShape();
        return;
      }
      
      //"Move" the points so error[0] is always true, and error[i] is alway false.
      //First, find out how much to move them.
      for (int i = 0; i < va.length-1; i = i+1) {//Check each error...
        if (!error[0]) {
          //Move them to the left.
          vtemp=va[0]; errortemp=error[0];
          for (int j = 0; j < va.length-1; j = j+1) {
            va[j] = va[j+1]; error[j] = error[j+1];
          }
          va[va.length-1] = vtemp;
          error[error.length-1] = errortemp;
        }
      }
      for (int i = 0; i < va.length-2; i = i+1) {//Check each error...
        if (error[error.length-1]) {
          //Move them to the right.
          vtemp = va[va.length-1];
          errortemp = error[error.length-1];
          for (int j = va.length-1; j > 0; j = j-1) {
            va[j] = va[j-1]; error[j] = error[j-1];
          }
          va[0] = vtemp; error[0] = errortemp;
        }
      }
      beginShape();
      //Find the intersection using the first error.
      vertex(window_border,intersect_lwv(va[0],va[va.length-1],window_border));
      //Find the intersection using the last error.
      vertex(window_border,intersect_lwv(va[number_of_true_points],va[number_of_true_points-1],window_border));
      for (int i = number_of_true_points; i < va.length; i = i+1) {//For each point after all the false ones...
        vertex(va[i].u,va[i].v);
      }
      endShape();
      return;
    } else {
      beginShape();
      for (int i = 0; i < va.length; i = i+1) {//For each point...
        vertex(va[i].u,va[i].v);
      }
      endShape();
    }
  }
  
  Jvect2 rotate_point(float x, float y, float radians, Jvect2 target) {
    if (target == null) target = t; 
    float distance = dist(0,0,x,y);
    if (distance > 0) {  
      float angle = acos(x/distance);
      if (y < 0) {
        angle = TWO_PI-angle;
      }
      target.set(distance*cos(angle+radians),distance*sin(angle+radians));
      return target;
    } else {
      target.set(x,y);
      return target;
    }
  }
  
  float intersect_lwv(float x1, float x2, float y1, float y2, float vertical_line) {
    //Takes a line from 2 points, and an x-value of a vertical line, and intersects them.
    //It returns the y-value of the intersect point.
    return ((y2-y1)/ (x2-x1)*(vertical_line-x1)+y1);
  }
  
  float intersect_lwv(Jvect2 v1, Jvect2 v2, float vertical_line) {
    //Takes a line from 2 points, and an x-value of a vertical line, and intersects them.
    //It returns the y-value of the intersect point.
    return ((v2.v-v1.v)/ (v2.u-v1.u)*(vertical_line-v1.u)+v1.v);
  }
}

class Jvect2 {//Vector with 2 dimentions
  float u;
  float v;
  Jvect2(float u_, float v_) {
    u = u_; v = v_;
  }
  float direction() {
    float angle = acos(u/magnitude());
    if (v < 0) {
      angle = TWO_PI-angle;
    }
    return angle;
  }
  float magnitude() {
    return sqrt(u*u+v*v);
  }
  void set(float u_, float v_) {
    u = u_; v = v_;
  }
  void add(float u_, float v_) {
    u += u_; v += v_;
  }
  void add(Jvect2 vect) {
    u = u+vect.u; v = v+vect.v;
  }
}

class Jvect2_ext extends Jvect2 {//Returned by the persp() function.
  float size;
  Jvect2_ext(float u_, float v_, float size_) {
    super(u_, v_);
    size = size_;
  }
  void set(float u_, float v_, float size_) {
    u = u_; v = v_; size = size_;
  }
}

class Jvect3 {//Vector with 3 dimentions
  float x;
  float y;
  float z;
  Jvect3(float x_, float y_, float z_) {
    x = x_; y = y_; z = z_;
  }
  float magnitude() {
    return sqrt(x*x+y*y+z*z);
  }
  void set(float x_, float y_, float z_) {
    x = x_; y = y_; z = z_;
  }
  void add(Jvect3 vect) {
    x = x+vect.x; y = y+vect.y; z = z+vect.z;
  }
}