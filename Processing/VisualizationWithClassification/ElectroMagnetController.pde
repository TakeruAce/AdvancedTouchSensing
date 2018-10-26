/* Electro magnet controller */
Serial myElectroMagnetPort;
int myElectroMagnetId = 8;
void electroMagnetSerialSetup() {
  String portName = Serial.list()[myElectroMagnetId];
  myElectroMagnetPort = new Serial(this, portName, 250000);
}

void testControll() {
  myElectroMagnetPort.write("a");
}
