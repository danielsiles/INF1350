#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define KEY1       A1
#define KEY2       A2
#define KEY3       A3
#define POT        A0

unsigned long old;
int buttonState = 0;
int state = 1;

void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  Serial.begin(9600);
  pinMode(LED1, OUTPUT);
  pinMode(KEY1, INPUT_PULLUP);
  pinMode(KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);
}

// the loop function runs over and over again forever
void loop() {
   // read the state of the pushbutton value:
  buttonState = digitalRead(KEY1);
  if(buttonState == LOW) {
    digitalWrite(LED1, LOW);
    while(1);
  }
  unsigned long now = millis();

  if(now >= old + 1000) {
    old = now;
    state = !state;
    digitalWrite(LED1, state);
  }
}
