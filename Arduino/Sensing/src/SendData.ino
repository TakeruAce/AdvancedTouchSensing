byte yMSB = 0;
byte yLSB = 0;
byte xMSB = 0;
byte xLSB = 0;
byte zeroByte = 128;
byte checkSum = 0;

void SendDatum(int command, unsigned int yValue,unsigned int xValue) {
  /*
    y = 01010100 11010100    (x & y are 2 Byte integers)
    yMSB      yLSB      send seperately -> reciever joins them
  */

  yLSB = lowByte(yValue);
  yMSB = highByte(yValue);
  xLSB = lowByte(xValue);
  xMSB = highByte(xValue);

  /*
    Only the very first Byte may be a zero, this way allows the computer
    to know that if a Byte recieved is a zero it must be the start byte.
    If data bytes actually have a value of zero, They are given the value
    one and the bit in the zeroByte that represents that Byte is made
    high.
  */

  zeroByte = 128; // 10000000

  if (yLSB==0) {
    yLSB=1;
    zeroByte=zeroByte+1;
  }
  if (yMSB==0) {
    yMSB=1;
    zeroByte=zeroByte+2;
  }
  if (xLSB==0) {
    xLSB=1;
    zeroByte=zeroByte+4;
  }
  if (xMSB==0) {
    xMSB=1;
    zeroByte=zeroByte+8;
  }

  // Calculate the remainder of: sum of all the Bytes divided by 255
  checkSum = (command + yMSB + yLSB + xMSB + xLSB + zeroByte) % 255;

  if (checkSum != 0) {
    Serial.write(byte(0));            // send start bit
    Serial.write(byte(command));      // command eg: Which Graph is this data for

    Serial.write(byte(yMSB));         // Y value's most significant byte
    Serial.write(byte(yLSB));         // Y value's least significant byte
    Serial.write(byte(xMSB));         // X value's most significant byte
    Serial.write(byte(xLSB));         // X value's least significant byte

    Serial.write(byte(zeroByte));     // Which values have a zero value
    Serial.write(byte(checkSum));     // Error Checking Byte
  }
}

void SendData(unsigned int dataIndex, float array1[], float array2[]) {
  SendDatum(1 + 3 * dataIndex, 1, 1);                // Tell PC an array is about to be sent
  for (int x = 0; x < sizeOfArray; x++) {
    SendDatum(2 + 3 * dataIndex, round(array1[x]), round(array2[x]));
  }
  SendDatum(3 + 3 * dataIndex, 1, 1);            // Confirm arrrays have been sent
}
