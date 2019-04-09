/* Define shift register pins used for seven segment display */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
#define LED1       10
#define LED2       11
#define LED3       12
#define LED4       13
#define BUZZ        3
#define KEY1       A1
#define KEY2       A2
#define KEY3       A3
#define POT        A0
#include <GFButton.h>

GFButton button1(KEY1);
GFButton button2(KEY2);
GFButton button3(KEY3);

int leds[4] = { LED1, LED2, LED3, LED4 };

long day = 86400000; // 86400000 milliseconds in a day
long hour = 3600000; // 3600000 milliseconds in an hour
long minute = 60000; // 60000 milliseconds in a minute
long second =  1000; // 1000 milliseconds in a second

enum {
    SHOW_CLOCK,
    SHOW_ALARM,
    SET_CLOCK_H,
    SET_CLOCK_M,
    SET_ALARM_H,
    SET_ALARM_M,
    ALERT
};

int states[7] = { SHOW_CLOCK, SHOW_ALARM, SET_CLOCK_H, SET_CLOCK_M, SET_ALARM_H, SET_ALARM_M, ALERT}; 

int alarmOn = false;
int stateIndex = 0 ;

// Display digits
int digits[4] = {1, 2, 0, 0};
unsigned long currentTime = 86400000 / 2;

int alarmH = 12;
int alarmM = 10;

int alarmSetH = 0;
int alarmSetM = 0;

int clockSetH = 0;
int clockSetM = 0;

unsigned long latestBlink = millis();
unsigned long latestPress = millis();
 
/* Segment byte maps for numbers 0 to 9 */
const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90, 0xFF};
/* Byte maps to select digit 1 to 4 */
const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

void buttonHandler1(GFButton& event){
    latestPress = millis();
    if(button3.isPressed()) {
        stateIndex = 0;
    }
    else if(button2.isPressed()) {
        alarmOn = !alarmOn;
    }
} 

void buttonHandler2(GFButton& event){
  Serial.println(stateIndex);
  latestPress = millis();
  if(button1.isPressed()) {
        alarmOn = !alarmOn;
  }
  else {
    if(states[stateIndex] == SET_CLOCK_H) {
        if(clockSetH == 23) {
          clockSetH = 0;
        }
        else {
          clockSetH++;
        }
        currentTime = (hour * clockSetH + minute * clockSetM);
    }
    else if(states[stateIndex] == SET_CLOCK_M) {
        if(clockSetM == 59) {
          clockSetM = 0;
        }
        else {
          clockSetM++;
        }
        currentTime = (hour * clockSetH + minute * clockSetM);
        
    }
    else if(states[stateIndex] == SET_ALARM_H) {
        if(alarmH == 23) {
          alarmH = 0;
        }
        else {
          alarmH++;
        }
    }
    else if(states[stateIndex] == SET_ALARM_M) {
        if(alarmM == 59) {
          alarmM = 0;
        }
        else {
          alarmM++;
        }
    }
    else if(states[stateIndex] == ALERT) {
      // Soneca
      alarmOn = true;
      stateIndex = 0;
      digitalWrite(BUZZ, HIGH);
      alarmM += 1;
      if(alarmM > 59) {
        alarmM -= 60;
        alarmH += 1;
        if(alarmH > 23) {
          alarmH = 0;
        }
      }
    }
  }
} 

void buttonHandler3(GFButton& event){
  latestPress = millis();
  if(button1.isPressed()) {
        stateIndex = 0;
  }
  else {
    Serial.println(stateIndex);
    if(stateIndex == 5) {
        stateIndex = 0;
    }
    else if(stateIndex > 5){
        alarmOn = false;
        stateIndex = 0;
        digitalWrite(BUZZ, HIGH);
    }
    else {
        stateIndex++;
    }
  }
} 


void setup() {
  /* Set DIO pins to outputs */
  Serial.begin(9600);
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  pinMode(BUZZ, OUTPUT);
  digitalWrite(BUZZ,HIGH);
  ledsOff();
  button1.setPressHandler(buttonHandler1);
  button2.setPressHandler(buttonHandler2);
  button3.setPressHandler(buttonHandler3);
}
 
