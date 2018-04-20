import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
PGraphics offscreen;
PImage one;

void setup()
{
  size(1920,1080, P3D);
  
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(1920, 1080, 200);
  ks.load();
  offscreen = createGraphics(1920, 1080, P3D);
  //one = loadImage("Inisfil_Image.png");
  one = loadImage("lakeshore_image.png");
}
void draw(){
  background(0);
  offscreen.beginDraw();
  offscreen.image(one,0,0);
  offscreen.endDraw();
  
   surface.render(offscreen);
}

void keyPressed() {
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  }
}
