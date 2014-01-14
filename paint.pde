/* This programm is "palette TV"
 * Created by Sota Sugiura
 * for Media Technology Basic - 3D Programming
 */

/* modules */
import processing.video.*;

/* variable */
PImage canvas; // canvas
Capture video;

color[] pen_color = new color[4]; // black:0 red:1 green:2 blue:3
int pn = 0, tn = 0; // pn : color number | tn : text number
int counter = 0, counter2 = 0, counter3 = 0, counter4 = 0;
int w=640,h=480; // height and width
color[] v_color = new color[640*480]; // for reverse right and left
int[] v_line = new int[640*480];  // array of line | true:1 false:0

void setup() {
  size(640, 480); // default:(640,480)
  
  /* pic setup */
  canvas = createImage(width, height, RGB);
  
  /* video setup */
  video = new Capture(this, width, height, 30);
  video.start();
  
  /* first init */
  pen_color[0] = color(0, 0, 0);
  pen_color[1] = color(255, 0, 0);
  pen_color[2] = color(0, 255, 0);
  pen_color[3] = color(0, 0, 255);
  for(int i=0;i<640*480;i++){
    v_line[i] = 0;
  }
}

void draw() {
  /* video process */
  if (video.available()) {
    video.read();
  }
  video.loadPixels();
  
  /* draw line */
  int x_sum=0, y_sum=0, c_sum=0; // sum of x and y coordinate | number of painted pixels
  
  canvas.loadPixels();
  for (int y=0;y<h;y++) {
    for(int x=0;x<w;x++) {
      int i = y * w + x;
      if (brightness(video.pixels[i])==255) {
        canvas.pixels[i] = color(255, 0, 0); // white -> paint
      } else {
        canvas.pixels[i] = color(0); // not white -> black
      }
    }
  }
  
  // noise reduction 3 * 4
  for(int y=0;y<h;y+=3){
    for(int x=0;x<w;x+=4){
      int p_counter = 0; // painted pixel's counter
      int place = y * w + x; // coordinate of main pixel
      for(int xx=0;xx<4;xx++){
        for(int yy=0;yy<3;yy++){
          if(canvas.pixels[place + yy * w + xx] == color(255, 0, 0)) p_counter++;
        }
      }
      for(int xx=0;xx<4;xx++){
        for(int yy=0;yy<3;yy++){
          if(p_counter > 11){
            x_sum = x_sum + x + xx; 
            y_sum = y_sum + y + yy; 
            c_sum++;
          }
        }
      }
    }
  }
  
  // take average of pixels -> brightness(255)
  if(c_sum >= 7000){
    int new_x = x_sum / c_sum;
    int new_y = y_sum / c_sum;
    for(int x=0;x<6;x++){
      for(int y=0;y<6;y++){
        if(new_x > (w - 6) || new_y > (h - 4)) break;
        video.pixels[(new_y + y) * w + (x + new_x)] = pen_color[pn];
        v_line[(new_y + y) * w + (x + new_x)] = 1;
        v_color[(new_y + y) * w + (x + new_x)] = pen_color[pn];
      }
    }
  }
  
  /* draw saved line */
  for (int i=0;i<w*h;i++) {
    if(v_line[i] == 1) video.pixels[i] = v_color[i];
  }
  
  video.updatePixels();
  canvas.updatePixels();
  image(video, 0, 0);
  
  /* make rect */
  noFill();
  strokeWeight(2);
  stroke(100, 100, 100); rect(40, 40, 80, 80);
  stroke(250, 250, 250); rect(520, 40, 80, 80);
  stroke(0, 250, 250); rect(520, 360, 80, 80);
  
  /* change color */
  if(on_switch(40, 40, 80)){
    counter++;
    if(counter >= 60){
      if(pn == 3) pn = 0;
      else pn++;
      tn = 1;
      counter = 0;
    }
  } else {
    counter = 0;
  }
  
  /* eraser */
  if(on_switch(520, 40, 80)) {
    counter2++;
    if(counter2 >= 60) {
      reset();
      tn = 2; 
      counter2 = 0;
    }
  } else {
    counter2 = 0;
  }

  /* save */
  if(on_switch(520, 360, 80)) {
    counter3++;
    if(counter3 >= 30) {
      save("~/Documents/Processing/pic/image.png"); 
      tn = 3;
      counter3 = 0;
    }
  } else {
    counter3 = 0;
  }
  
  /* text */
  textSize(16);
  if(tn > 0) {
    String str = "";
    if(tn==1){
      str = "change color";
    } else if(tn==2){
      str = "all clear";
    } else if(tn==3){
      str = "save screenshot";
    }
    
    if(counter4 >= 40) {
      tn = 0;
      counter4 = 0;
    } else {
      text(str, 130, 50);
      counter4++;
    }
  } 
}

boolean on_switch(int lx, int ly, int size) {
  int p=0;
  for(int y=ly;y<ly+size;y++){
    for(int x=lx;x<lx+size;x++){
     if(brightness(video.pixels[y * w + x])==255) p++;
    }
  }
  if(p >= 4000){
    return true;
  } else {
    return false;
  }
}

void reset(){
  for(int i=0;i<640*480;i++){
    v_line[i] = 0;
  }  
}
