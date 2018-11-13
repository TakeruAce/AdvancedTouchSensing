/*
  Illutron take on Disney style capacitive touch sensor using only passives and Arduino
  Dzl 2012

                                   10nF
    PWM Output -[*Omhm]-+-----10mH---+--||-- OBJECT
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
  Threshold:      TOP / 2

  PWM Output:     5 & 6 (8bit timer)
  Wave:           CTC
  Method:         Toggle

  Clock Division: None
  Min Top Count:  30
  Max Top Count:  255
*/

// Parameter
#define SENSING_NUM 4
#define MIN_COUNT 30
#define MAX_COUNT 255
#define SAMPLE_SIZE SENSING_NUM
#define SAMPLE_NUM (MAX_COUNT - MIN_COUNT) / SAMPLE_SIZE
#define AVERAGE_NUM 5
#define IS_FOR_ACTUATOR true

// Variable
int v[SENSING_NUM];
float results[SENSING_NUM][SAMPLE_NUM];
float freq[SENSING_NUM][SAMPLE_NUM];
int sizeOfArray = SAMPLE_NUM;

// Function
#define SET(x, y) (x |= (1<<y))
#define CLR(x, y) (x &= (~(1<<y)))

void setup() {
  pinMode(9, OUTPUT);
  pinMode(10, OUTPUT);
  TCCR1A = 0b10100010;
  TCCR1B = 0b00011001;
  ICR1 = MIN_COUNT;
  OCR1A = MIN_COUNT / 2;
  OCR1B = MIN_COUNT / 2;

  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  TCCR0A = 0b01010010;
  TCCR0B = 0b00000001;
  OCR0A = MIN_COUNT / 2;
  OCR0B = MIN_COUNT / 2;

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
      v[i] = 0;
      if (IS_FOR_ACTUATOR) {
        for (int j = 0; j < AVERAGE_NUM_FOR_ACTUATOR; j++) {
          v[i] += analogRead(i) / AVERAGE_NUM_FOR_ACTUATOR;
        }
        results[i][d] = results[i][d] * 0.0 + (float)(v[i]) * 1.0;
      } else {
        for (int j = 0; j < AVERAGE_NUM; j++) {
          v[i] += analogRead(i) / AVERAGE_NUM;
        }
        results[i][d] = results[i][d] * 0.5 + (float)(v[i]) * 0.5;
      }

      freq[i][d] = d * SAMPLE_SIZE + MIN_COUNT;
    }
    // Pin 9 & 10
    // Stop generator
    CLR(TCCR1B, CS10);
    // Reload new frequency
    TCNT1 = 0;
    ICR1 = d * SAMPLE_SIZE + MIN_COUNT;
    OCR1A = (d * SAMPLE_SIZE + MIN_COUNT) / 2;
    OCR1B = (d * SAMPLE_SIZE + MIN_COUNT) / 2;
    // Restart generator
    SET(TCCR1B, CS10);

    // Pin 5 & 6
    // Stop generator
    CLR(TCCR0B, CS00);
    // Reload new frequency
    OCR0A = (d * SAMPLE_SIZE + MIN_COUNT) / 2;
    OCR0B = (d * SAMPLE_SIZE + MIN_COUNT) / 2;
    // Restart generator
    SET(TCCR0B, CS00);
  }
  for (int i = 0; i < SENSING_NUM; i++) {
    SendData(i, freq[i], results[i]);
  }
}
