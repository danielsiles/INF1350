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

unsigned long bt1Press;
unsigned long bt2Press;

int buttonState1 = 0;
int buttonState2 = 0;
int buttonState3 = 0;

int state = 1;

int blinkTime = 1000;

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
  Serial.println(blinkTime);
   // read the state of the pushbutton value:
  buttonState1 = digitalRead(KEY1);
  buttonState2 = digitalRead(KEY2);
  buttonState3 = digitalRead(KEY3);
  
  if(buttonState1 == LOW) {
      bt1Press = millis();
      blinkTime -= 10;
      if(blinkTime < 100) {
        blinkTime = 100;
      }
      if(bt1Press <= bt2Press + 500) {
        while(1);
      }
  }
  if(buttonState2 == LOW) {
      bt2Press = millis();
      blinkTime += 10;
      if(bt2Press <= bt1Press + 500) {
        while(1);
      }
  }
  unsigned long now = millis();

  if(now >= old + blinkTime) {
    old = now;
    state = !state;
    digitalWrite(LED1, state);
  }
}
