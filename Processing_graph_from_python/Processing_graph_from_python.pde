import processing.net.*;
int port = 10001;
Server server_of_processing;
Client client_of_processing;

Graph MyArduinoGraph = new Graph(150, 80, 500, 300, color (200, 20, 20));
float[] gestureOne=null;
float[] gestureTwo = null;
float[] gestureThree = null;

float[][] gesturePoints = new float[4][2];
float[] gestureDist = new float[4];
String[] names = {"Nothing", "One-finger-Touch", "Two-finger-Touch","Three-finger-Touch"};
String currentState = "";
boolean isSendStarted = false;
boolean isServerResReceived = true;

void setup() {

  size(1200, 500); 

  MyArduinoGraph.xLabel="Readnumber";
  MyArduinoGraph.yLabel="Amp";
  MyArduinoGraph.Title=" Graph";  
  noLoop();
  PortSelected=7;      /* ====================================================================
   adjust this (0,1,2...) until the correct port is selected 
   In my case 2 for COM4, after I look at the Serial.list() string 
   println( Serial.list() );
   [0] "COM1"  
   [1] "COM2" 
   [2] "COM4"
   ==================================================================== */
  SerialPortSetup();      // speed of 115200 bps etc.
  server_of_processing = new Server(this,port);
  println("server address:" + server_of_processing.ip());
  client_of_processing = new Client(this,"",10002);
  frameRate(10);
}


void draw() {
  //receive message from python
  readServerData();
  print(currentState);
  if (!isSendStarted && isServerResReceived) {
    isServerResReceived = false;
    sendVoltageData();
  }
  
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
   // for (int i = 0; i < 4;i++)

   // {

   //   //  gesturePoints[i][0] = 
   //   if (mousePressed && mouseX > 750 && mouseX < 800 && mouseY > 100*(i+1) && mouseY < 100*(i+1) + 50)
   //   {
   //     fill(255, 0, 0);

   //     gesturePoints[i][0] = Time3[MyArduinoGraph.maxI];
   //     gesturePoints[i][1] = Voltage3[MyArduinoGraph.maxI];
   //   }
   //   else
   //   {
   //     fill(255, 255, 255);
   //   }

   ////calucalte individual dist
   //   gestureDist[i] = dist(Time3[MyArduinoGraph.maxI], Voltage3[MyArduinoGraph.maxI], gesturePoints[i][0], gesturePoints[i][1]);
   //   totalDist = totalDist + gestureDist[i];
   //   if(gestureDist[i] < currentMaxValue || i == 0)
   //   {
   //      currentMax = i;
   //     currentMaxValue =  gestureDist[i];
   //   }
   // }
   // totalDist=totalDist /3;

   // for (int i = 0; i < 4;i++)
   // {
   //   float currentAmmount = 0;
   //   currentAmmount = 1-gestureDist[i]/totalDist;
   //   if(currentMax == i)
   //    {
   //      fill(0,0,0);
   // //       text(names[i],50,450);
   //    fill(currentAmmount*255.0f, 0, 0);
     

   //    }
   //    else
   //    {
   //      fill(255,255,255);
   //    }

   //   stroke(0, 0, 0);
   //   rect(750, 100 * (i+1), 50, 50);
   //   fill(0,0,0);
   //   textSize(30);
   //   text(names[i],810,100 * (i+1)+25);

   //   fill(255, 0, 0);
   ////   rect(800,100* (i+1), max(0,currentAmmount*50),50);
   // }
    fill(0,0,0);
    textSize(30);
    text(currentState,810,100*1+25);
    

  }
}

void stop()
{

  myPort.stop();
  super.stop();
}

void readServerData() {
  Client client_of_python = server_of_processing.available();
  //println(client_of_python);
  if (client_of_python != null) {
    String whatClientSaid = client_of_python.readString();
    isServerResReceived = true;
    if (whatClientSaid != null) {
      currentState = whatClientSaid;
      println(currentState);
    } else {
      currentState = "";
    }
  }
}

void sendVoltageData() {
  isSendStarted = true;
  if (Voltage3 != null && Voltage3.length != 0) {
    //client_of_processing.write("start/");
    for (int i =0;i<Voltage3.length;i++) {
      client_of_processing.write(str(Voltage3[i]) + "/");
    }
    client_of_processing.write("finished");
    isSendStarted = false;
  }
}
