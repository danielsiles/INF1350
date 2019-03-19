#include "event_driven.h"
#include "app.h"


int buttons[3] = {0, 0, 0};
int buttonsState[3] = {HIGH, HIGH, HIGH};
int btCounter= 0;

unsigned long old;

int timer = 1000;

void button_listen(int pin) {
  if(btCounter < 3){
    buttons[btCounter] = pin;
    btCounter++;
  }     
}

void timer_set(int ms) {
  timer = ms;
}

void button_changed(int pin, int v);
void timer_expired(void);
void appInit(void);

void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  Serial.begin(9600);
  appInit();
  for(int i = 0; i < btCounter; i++){
      pinMode(buttons[i], INPUT_PULLUP);
  }
}

// the loop function runs over and over again forever
void loop() {
  for(int i = 0; i < btCounter; i++){
      int state = digitalRead(buttons[i]);
//      Serial.println(state);
//      Serial.println(btCounter);
      if(state != buttonsState[i]) {
        button_changed(buttons[i], state);
        buttonsState[i] = state;  
      }
  }

  unsigned long now = millis();
  if(now >= old + timer) {
    old = now;
    timer_expired();
  }
}
