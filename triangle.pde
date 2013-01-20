// comments go here
int SIZE_X = 2000;
int SIZE_Y = 1000;
float SIDE_LEN = 50;

color COLOR_BG = color(255);
color COLOR_MESH = color(225);
color COLOR_1 = color(200, 50, 100);
color COLOR_2 = color(50, 100, 200);
color COLOR_3 = color(100, 200, 50);

Mesh triangle_grid = new Mesh(SIZE_X, SIZE_Y, SIDE_LEN);

void setup()
{
  size(SIZE_X, SIZE_Y);
  background(COLOR_BG);
  //fill(COLOR_BG);
  triangle_grid.create_new_triangle_mesh();
  noLoop();  
}

void draw(){  
 
  
  
}

void mousePressed(){
  float x = mouseX;
  float y = mouseY;
  triangle_grid.change_color_at(x, y);
  redraw();
  
}

class Mesh{
  
  float start_x, start_y, size_x, size_y, side_len;
  float x_inc, y_inc;
  int num_x, num_y, array_size;
  ArrayList triangles;
  
  Mesh(float sizex, float sizey, float sidelen){ 
    size_x = sizex;
    size_y = sizey;
    start_x = 0;
    start_y = 0;
    side_len = sidelen;
    y_inc = side_len / 2;
    x_inc = side_len * sqrt(3) / 2;
    num_x = (int) (size_x / x_inc)+2;
    num_y = (int) (size_y / y_inc)+2;
    array_size = num_x * num_y;
    
    //create_new_triangle_mesh();
  }
  
  float get_x_coordinate_from_xy_index(int ix, int iy){
    int adj1 = ix % 2;
    int adj2 = iy % 2;
    int adj = (adj1 + adj2) % 2;
    return ix * x_inc + start_x + x_inc * adj;
  }
  
  float get_y_coordinate_from_y_index(int iy){
    return iy * y_inc + start_y;
  }
  
  int get_x_index_from_array_index(int i){
    return (int) ((i + 1) / num_y);
  }
  
  int get_y_index_from_array_index(int i){
    return (int) (i % num_y);
  }
  
  int get_array_index_from_xy(int ix, int iy){
    return (int) (ix * num_y + iy);
  }
  
  int get_x_index_from_coordinates(float xcor, float ycor){
    return (int) ((xcor-start_x) / x_inc);
  }
  
  int get_y_index_from_coordinates(float xcor, float ycor){
    int ix = get_x_index_from_coordinates(xcor, ycor);
    int temp_iy = (int) ((ycor-start_y) / y_inc);
    float xroot = get_x_coordinate_from_xy_index(ix, temp_iy);
    float xdiff = abs(xcor - xroot);
    float temp_yroot = get_y_coordinate_from_y_index(temp_iy);
    float yup = temp_yroot - xdiff / sqrt(3);
    float ydn = temp_yroot + xdiff / sqrt(3);
    if (ycor < yup){
      return temp_iy - 1;
    }
    if (ycor > ydn){
      return temp_iy + 1;
    }
    return temp_iy;
  }
  
  void create_new_triangle_mesh(){
    float xcor, ycor;
    boolean point_left = true;
    boolean point_left_temp = true;
    Equilateral_Triangle curr, neighbor;
    triangles = new ArrayList();
    for (int ix = 0; ix < num_x; ix++){
      for (int iy = 0; iy < num_y; iy++){
        xcor = get_x_coordinate_from_xy_index(ix, iy);
        ycor = get_y_coordinate_from_y_index(iy);
        triangles.add(new Equilateral_Triangle(point_left_temp, xcor, ycor, side_len)); 

        // add neighbors
        curr = (Equilateral_Triangle) triangles.get(get_array_index_from_xy(ix, iy));
        if (iy > 0){
          neighbor = (Equilateral_Triangle) triangles.get(get_array_index_from_xy(ix, iy - 1));
          curr.add_top_neighbor(neighbor);
          neighbor.add_bottom_neighbor(curr);
          
        }
        if (ix > 0 && !point_left_temp){
          neighbor = (Equilateral_Triangle) triangles.get(get_array_index_from_xy(ix - 1, iy));
          curr.add_side_neighbor(neighbor);
          neighbor.add_side_neighbor(curr);
        }
        
        
        // go ahead and paint since inital grid is gray anyway
        
        curr.paint();
        
        
        point_left_temp = !point_left_temp;
                
      }
      point_left = !point_left;
      point_left_temp = point_left;
    }
    
  }
  
