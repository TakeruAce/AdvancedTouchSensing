/* Electro magnet controller */
import processing.serial.*;

Serial myElectroMagnetPort;
int myElectroMagnetId = 8;
void electroMagnetSerialSetup() {
  String portName = Serial.list()[myElectroMagnetId];
  println(Serial.list());
  myElectroMagnetPort = new Serial(this, portName, 9600);
}

void testControll() {
  myElectroMagnetPort.write("a");
}
