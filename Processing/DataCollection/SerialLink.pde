import processing.serial.*;

int PortSelected = 11;

int xValue, yValue, Command;
boolean Error = true;

boolean UpdateGraph = true;
int lineGraph;
int ErrorCounter = 0;
int TotalRecieved = 0;

boolean DataReceived1 = false, DataReceived2 = false, DataReceived3 = false;

float[] DynamicArrayTime1, DynamicArrayTime2, DynamicArrayTime3;
float[] Time1, Time2, Time3;
float[] Voltage1, Voltage2, Voltage3;
float[] current;
float[] DynamicArray1, DynamicArray2, DynamicArray3;

float[] PowerArray = new float[0];
float[] DynamicArrayPower = new float[0];
float[] DynamicArrayTime = new float[0];

String portName;
String[] ArrayOfPorts = new String[PortSelected];

boolean DataReceived = false, Data1Recieved=false, Data2Recieved=false;
int incrament = 0;

int NumOfSerialBytes = 8;
int[] serialInArray = new int[NumOfSerialBytes];
int serialCount = 0;
int xMSB, xLSB, yMSB, yLSB;

Serial myPort;

boolean SerialPortSetup() {
  portName = Serial.list()[PortSelected];
  ArrayOfPorts=Serial.list();
  println("Port list:");
  println("=====================================");
  println(ArrayOfPorts);
  println("=====================================");
  println("Selected port: " + portName);
  myPort = new Serial(this, portName, 115200);
  if (myPort == null) {
    exit();
  }
  myPort.clear();
  myPort.buffer(20);
  return true;
}

void serialEvent(Serial myPort) {
  while (myPort.available() > 0) {
    int inByte = myPort.read();
    if (inByte == 0) {
      serialCount = 0;
    } else if (inByte > 255) {
      println(" inByte = "+inByte);
      exit();
    }

    serialInArray[serialCount] = inByte;
    serialCount++;

    Error = true;
    if (serialCount >= NumOfSerialBytes ) {
      serialCount = 0;

      TotalRecieved++;

      int Checksum = 0;
      for (int x = 0; x < serialInArray.length - 1; x++) {
        Checksum = Checksum + serialInArray[x];
      }
      Checksum = Checksum % 255;

      if (Checksum == serialInArray[serialInArray.length - 1]) {
        Error = false;
        DataReceived = true;
      }
      else {
        Error = true;
        DataReceived = false;
        ErrorCounter++;
        println("Error:  " + ErrorCounter + " / " + TotalRecieved + " : " + float(ErrorCounter/TotalRecieved) * 100 + "%");
      }
    }

    if (!Error) {
      int zeroByte = serialInArray[6];

      xLSB = serialInArray[3];
      if ( (zeroByte & 1) == 1) xLSB=0;
      xMSB = serialInArray[2];
      if ( (zeroByte & 2) == 2) xMSB=0;

      yLSB = serialInArray[5];
      if ( (zeroByte & 4) == 4) yLSB=0;

      yMSB = serialInArray[4];
      if ( (zeroByte & 8) == 8) yMSB=0;

      // Combine bytes to form large integers
      xValue   = xMSB << 8 | xLSB;
      yValue   = yMSB << 8 | yLSB;
      /*
        How it works:

        if xMSB = 10001001 and xLSB = 0100 0011
        xMSB << 8 = 10001001 00000000
        xLSB = 01000011
        xLSB | xMSB = 10001001 01000011
        xValue = 10001001 01000011 (xValue is a 2 byte number 0 -> 65536)
      */

      Command  = serialInArray[1];
      switch(Command) {
        // add values
        case 1:
          try {
            DynamicArrayTime3 = append(DynamicArrayTime3, (xValue));
            DynamicArray3 = append(DynamicArray3, (yValue));
            break;
          } catch(NullPointerException e) {
            println("Warning: Arrays are not initialized in this loop.");
          }
          break;

        // init arrays
        case 2:
          DynamicArrayTime3 = new float[0];
          DynamicArray3 = new float[0];
          break;

        // export arrays
        case 3:
          Time3 = DynamicArrayTime3;
          Voltage3 = DynamicArray3;
          DataReceived3 = true;
          break;

        // Data is added to dynamic arrays
        case 4:
          DynamicArrayTime2 = append(DynamicArrayTime2, xValue);
          DynamicArray2 = append(DynamicArray2, (yValue - 16000.0) / 32000.0 * 20.0);
          break;

        // An array of unknown size is about to be recieved, empty storage arrays
        case 5:
          DynamicArrayTime2 = new float[0];
          DynamicArray2 = new float[0];
          break;

        // Array has finnished being recieved, update arrays being drawn
        case 6:
          Time2 = DynamicArrayTime2;
          current = DynamicArray2;
          DataReceived2 = true;
          break;

        case 20:
          PowerArray = append( PowerArray, yValue );
          break;

        case 21:
          DynamicArrayTime = append( DynamicArrayTime, xValue );
          DynamicArrayPower = append( DynamicArrayPower, yValue );
          break;
      }
    }
  }
  redraw();
}
