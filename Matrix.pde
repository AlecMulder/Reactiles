public class Matrix {
  OPC opc;
  String address;
  int port;

  int index = 0;
  int stripLength = 8;
  int numStrips = 8;
  float x;
  float y;
  float ledSpacing;
  float stripSpacing;
  float angle = 0;
  boolean zigzag = false;

  int code;
  float unit;


  Matrix(PApplet parent, String address, int port, int _code) {
    opc = new OPC(parent, address, port);
    code = _code;
  }

  public void update(float _x, float _y, float _unit, float _angle) {
    float _yMapped = mapY(_y);
    float _xMapped = mapX(_x);
    x = _xMapped;
    if (_yMapped>numStrips/2*stripSpacing && _yMapped<height-numStrips/2*stripSpacing) {
      println("Too close to the top or bottom - " + _y);
      y = _yMapped;
    }
    unit = _unit;
    angle = _angle;
  }
  private float mapX(float x) {
    return map(x, 0, videoWidth, 0, width);
  }

  private float mapY(float y) {
    return map(y, 0, videoHeight, 0, width);
  }
}