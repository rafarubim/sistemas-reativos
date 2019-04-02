#include <avr/sleep.h>
#include <avr/power.h>
#include "pindefs.h"

// globais

volatile int buttonChanged = 0;

void pciSetup (byte pin) {
    *digitalPinToPCMSK(pin) |= bit (digitalPinToPCMSKbit(pin));  // enable pin
    PCIFR  |= bit (digitalPinToPCICRbit(pin)); // clear any outstanding interruptjk
    PCICR  |= bit (digitalPinToPCICRbit(pin)); // enable interrupt for the group
}

void disable (byte pin) {
  *digitalPinToPCMSK(pin) &= ~bit (digitalPinToPCMSKbit(pin)); 
}

ISR (PCINT1_vect) { // handle pin change interrupt for A0 to A5 here
   buttonChanged=1;
 }

void enterSleep() {
  set_sleep_mode(SLEEP_MODE_PWR_DOWN);
  sleep_enable();
  sleep_mode();
  sleep_disable();
}

void setup() {
  
  pinMode(LED1, OUTPUT); pinMode(LED2, OUTPUT); 
  pinMode (LED3, OUTPUT); pinMode(LED4, OUTPUT);
  digitalWrite(LED1,HIGH); digitalWrite(LED2,HIGH);
  digitalWrite(LED3,HIGH); digitalWrite(LED4,HIGH);
  pinMode (KEY1, INPUT_PULLUP); 
  pinMode (KEY2, INPUT_PULLUP);
  pinMode(KEY3, INPUT_PULLUP);
  
  pciSetup(KEY1); pciSetup(KEY2); pciSetup(KEY3);

  Serial.begin(9600); 
}

void loop() {
  enterSleep();
  Serial.print("!"); delay(10);
  if (buttonChanged) {

     digitalWrite(LED1,digitalRead(KEY1));
     digitalWrite(LED2,digitalRead(KEY2));
     
     buttonChanged = 0;
  }
}
