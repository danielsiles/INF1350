#include "event_driven.h"
#include "app.h"

#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define KEY1       A1
#define KEY2       A2
#define KEY3       A3
#define POT        A0

int ledState = 0;
int tm = 1000;
unsigned long btPress1;
unsigned long btPress2;
void appInit(void) {
  pinMode(LED1, OUTPUT);
  
  button_listen(KEY1);
  button_listen(KEY2);
  timer_set(tm);
  Serial.begin(9600);
}
void button_changed(int p, int v) {
    if(p == KEY1) {
        btPress1 = millis();
        if(btPress1 < btPress2 + 500) {
          while(1);  
        }
        tm -= 50;
        if(tm < 100) {
          tm = 100;  
        }
    }
    if(p == KEY2) {
      btPress2 = millis();
        if(btPress2 < btPress1 + 500) {
          while(1);  
        }
      tm += 50;  
    }

    timer_set(tm);
}
void timer_expired(void) {
    ledState = !ledState;
    digitalWrite(LED1, ledState);
}
