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

void setup(){
  size(SIZE_X, SIZE_Y);
  background(COLOR_BG);
  triangle_grid.create_new_triangle_mesh();
}

void draw(){}

void mousePressed(){
  float x = mouseX;
  float y = mouseY;
  triangle_grid.change_color_at(x, y);
}

class Mesh{
  
  float start_x, start_y, size_x, size_y, side_len;
  float x_inc, y_inc;
  int num_x, num_y, array_size;
  Equilateral_Triangle[][] triangles;
  
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
    triangles = new Equilateral_Triangle[num_x][num_y];
  }
  
  // calculating x coordinate and y coordinate of the side vertex of the triangle 
  // from the x-index and y-index in "2-d array" of triangles
  float get_x_coordinate_from_xy_index(int ix, int iy){
    int adj1 = ix % 2;
    int adj2 = iy % 2;
    int adj = (adj1 + adj2) % 2;
    return ix * x_inc + start_x + x_inc * adj;
  }
  
  float get_y_coordinate_from_y_index(int iy){
    return iy * y_inc + start_y;
  }
  
  // calculate which triangle in 2d array contains the points (xcor, ycor)
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
  
  // initiate a new triangle mesh
  void create_new_triangle_mesh(){
    float xcor, ycor;
    boolean point_left = true;
    boolean point_left_temp = true;
    Equilateral_Triangle curr, neighbor;
    //triangles = new ArrayList();
    for (int ix = 0; ix < num_x; ix++){
      for (int iy = 0; iy < num_y; iy++){
        xcor = get_x_coordinate_from_xy_index(ix, iy);
        ycor = get_y_coordinate_from_y_index(iy); 
        curr = new Equilateral_Triangle(point_left_temp, xcor, ycor, side_len);
        triangles[ix][iy] = curr;

        // connect neighbors to top and left
        if (iy > 0){
          neighbor = (Equilateral_Triangle) triangles[ix][iy - 1];
          curr.add_top_neighbor(neighbor);
          neighbor.add_bottom_neighbor(curr);
        }
        if (ix > 0 && !point_left_temp){
          neighbor = (Equilateral_Triangle) triangles[ix - 1][iy];
          curr.add_side_neighbor(neighbor);
          neighbor.add_side_neighbor(curr);
        }
        
        // go ahead and paint the triangle since inital grid is gray anyway
        curr.paint();
        point_left_temp = !point_left_temp;        
      }
      point_left = !point_left;
      point_left_temp = point_left;
    }
  }
  
  // change the color of the triangle containing the point (xcor, ycor)
  void change_color_at(float xcor, float ycor){
    int ix = get_x_index_from_coordinates(xcor, ycor);
    int iy = get_y_index_from_coordinates(xcor, ycor);
    if(ix < num_x && iy < num_y && ix >= 0 && iy >= 0){
      Equilateral_Triangle t = (Equilateral_Triangle) triangles[ix][iy];
      Equilateral_Triangle[][] paintlist = new Equilateral_Triangle[4][4];
      
      t.change_color();
      t.paint();
    }
  }
  
  void paint_all(){
    for(int ix = 0; ix < num_x; ix++){
        for (int iy = 0; iy < num_y; iy++){
          Equilateral_Triangle t = triangles[ix][iy];
          t.paint();
        }
    }    
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
    
    int sign = -1;
    if (is_left_pointing){
      sign = 1;
    }
    y2 = y1 - side_length / 2;
    y3 = y1 + side_length / 2;
    x2 = x1 + sign * side_length * sqrt(3) / 2;
    x3 = x2;    
  }
 
  void add_top_neighbor(Equilateral_Triangle t){
    top_neighbor = t;
  }
  
  void add_bottom_neighbor(Equilateral_Triangle t){
    bottom_neighbor = t;
  }
  
  void add_side_neighbor(Equilateral_Triangle t){
    side_neighbor = t;
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
          line(x1, y1, x2, y2);
        }            
        if(bot){  
          stroke(COLOR_MESH);
          line(x1, y1, x3, y3);
        }if(sid){
          stroke(COLOR_MESH);
          line(x2, y2, x3, y3);
        }
        return;
    }
       
    //improving smoothconnect with neighbors
    fill(get_fill_color());
    stroke(get_fill_color());
    
    top = top_neighbor != null && top_neighbor.fill_color == fill_color;
    bot = bottom_neighbor != null && bottom_neighbor.fill_color == fill_color;
    sid = side_neighbor != null && side_neighbor.fill_color == fill_color;
    
    if(top && bot && sid){
      triangle(side_neighbor.x1, side_neighbor.y1, top_neighbor.x2, top_neighbor.y2, bottom_neighbor.x3, bottom_neighbor.y3);
      return;
    }
    if (top && bot){
      quad(top_neighbor.x2, top_neighbor.y2, x2, y2, x3, y3, bottom_neighbor.x3, bottom_neighbor.y3);
      return;
    }
    if(top && sid){
      quad(top_neighbor.x2, top_neighbor.y2, x1, y1, x3, y3, side_neighbor.x1, side_neighbor.y1);
      return;
    }
    if(bot && sid){
      quad(x1, y1, x2, y2, side_neighbor.x1, side_neighbor.y1, bottom_neighbor.x3, bottom_neighbor.y3);
      return;
    }
    if(top){
      quad(x1, y1, x3, y3, x2, y2, top_neighbor.x2, top_neighbor.y2);
      return;
    }
    if(bot){
      quad(x1, y1, x2, y2, x3, y3, bottom_neighbor.x3, bottom_neighbor.y3);
      return;
    }
    if(sid){
      quad(x1, y1, x2, y2, side_neighbor.x1, side_neighbor.y1, x3, y3);
      return;
    }
    if(!(top || bot || sid)){
      triangle(x1, y1, x2, y2, x3, y3);
      return;
    } 
  }
}


