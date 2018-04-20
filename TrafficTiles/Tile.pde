public class Tile {
  OPC opc;
  String address;
  int port;

  int index = 0;
  int stripLength = 8;
  int numStrips = 8;
  float x = width/2+(random(-100, 100));
  float y = height/2+(random(-100, 100));
  float spacing = 1;
  float angle = 0;
  boolean zigzag = false;

  String name;
  int code;
  float xSpeed;
  float ySpeed;
  boolean isMoving;
  float moveAcceleration;
  float moveSpeed;
  float rotationAcceleration;
  float rotationSpeed;

  Tile(PApplet parent, String _name, String _address, int _port, int _code) {
    opc = new OPC(parent, _address, _port);
    name = _name;
    address = _address;
    port = _port;
    code = _code;
    opc.showLocations(debug);
    opc.ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  public void update(float _x, float _y, float _xSpeed, float _ySpeed, boolean _isMoving, float mA, float mS, float _angle, float rA, float rS) {
    x = _x;

    y = _y;
    //
    xSpeed = _xSpeed;
    ySpeed = _ySpeed;
    isMoving = _isMoving;
    moveAcceleration = mA;
    moveSpeed = mS;
    rotationAcceleration = rA;
    rotationSpeed = rS;
    angle = _angle;
    opc.ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }
  
  public void update(float _x, float _y){
   x=_x; 
   y=_y;
   opc.ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }
  
  //public void setOnScreen(boolean os) {
  //  opc.setOnScreen(os);
  //}
  
  public void setColor(color c) {
    println("set Color");
    for (int i = 0; i<64; i++) {
      opc.setPixel(i, c);
    }
    opc.writePixels();
    opc.pixelLocations=null;
  }
  
  public String toString() {
    return name + " " + code + " " + address + " " + port + "  " + x + " " + y;
  }
}
