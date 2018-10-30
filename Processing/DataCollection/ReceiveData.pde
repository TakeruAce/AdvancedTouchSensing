import processing.serial.*;

// Port
int PortSelected = 11;
String portName;
String[] ArrayOfPorts = new String[PortSelected];
Serial myPort;

// Data
boolean DataReceived = false;
float[] DynamicTime;
float[] DynamicVoltage;
float[] Time;
float[] Voltage;

// Communication
int xValue, yValue, Command;
boolean Error = true;
int ErrorCounter = 0;
int TotalRecieved = 0;
int NumOfSerialBytes = 8;
int[] serialInArray = new int[NumOfSerialBytes];
int serialCount = 0;
int xMSB, xLSB, yMSB, yLSB;

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

      Command  = serialInArray[1];
      switch(Command) {
        // Init arrays
        case 1:
          DynamicTime = new float[0];
          DynamicVoltage = new float[0];
          break;

        // Add values
        case 2:
          try {
            DynamicTime = append(DynamicTime, (xValue));
            DynamicVoltage = append(DynamicVoltage, (yValue));
            break;
          } catch(NullPointerException e) {
            println("Warning: Arrays are not initialized in this loop.");
          }
          break;

        // Export arrays
        case 3:
          Time = DynamicTime;
          Voltage = DynamicVoltage;
          DataReceived = true;
          break;
      }
    }
  }
  redraw();
}
