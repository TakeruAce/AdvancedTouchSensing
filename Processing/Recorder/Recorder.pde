// Parameter
final int SENSOR_PORT = 17;
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
String[] names = {
  "Nothing",
  "Near1",
  "Near2",
  "Near3",
  "Touch1",
  "Touch2",
  "Touch3"
};

// Variable
final int NOT_SELECTED = -1;
final int RECORDED = -2;
int[] learningCount = new int[names.length];
PrintWriter[] output = new PrintWriter[SENSING_NUM];
boolean isCollecting = false;
int selectedNumber = NOT_SELECTED;

// Funtion
void setup() {
  size(1280, 720);

  for (int i = 0; i < graphs.length; i++) {
    graphs[i].xLabel = "Number";
    graphs[i].yLabel = "Amp";
    graphs[i].Title = "Graph " + str(i + 1);
  }
  noLoop();

  String path = sketchPath();
  File[] files = listFiles(path + "/data");
  for (int i = 0; i < files.length; i++) {
    if (!files[i].isDirectory()) {
      files[i].delete();
    }
  }

  if (sensorSerialPortSetup()) { // speed of 115200 bps etc.
    String filename = nf(year(),4) + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
    for (int i = 0; i < SENSING_NUM; i++) {
      output[i] = createWriter("data/" + filename + "_sensor" + (i + 1) + ".csv");
    }
  } else {
    exit();
  }
  frameRate(60);

  for (int i = 0; i < names.length; i++) {
    learningCount[i] = 0;
  }
}

void draw() {
  background(255);

  if (selectedNumber == RECORDED) {
    selectedNumber = NOT_SELECTED;
  }
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

    fill(0, 0, 0);
    textSize(20);
    text(
      "Type label number to collect data for a second.",
      800, 75 * names.length + 50
    );
    text(
      "Type \"S\" to save collected data.",
      800, 75 * names.length + 50 + 40
    );
    text(
      "[*] is a number of learning times.",
      800, 75 * names.length + 50 + 40 * 2
    );

    /* ====================================================================
     Gesture compare
     ====================================================================  */
    for (int i = 0; i < names.length;i++) {
      if (i == selectedNumber) {
        fill(255, 0, 0);
      } else {
        fill(255, 255, 255);
      }
      stroke(0, 0, 0);
      rect(800, 75 * i + 25, 50, 50);
      fill(0,0,0);
      textSize(30);
      text(i + ". " + names[i] + " [" + learningCount[i] + "]", 860, 75 * i + 25 + 25);

      fill(255, 0, 0);
    }
  }
}

void record(int labelNumber) {
  int count = 0;
  println("Start recording \'" + names[labelNumber] + "\'...");
  learningCount[labelNumber]++;
  while(count < 20) {
    for (int j = 0; j < SENSING_NUM; j++) {
      output[j].print(names[labelNumber] + ",");
      for (int k = 0; k < Voltage[j].length; k++) {
        output[j].print(Voltage[j][k] + ",");
      }
      output[j].println();
    }
    count++;
    delay(50);
  }
  println("Finished.");
}

void stop() {
  sensorPort.stop();
  super.stop();
}

void keyPressed() {
  if (key == 'S' || key == 's') {
    for (int i = 0; i < SENSING_NUM; i++) {
      output[i].flush();
      output[i].close();
    }
    println("Save file.");
  }

  if (!isCollecting && selectedNumber != RECORDED) {
    for (int i = 0; i < names.length; i++) {
      if (key - '0' == i) {
        selectedNumber = i;
      }
    }
  };
}

void keyReleased() {
  if (selectedNumber >= 0) {
    record(selectedNumber);
    selectedNumber = RECORDED;
  }
}
