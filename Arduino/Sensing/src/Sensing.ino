/*
  Illutron take on Disney style capacitive touch sensor using only passives and Arduino
  Dzl 2012

                                   10nF
    PWM Output --[10k]-+-----10mH---+--||-- OBJECT
                       |            |
                      3.3k          |
                       |            V 1N4148 diode
                      GND           |
                                    |
    Analog Input ---+------+--------+
                    |      |
                  100pF   1MOmhm
                    |      |
                   GND    GND

  PWM Output:     9 & 10 (16bit timer)
  Wave:           High frequency PWM
  Method:         Low compare match
  Clock Division: None
  Top:            255
  Threshold:      TOP / 2
*/

#define SET(x) (x |= (1<<0))
#define CLR(x) (x &= (~(1<<0)))

#define SENSING_NUM 2
#define MIN_PERIOD 30
#define MAX_PERIOD 255
#define SAMPLE_SIZE SENSING_NUM
#define SAMPLE_NUM (MAX_PERIOD - MIN_PERIOD) / SAMPLE_SIZE

int v[SENSING_NUM];
float results[SENSING_NUM][SAMPLE_NUM];
float freq[SENSING_NUM][SAMPLE_NUM];
int sizeOfArray = SAMPLE_NUM;

void setup() {
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  TCCR1A = 0b10100010;
  TCCR1B = 0b00011001;
  ICR1 = MIN_PERIOD;
  OCR1A = MIN_PERIOD / 2;
  OCR1B = MIN_PERIOD / 2;

  Serial.begin(115200);
  for (int i = 0; i < SENSING_NUM; i++) {
    for (int j = 0; j < SAMPLE_NUM; j++) {
      results[i][j] = 0;
    }
  }
}

void loop() {
  for (unsigned int d = 0; d < SAMPLE_NUM; d++) {
    for (int i = 0; i < SENSING_NUM; i++) {
      v[i] = analogRead(i);
      if (d < 1) {
        results[i][d] = (results[i][d] + (float)(v[i])) / 2;
      } else {
        results[i][d] = (results[i][d - 1] + results[i][d] + (float)(v[i])) / 3;
      }
      freq[i][d] = d * SAMPLE_SIZE + MIN_PERIOD;
    }
    // Stop generator
    CLR(TCCR1B);
    // Reload new frequency
    TCNT1 = 0;
    ICR1 = d * SAMPLE_SIZE + MIN_PERIOD;
    OCR1A = (d * SAMPLE_SIZE + MIN_PERIOD) / 2;
    OCR1B = (d * SAMPLE_SIZE + MIN_PERIOD) / 2;
    // Restart generator
    SET(TCCR1B);
  }
  for (int i = 0; i < SENSING_NUM; i++) {
    SendData(i, freq[i], results[i]);
  }
}
