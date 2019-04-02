#include "pindefs.h"
#include <avr/sleep.h>
#include <avr/power.h>

byte state = HIGH;
volatile int counter = 0;

volatile int lastButton1State = 0;
volatile int lastButton2State= 0;

volatile int button1Time = 0;
volatile int button2Time = 0;

int stopLED = 0;

void pciSetup (byte pin) {
    *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));  // enable pin
    PCIFR  |= bit (digitalPinToPCICRbit(pin)); // clear any outstanding interruptjk
    PCICR  |= bit (digitalPinToPCICRbit(pin)); // enable interrupt for the group
}

void timerSetup () {
   TIMSK2 = (TIMSK2 & B11111110) | 0x01;
   TCCR2B = (TCCR2B & B11111000) | 0x07;
}

void enterSleep(void)
{
  set_sleep_mode(SLEEP_MODE_PWR_SAVE);
  sleep_enable();
  sleep_mode();
  sleep_disable();   
}

void setup() {
   pinMode(LED1, OUTPUT); digitalWrite(LED1, state);
   pinMode(LED2, OUTPUT); digitalWrite(LED2, state);
   pinMode(LED3, OUTPUT); digitalWrite(LED3, state);
   pinMode(LED4, OUTPUT); digitalWrite(LED4, state);
   pinMode(KEY2, INPUT_PULLUP);
   pinMode(KEY1, INPUT_PULLUP);
   Serial.begin(9600); 
   pciSetup(KEY1);
   pciSetup(KEY2);
   timerSetup();
}
 
void loop() {
  enterSleep();
  if (counter>50) {
    if (stopLED != 1)
    {
      state = !state;
      digitalWrite(LED1, state);
      counter = 0;
    }
  }
}
 
ISR(TIMER2_OVF_vect){
   counter++;

}

ISR(PCINT1_vect){
   int button1State=!digitalRead(KEY1);
   int button2State=!digitalRead(KEY2);
   if(button1State && button1State != lastButton1State)
   {
      button1Time = millis();
   }
   if(button2State && button2State != lastButton2State)
   {
      button2Time = millis();
   }
   if((abs(button1Time - button2Time) <= 500) && button1State==1 && button2State==1)
   {
     digitalWrite(LED1,HIGH);
     stopLED = 1; 
   }
   lastButton1State = button1State;
   lastButton2State = button2State;
}

