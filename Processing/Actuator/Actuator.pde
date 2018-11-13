import processing.net.*;

// Parameter
final int SENSOR_PORT = 17;
final int DISCRIMINATOR_PORT = 10001;
final int ACTUATOR_PORT = 10;
final int SENSING_NUM = 3;
final int graphWidth = 200;
final int graphHeight = 150;
final int graphMargin = 175;
final Graph[] graphs = {
  new Graph(
    115,
    80,
    graphWidth,
    graphHeight,
    color (200, 20, 20)
  ),
  new Graph(
    115 + (graphWidth + graphMargin),
    80,
    graphWidth,
    graphHeight,
    color (200, 20, 20)
  ),
  new Graph(
    115,
    80 + (graphHeight + graphMargin),
    graphWidth,
    graphHeight,
    color (200, 20, 20)
  )
};

// Variable
Serial actuatorPort;
Server server;
Client client;
String currentState = "";
boolean isSending = false;
boolean hasReceived = true;

boolean actuatorSerialPortSetup() {
  String portName = Serial.list()[ACTUATOR_PORT];
  println("Selected actuator port: " + portName);
  actuatorPort = new Serial(this, portName, 9600);
  if (actuatorPort == null) {
    exit();
  }
  return true;
}

// Funtion
void setup() {
  size(1280, 720);
  for (int i = 0; i < graphs.length; i++) {
    graphs[i].xLabel = "Number";
    graphs[i].yLabel = "Amp";
    graphs[i].Title = "Graph " + str(i + 1);
  }
  noLoop();

  if (!sensorSerialPortSetup() || !actuatorSerialPortSetup()) {
    exit();
  }
  server = new Server(this, DISCRIMINATOR_PORT);
  server.active();
  println("server address:" + server.ip());
  client = new Client(this, "", 10002);
  frameRate(100);
}

void draw() {
  //receive message from python
  receiveState();
  if (!isSending && hasReceived) {
    sendData();
  }

  background(255);

  if (DataReceived) {
    pushMatrix();
    pushStyle();
    try {
      for (int i = 0; i < graphs.length; i++) {
        graphs[i].yMax = 1000;
        graphs[i].yMin = 0;
        graphs[i].xMax = int(max(Time[i]));
        graphs[i].DrawAxis();
        graphs[i].smoothLine(Time[i], Voltage[i]);
      }
    } catch(NullPointerException e) {
      println("Warning: no data is received.");
    }
    popStyle();
    popMatrix();

    /* ====================================================================
     Gesture compare
     ====================================================================  */
    fill(0,0,0);
    textSize(50);
    text(currentState, 810, 100);
    // switch(currentState) {
    //   case "Nothing":
    //     actuatorPort.write('a');
    //     break;
    //   case "Near1":
    //     actuatorPort.write('b');
    //     break;
    //   case "Near2":
    //     actuatorPort.write('c');
    //     break;
    //   case "Near3":
    //     actuatorPort.write('d');
    //     break;
    //   case "Touch1":
    //     actuatorPort.write('e');
    //     break;
    //   case "Touch2":
    //     actuatorPort.write('f');
    //     break;
    //   case "Touch3":
    //     actuatorPort.write('g');
    //     break;
    //   default:
    //     break;
    // }
  }
}

void stop() {
  sensorPort.stop();
  actuatorPort.stop();
  super.stop();
}

void sendData() {
  isSending = true;
  hasReceived = false;
  boolean flag = true;
  for (int i = 0; i < SENSING_NUM; i++) {
    if (Voltage[i] == null || Voltage[i].length == 0) {
      flag = false;
    }
  }
  if (flag) {
    for (int i = 0; i < SENSING_NUM; i++) {
      client.write("index" + str(i) + "/");
      for (int j = 0; j < Voltage[i].length; j++) {
        client.write(str(Voltage[i][j]) + "/");
      }
      client.write("pause" + "/");
    }
    client.write("finished");
  }
  isSending = false;
}

void receiveState() {
  Client discriminatorClient = server.available();
  if (discriminatorClient != null) {
    String incoming = discriminatorClient.readString();
    hasReceived = true;
    if (incoming != null) {
      currentState = incoming;
    } else {
      currentState = "";
    }
  }
}
