import controlP5.*;
ControlP5 Button;
String writeStr = "";

void setup() {
  size(500, 500);

  Button = new ControlP5(this);
  Button.addButton("a")
    .setLabel("Send a")//テキスト
    .setPosition(200, 40)
    .setSize(100, 40);
    //slider.addSlider(name, value (float), x, y, width, height)
  Button.addButton("b")
    .setLabel("Send b")//テキスト
    .setPosition(200, 100)
    .setSize(100, 40);
  Button.addButton("c")
    .setLabel("Send c")//テキスト
    .setPosition(200, 160)
    .setSize(100, 40);
    
  electroMagnetSerialSetup();
}

void draw() {
  if (writeStr != "") {
    myElectroMagnetPort.write(writeStr);
  }
}

void a() {
  println("a");
  writeStr = "a";
}

void b() {
  println("b");
  writeStr = "b";
}

void c() {
  println("c");
  writeStr = "c";
}