  boolean change_color_at(float xcor, float ycor){
    int ix = get_x_index_from_coordinates(xcor, ycor);
    int iy = get_y_index_from_coordinates(xcor, ycor);
    if(ix < num_x && iy < num_y && ix >= 0 && iy >= 0){
      int i = get_array_index_from_xy(ix, iy);
      Equilateral_Triangle t = (Equilateral_Triangle) triangles.get(i);
      t.change_color();
      
      if (t.top_neighbor != null){
        t.top_neighbor.paint();
      }
      if (t.bottom_neighbor != null){
        t.bottom_neighbor.paint();
      }
      if (t.side_neighbor != null){
        t.side_neighbor.paint();
      }
      
      t.paint();
      
      return true;
    }
    return false;
  }
  
}

class Equilateral_Triangle {
  
  Equilateral_Triangle top_neighbor, bottom_neighbor, side_neighbor;
  Boolean is_left_pointing;
  int fill_color;
  float side_length;
  float x1, y1, x2, y2, x3, y3;
  
  Equilateral_Triangle (Boolean lp, float xp1, float yp1, float side_len) {
    top_neighbor = null;
    bottom_neighbor = null;
    side_neighbor = null;
    is_left_pointing = lp;
    fill_color = 0;
    side_length = side_len;
    x1 = xp1;
    y1 = yp1;
    
    // (x1,y1) should be the left coordinate if left pointing, and right coordinate if right pointing.
    // figure out (x2, y2) and (x3,y3)
    
    int sign = -1;
    if (is_left_pointing){
      sign = 1;
    }
    y2 = y1 - side_length / 2;
    y3 = y1 + side_length / 2;
    x2 = x1 + sign * side_length * sqrt(3) / 2;
    x3 = x2;
    
  }
 
  boolean add_top_neighbor(Equilateral_Triangle t){
    if(top_neighbor == null && t != null && is_left_pointing != t.is_left_pointing){
      if (t.x1 == x2 && t.y1 == y2){
        top_neighbor = t;
        return true;
      }  
    }
    return false;
  }
  
  boolean add_bottom_neighbor(Equilateral_Triangle t){
    if(bottom_neighbor == null && t != null && is_left_pointing != t.is_left_pointing){
      if (t.x1 == x3 && t.y1 == y3){
        bottom_neighbor = t;
        return true;
      }  
    }
    return false;
  }
  
  boolean add_side_neighbor(Equilateral_Triangle t){
    if(side_neighbor == null && t != null && is_left_pointing != t.is_left_pointing){
      if (t.x1 == (x2-x1) + x2 && t.y1 == y1){
        side_neighbor = t;
        return true;
      }  
    }
    return false;
  }
  
  void change_color(){
    fill_color = (fill_color + 1) % 4;
  }
  
  color get_fill_color(){
    switch(fill_color){
      case 0:
        return COLOR_BG;
      case 1:
        return COLOR_1;
      case 2:
        return COLOR_2;
    }
    return COLOR_3;
  }
    