/* Main program */
void loop() {
  button1.process();
  button2.process();
  button3.process();

  if(states[stateIndex] == SHOW_CLOCK) {
      showCurrentTime();
      ledsOn(LOW, HIGH, HIGH, HIGH);
  }
  else if(states[stateIndex] == SHOW_ALARM) {
      showAlarm();
      ledsOn(HIGH, LOW, HIGH, HIGH);
  }
  else if(states[stateIndex] == SET_CLOCK_H) {
      blinkDisplay1(0, 1);
      ledsOn(LOW, HIGH, LOW, HIGH);
      checkInactiveUser();
  }
  else if(states[stateIndex] == SET_CLOCK_M) {
      blinkDisplay1(1, 1);
      ledsOn(LOW, HIGH, LOW, HIGH);
      checkInactiveUser();
  }
  else if(states[stateIndex] == SET_ALARM_H) {
      blinkDisplay1(0, 0);
      ledsOn(HIGH, LOW, LOW, HIGH);
  }
  else if(states[stateIndex] == SET_ALARM_M) {
      blinkDisplay1(1, 0);
      ledsOn(HIGH, LOW, LOW, HIGH);
      checkInactiveUser();
  }
  else if(states[stateIndex] == ALERT) {
      showCurrentTime();
      digitalWrite(BUZZ, LOW);
      checkInactiveUser();
  }
  
  if(alarmOn) {
    checkForAlarm();
    digitalWrite(leds[3], LOW);
  }
  else {
    digitalWrite(leds[3], HIGH);
  }
  WriteNumberToSegment(0 , digits[0]);
  WriteNumberToSegment(1 , digits[1]);
  WriteNumberToSegment(2 , digits[2]);
  WriteNumberToSegment(3 , digits[3]);
}
 
/* Write a decimal number between 0 and 9 to one of the 4 digits of the display */
void WriteNumberToSegment(byte Segment, byte Value) {
  digitalWrite(LATCH_DIO,LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[Value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[Segment] );
  digitalWrite(LATCH_DIO,HIGH);
}

void showCurrentTime() {
  unsigned long timeNow = millis() + currentTime;

  int hours = (timeNow % day) / hour;                    
  int minutes = ((timeNow % day) % hour) / minute ;  
  clockSetH = hours;
  clockSetM = minutes;
  setDigits(0, hours);
  setDigits(1, minutes);
  
}

void showAlarm() {
  setDigits(0, alarmH);
  setDigits(1, alarmM);
}

void setDigits(int mode, int value) {
  if(mode == 0) {
      digits[1] = value % 10;
      digits[0] = (value / 10) % 10;
  }
  else if(mode == 1) {
      digits[3] = value % 10;
      digits[2] = (value / 10) % 10;
  }
}

void clearDigits(int mode) {
  if(mode == 0) {
    digits[0] = 10;
    digits[1] = 10;
  }
  else if(mode == 1) {
    digits[2] = 10;
    digits[3] = 10;  
  } 
}

void blinkDisplay1(int mode, int isClock) {
  
  if(millis() > latestBlink + 800) {
      if(mode == 0) {
          digits[0] = 10;
          digits[1] = 10;
      }
      else if(mode == 1) {
          digits[2] = 10;
          digits[3] = 10;  
      } 
    if(millis() > latestBlink + 1000) {
      latestBlink = millis();  
    }
  }
  else {
    if(isClock) {
        showCurrentTime();
    }
    else {
        showAlarm();
    }
    
  }
  
}

void checkForAlarm() {
  unsigned long timeNow = millis() + currentTime;

  int hours = (timeNow % day) / hour;                    
  int minutes = ((timeNow % day) % hour) / minute;  

  if(hours == alarmH && minutes == alarmM) {
    stateIndex = 6;
  }
}

void ledsOff() {
  for(int i = 0; i < 4; i++) {
    digitalWrite(leds[i], HIGH);
  }
}

void ledsOn(int a, int b, int c, int d) {
  digitalWrite(leds[0], a);
  digitalWrite(leds[1], b);
  digitalWrite(leds[2], c);
  digitalWrite(leds[3], d);
}

void checkInactiveUser() {
  if(millis() > latestPress + 10000) {
    latestPress = millis();
    stateIndex = 0;
  }
}
