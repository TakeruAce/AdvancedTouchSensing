//****************************************************************************************
// Illutron take on Disney style capacitive touch sensor using only passives and Arduino
// Dzl 2012
//****************************************************************************************

//                              10n
// PIN 9 --[10k]-+-----10mH---+--||-- OBJECT
//               |            |
//              3.3k          |
//               |            V 1N4148 diode
//              GND           |
//                            |
//Analog 0 ---+------+--------+
//            |      |
//          100pf   1MOmhm
//            |      |
//           GND    GND

#define SET(x,y) (x |= (1<<y))
#define CLR(x,y) (x &= (~(1<<y)))
#define CHK(x,y) (x & (1<<y))
#define TOG(x,y) (x ^= (1<<y))

#define MIN_TOP 30
#define MAX_TOP 255
#define N MAX_TOP - MIN_TOP

float results[N];
float freq[N];
int sizeOfArray = N;

void setup() {
  /*
    Pin:            9 & 10 (16bit timer)
    Wave:           High frequency PWM
    Method:         Low compare match
    Clock division: None
    Top:            110
    Threshold:      55
  */
  TCCR1A = 0b10100010;
  TCCR1B = 0b00011001;
  ICR1 = MIN_TOP;
  OCR1A = MIN_TOP / 2;
  OCR1B = MIN_TOP / 2;

  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  pinMode(8,OUTPUT); // Sync test pin

  Serial.begin(115200);
  for (int i = 0; i < N; i++) {
    results[i] = 0;
  }
}

void loop() {
  unsigned int d;

  int counter = 0;
  for (unsigned int d = 0; d < N; d++) {
    int v = analogRead(0); // Read response signal
    CLR(TCCR1B, 0);        // Stop generator
    TCNT1 = 0;             // Reload new frequency
    ICR1 = d + MIN_TOP;
    OCR1A = (d + MIN_TOP) / 2;
    OCR1B = (d + MIN_TOP) / 2;
    SET(TCCR1B, 0);        //-Restart generator

    results[d] = results[d] * 0.5 + (float)(v) * 0.5; //Filter results

    freq[d] = d + MIN_TOP;
  }

   PlottArray(1, freq, results);

  TOG(PORTB, 0);            //-Toggle pin 8 after each sweep (good for scope)
}
