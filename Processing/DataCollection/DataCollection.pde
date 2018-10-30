int graphWidth = 200;
int graphHeight = 150;
int graphMargin = 175;

Graph[] graphs = {
  new Graph(115, 80, graphWidth, graphHeight, color (200, 20, 20)),
  new Graph(115 + (graphWidth + graphMargin), 80, graphWidth, graphHeight, color (200, 20, 20)),
  new Graph(115, 80 + (graphHeight + graphMargin), graphWidth, graphHeight, color (200, 20, 20)),
  new Graph(115 + (graphWidth + graphMargin), 80 + (graphHeight + graphMargin), graphWidth, graphHeight, color (200, 20, 20))
};
float[] gestureOne=null;
float[] gestureTwo = null;
float[] gestureThree = null;

String[] names = {"Nothing", "One-finger-Touch", "Near"};
PrintWriter output;
boolean isCollecting = false;
void setup() {
  size(1280, 960);

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

  if (SerialPortSetup()) { // speed of 115200 bps etc.
    String filename = nf(year(),4) + nf(month(),2) + nf(day(),2) + nf(hour(),2) + nf(minute(),2) + nf(second(),2);
    output = createWriter("data/" + filename + ".csv");
  } else {
    exit();
  }
  frameRate(20);
}


void draw() {
  background(255);

  if ( DataReceived3 ) {
    pushMatrix();
    pushStyle();
    try {
      for (int i = 0; i < graphs.length; i++) {
        graphs[i].yMax = 700;
        graphs[i].yMin = 0;
        graphs[i].xMax = int(max(Time3));
        graphs[i].DrawAxis();
        graphs[i].smoothLine(Time3, Voltage3);
      }
    } catch(NullPointerException e) {
      println("Warning: data are not initialized.");
    }
    popStyle();
    popMatrix();

    fill(0, 0, 0);
    textSize(20);
    text("Click label to collect data for a second.", 800, 40);
    text("Type 's' to save collected data.", 800, 65);

    /* ====================================================================
     Gesture compare
     ====================================================================  */
    for (int i = 0; i < names.length;i++) {
      if (mouseX > 800 && mouseX < 850 && mouseY > 100 * (i + 1) && mouseY < 100 * (i + 1) + 50) {
        fill(255, 0, 0);
      } else {
        fill(255, 255, 255);
      }
      stroke(0, 0, 0);
      rect(800, 100 * (i+1), 50, 50);
      fill(0,0,0);
      textSize(30);
      text(names[i],860,100 * (i+1)+25);

      fill(255, 0, 0);
    }
  }
}

void keyPressed() {
  if (key == 'S' || key == 's') {
    output.flush();
    output.close();
    println("Save file.");
  }
}

void stop() {
  output.flush();
  output.close();
  myPort.stop();
  super.stop();
}

void mousePressed() {
  if (isCollecting) return;
  int count = 0;
  println("Start recording...");
  for (int i = 0; i < names.length; i++) {
    if (mousePressed && mouseX > 800 && mouseX < 850 && mouseY > 100 * (i+1) && mouseY < 100 * (i+1) + 50) {
      println("Press '" + names[i] + "'");
      while(count < 20) {
        output.print(names[i] + ",");
        for (int j = 0;j<Voltage3.length;j++) {
          output.print(Voltage3[j] + ",");
        }
        output.println();
        count++;
        delay(50);
      }
    }
  }
  println("Finish recording.");
}
