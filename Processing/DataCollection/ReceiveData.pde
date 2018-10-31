import processing.serial.*;

// Port
final int PORT_SELECTED = 11;
String portName;
String[] ArrayOfPorts = new String[PORT_SELECTED];
Serial myPort;

// Data
final int NUM_DATA = 2;
boolean DataReceived = false;
float[][] DynamicTime = new float[NUM_DATA][];
float[][] DynamicVoltage = new float[NUM_DATA][];
float[][] Time = new float[NUM_DATA][];
float[][] Voltage = new float[NUM_DATA][];

// Communication
int xValue, yValue, command, phase, dataIndex;
boolean Error = true;
int ErrorCounter = 0;
int TotalRecieved = 0;
int NumOfSerialBytes = 8;
int[] serialInArray = new int[NumOfSerialBytes];
int serialCount = 0;
int xMSB, xLSB, yMSB, yLSB;

boolean SerialPortSetup() {
  portName = Serial.list()[PORT_SELECTED];
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
  myPort.buffer(NumOfSerialBytes);
  return true;
}

void serialEvent(Serial myPort) {
  while (myPort.available() > 0) {
    int inByte = myPort.read();
    if (inByte == 0) {
      serialCount = 0;
    } else if (inByte > 255) {
      println("inByte = " + inByte);
      exit();
    }

    serialInArray[serialCount] = inByte;
    serialCount++;

    Error = true;
    if (serialCount >= NumOfSerialBytes) {
      serialCount = 0;

      TotalRecieved++;

      int checkSum = 0;
      for (int x = 0; x < serialInArray.length - 1; x++) {
        checkSum = checkSum + serialInArray[x];
      }
      checkSum = checkSum % 255;

      if (checkSum == serialInArray[serialInArray.length - 1]) {
        Error = false;
      } else {
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
      /*
        How it works:

        if xMSB = 10001001 and xLSB = 0100 0011
        xMSB << 8 = 10001001 00000000
        xLSB = 01000011
        xLSB | xMSB = 10001001 01000011
        xValue = 10001001 01000011 (xValue is a 2 byte number 0 -> 65536)
      */
      xValue   = xMSB << 8 | xLSB;
      yValue   = yMSB << 8 | yLSB;

      command  = serialInArray[1];
      phase = command % 3;
      dataIndex = (command - 1) / 3;
      switch(phase) {
        // Init arrays
        case 1:
          DynamicTime[dataIndex] = new float[0];
          DynamicVoltage[dataIndex] = new float[0];
          break;

        // Add values
        case 2:
          try {
            DynamicTime[dataIndex] = append(DynamicTime[dataIndex], (xValue));
            DynamicVoltage[dataIndex] = append(DynamicVoltage[dataIndex], (yValue));
            break;
          } catch (NullPointerException e) {
            println("Warning: arrays are not initialized.");
          }
          break;

        // Export arrays
        case 0:
          Time[dataIndex] = DynamicTime[dataIndex];
          Voltage[dataIndex] = DynamicVoltage[dataIndex];
          if (dataIndex == NUM_DATA - 1) {
            DataReceived = true;
          }
          break;
        default:
          println("Error: The phase is an unexpected value (=" + phase + ").");
          exit();
          break;
      }
    }
  }
  redraw();
}
