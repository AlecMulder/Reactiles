import websockets.*;

WebsocketServer ws;

ArrayList<Matrix> matrices = new ArrayList<Matrix>();
float videoWidth = 1280;
float videoHeight = 720;

void setup() {
  size(700, 700);
  ws= new WebsocketServer(this, 8025, "/topcodes");
  matrices.add(new Matrix(this, "192.168.2.123", 7890, 39));

  background(0);
}

void draw() {
}


void webSocketServerEvent(String msg) {
  if (msg.indexOf("{ \"code\"")!=-1) {
    //println("msg = " + msg);
    String[][] m = matchAll(msg, "\\{(.*?)\\},");
    println("array length: " + m.length);
    for (int i = 0; i<m.length; i++) {
      //println("Found '" + m[i][1] + "' inside the tag.");
      JSONObject json = parseJSONObject(m[i][0]);
      if (json == null) {
        println("JSONArray could not be parsed");
      } else {
        //println(millis() + "Code " + json.getInt("code") +  " found");
        matrices.get(0).update(
          json.getFloat("x"), 
          json.getFloat("y"), 
          json.getFloat("unit"), 
          json.getFloat("angle")
          );
      }
    }
  }
}