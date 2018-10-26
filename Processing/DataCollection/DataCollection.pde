Graph MyArduinoGraph = new Graph(150, 80, 500, 300, color (200, 20, 20));
float[] gestureOne=null;
float[] gestureTwo = null;
float[] gestureThree = null;

float[][] gesturePoints = new float[8][2];
float[] gestureDist = new float[8];
String[] names = {"Nothing", "One-finger-Touch", "Near"};
PrintWriter output;
boolean isCollecting = false;
void setup() {

  size(1200, 600); 

  MyArduinoGraph.xLabel="Number";
  MyArduinoGraph.yLabel="Amp";
  MyArduinoGraph.Title="Graph";  
  noLoop();
  PortSelected=7;
  /* ====================================================================
   adjust this (0,1,2...) until the correct port is selected 
   In my case 2 for COM4, after I look at the Serial.list() string    
   [0] "COM1"  
   [1] "COM2" 
   [2] "COM4"
   ==================================================================== */
  
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

  /* ====================================================================
   Print the graph
   ====================================================================  */

  if ( DataRecieved3 ) {
    pushMatrix();
    pushStyle();
    MyArduinoGraph.yMax=800;      
    MyArduinoGraph.yMin=-200;      
    MyArduinoGraph.xMax=int (max(Time3));
    MyArduinoGraph.DrawAxis();    
    MyArduinoGraph.smoothLine(Time3, Voltage3);
    popStyle();
    popMatrix();

    float gestureOneDiff =0;
    float gestureTwoDiff =0;
    float gestureThreeDiff =0;

    /* ====================================================================
     Gesture compare
     ====================================================================  */
    float totalDist = 0;
    int currentMax = 0;
    float currentMaxValue = -1;
    for (int i = 0; i < names.length;i++)

    {

      //  gesturePoints[i][0] = 
      if (mousePressed && mouseX > 750 && mouseX<800 && mouseY > 100*(i+1) && mouseY < 100*(i+1) + 50)
      {
        fill(255, 0, 0);

        gesturePoints[i][0] = Time3[MyArduinoGraph.maxI];
        gesturePoints[i][1] = Voltage3[MyArduinoGraph.maxI];
        
      }
      else
      {
        fill(255, 255, 255);
      }

   //calucalte individual dist
      gestureDist[i] = dist(Time3[MyArduinoGraph.maxI], Voltage3[MyArduinoGraph.maxI], gesturePoints[i][0], gesturePoints[i][1]);
      totalDist = totalDist + gestureDist[i];
      if(gestureDist[i] < currentMaxValue || i == 0)
      {
         currentMax = i;
        currentMaxValue =  gestureDist[i];
      }
    }
    totalDist=totalDist /3;

    for (int i = 0; i < names.length;i++)
    {
      float currentAmmount = 0;
      currentAmmount = 1-gestureDist[i]/totalDist;
      if(currentMax == i)
       {
         fill(0,0,0);
    //       text(names[i],50,450);
       fill(currentAmmount*255.0f, 0, 0);
     

       }
       else
       {
         fill(255,255,255);
       }

      stroke(0, 0, 0);
      rect(750, 100 * (i+1), 50, 50);
      fill(0,0,0);
      textSize(30);
      text(names[i],810,100 * (i+1)+25);

      fill(255, 0, 0);
   //   rect(800,100* (i+1), max(0,currentAmmount*50),50);
    }
    
    fill(0, 0, 0);
    textSize(20);
    text("Click label to collect data for a second.   /   Type 's' to save collected data.", 55, 500);
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
    if (mouseX > 750 && mouseX < 800 && mouseY > 100 * (i+1) && mouseY < 100 * (i+1) + 50) {
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