  void paint(){
    boolean top, bot, sid;      
    if(fill_color == 0){
        // no color
        top = (top_neighbor == null || top_neighbor.fill_color == 0);
        bot = (bottom_neighbor == null || bottom_neighbor.fill_color == 0);
        sid = (side_neighbor == null || side_neighbor.fill_color == 0);
        
        fill(COLOR_BG);
        stroke(COLOR_BG);
        triangle(x1, y1, x2, y2, x3, y3);
          
            
        if(top){
          stroke(COLOR_MESH);
        } 
        else{
          stroke(top_neighbor.get_fill_color());
        }
        line(x1, y1, x2, y2);
            
        if(bot){  
          stroke(COLOR_MESH);
        }
        else{
          stroke(bottom_neighbor.get_fill_color());
        }
        line(x1, y1, x3, y3);
            
        if(sid){
          stroke(COLOR_MESH);
        }
        else{
          stroke(side_neighbor.get_fill_color());
        }
        line(x2, y2, x3, y3);
          
        return;
    }
    
    fill(get_fill_color());
    stroke(get_fill_color());
    triangle(x1, y1, x2, y2, x3, y3);
    top = (top_neighbor == null || top_neighbor.fill_color > fill_color);
    bot = (bottom_neighbor == null || bottom_neighbor.fill_color > fill_color);
    sid = (side_neighbor == null || side_neighbor.fill_color > fill_color);
    
    //consistent stroking priority so that when switching colors previous strokes don't show
    if (top){
      stroke(top_neighbor.get_fill_color());
    }
    else{
      stroke(get_fill_color());
    }
    line(x1, y1, x2, y2);
            
    if(bot){  
      stroke(bottom_neighbor.get_fill_color());
    }
    else{
      stroke(get_fill_color());
    }
    line(x1, y1, x3, y3);
            
    if(sid){
      stroke(side_neighbor.get_fill_color());
    }
    else{
      stroke(get_fill_color());
    }
    line(x2, y2, x3, y3);
    
    //improving smoothconnect with neighbors, only if left pointing to reduce redundance
    fill(get_fill_color());
    stroke(get_fill_color());
    if (is_left_pointing){
      float px1, px2, px3, px4, py1, py2, py3, py4;
      top = top_neighbor != null && top_neighbor.fill_color == fill_color;
      bot = bottom_neighbor != null && bottom_neighbor.fill_color == fill_color;
      sid = side_neighbor != null && side_neighbor.fill_color == fill_color;
      if(top && bot && sid){
        px1 = side_neighbor.x1;
        py1 = side_neighbor.y1;
        px2 = top_neighbor.x2;
        py2 = top_neighbor.y2;
        px3 = bottom_neighbor.x3;
        py3 = bottom_neighbor.y3;
        triangle(px1, py1, px2, py2, px3, py3);
        return;
      }
      if (top && bot){
        px1 = top_neighbor.x2;
        py1 = top_neighbor.y2;
        px2 = x2;
        py2 = y2;
        px3 = x3;
        py3 = y3;
        px4 = bottom_neighbor.x3;
        py4 = bottom_neighbor.y3;
        quad(px1, py1, px2, py2, px3, py3, px4, py4);
        return;
      }
      if(top && sid){
        px1 = top_neighbor.x2;
        py1 = top_neighbor.y2;
        px2 = x1;
        py2 = y1;
        px3 = x3;
        py3 = y3;
        px4 = side_neighbor.x1;
        py4 = side_neighbor.y1;
        quad(px1, py1, px2, py2, px3, py3, px4, py4);
        return;
      }
      if(bot && sid){
        px1 = x1;
        py1 = y1;
        px2 = x2;
        py2 = y2;
        px3 = side_neighbor.x1;
        py3 = side_neighbor.y1;
        px4 = bottom_neighbor.x3;
        py4 = bottom_neighbor.y3;
        quad(px1, py1, px2, py2, px3, py3, px4, py4);
        return;
      }
      if(top){
        px4 = top_neighbor.x2;
        py4 = top_neighbor.y2;
        quad(x1, y1, x3, y3, x2, y2, px4, py4);
        return;
      }
      if(bot){
        px4 = bottom_neighbor.x3;
        py4 = bottom_neighbor.y3;
        quad(x1, y1, x2, y2, x3, y3, px4, py4);
        return;
      }
      if(sid){
        px4 = side_neighbor.x1;
        py4 = side_neighbor.y1;
        quad(x1, y1, x2, y2, px4, py4, x3, y3);
        return;
      }
      
    }
    
  }
  
  
  
}


