import processing.video.*;
import TUIO.*;

TuioProcessing tuio;
Movie lakeshoreIntersection;

ArrayList<Tile> tiles = new ArrayList<Tile>();


boolean debug = false;

void setup() {
  size(1000, 500);
  background(0);
  initTiles();
  lakeshoreIntersection = new Movie (this, "Lakeshore_Video_smallHC2.mov");
  lakeshoreIntersection.loop();
  tuio = new TuioProcessing(this);
}

void movieEvent(Movie m) {
  m.read();
}

void draw() {
  background(0);
  //fill(100);

  imageMode(CENTER);
  image(lakeshoreIntersection, width/2-5, height/2);
  //ellipse(mouseX, mouseY, 50,50);
  if (debug) {
    ArrayList<TuioObject> tuioObjectList = tuio.getTuioObjectList();
    for (int i=0; i<tuioObjectList.size(); i++) {
      TuioObject tobj = tuioObjectList.get(i);
      text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
    }
  }
  stroke(0);
  line(434, 287, 564, 287);
}

void initTiles() {
  String[] loadTile = loadStrings("tileAddresses.txt");
  String[] loadCodes = loadStrings("codes.txt");
  for (int i = 0; i<loadTile.length; i++) {
    String[] split = split(loadTile[i], ": ");
    if (split.length>1)
      println(split.length);
    if (split.length>1) {
      println("add: " + split[0] + "Code: " + loadCodes[i]);
      tiles.add(new Tile(this, split[0], split[1], 7890+i, int(loadCodes[i])));
      println(tiles.get(tiles.size()-1) + "|" + split[1]+"|");
    }
  }
}


// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  //println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
  int id = tobj.getSymbolID();
  for (int i = 0; i<tiles.size(); i++) {
    //tiles.get(i).setOnScreen(true);
  }
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  //println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
  //  +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());

  int id = tobj.getSymbolID();
  for (int i = 0; i<tiles.size(); i++) {
    if (tiles.get(i).code == id) {
      println(tiles.get(i).name + " with code " + id + " updated at " + millis()/1000);
      tiles.get(i).update(map(tobj.getScreenX(130), 0, 130, width/2-65, width/2+65), 
        map(tobj.getScreenY(75), 0, 75, height/2-37.5, height/2+37.5), 
        tobj.getXSpeed(), 
        tobj.getYSpeed(), 
        tobj.isMoving(), 
        tobj.getMotionAccel(), 
        tobj.getMotionSpeed(), 
        tobj.getAngle()+radians(270), 
        tobj.getRotationAccel(), 
        tobj.getRotationSpeed());
    }
  }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
  int id = tobj.getSymbolID();
  for (int i = 0; i<tiles.size(); i++) {
    if (tiles.get(i).code == id) {
      //tiles.get(i).setOnScreen(false);
      //tiles.get(i).setColor(color(0, 0, 0));
    }
  }
}

// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
    +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) { 
  //println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
}

void keyPressed() {
  if (key=='0') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile0")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='1') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile1")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='2') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile2")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='3') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile3")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='4') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile4")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='5') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile5")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='6') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile6")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='7') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile7")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='8') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile8")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  } else if (key=='9') {
    for (int i = 0; i<tiles.size(); i++) {
      if (tiles.get(i).name.equals("tile9")) {
        tiles.get(i).update(mouseX, mouseY);
      }
    }
  }
}
