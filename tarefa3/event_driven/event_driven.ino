#include "event_driven.h"
#include "pindefs.h"
#include "app.h"

static int buttonStates[3] = {-1, -1, -1};
static unsigned long timerStart = -1;
static unsigned long timerDuration = -1;

static int pinByIndex[3] = {KEY1, KEY2, KEY3};

int getPinIndex(int pin) {
  switch(pin) {
    case KEY1:
      return 0;
    case KEY2:
      return 1;
    case KEY3:
      return 2;
  }
}

/* Funções de registro: */
void button_listen(int pin)
{
  pinMode(pin, INPUT_PULLUP);
  int inx = getPinIndex(pin);
  buttonStates[inx] = digitalRead(pin);
}
void timer_set(int ms)
{
  timerStart = millis();
  timerDuration = (unsigned int) ms;
}

/* Programa principal: */
void setup()
{
  appinit();
}
void loop()
{
  unsigned long currentTime = millis();

  for(int i = 0; i < 3; i++) {
    int oldState = buttonStates[i];
    if (oldState != -1) {
      int pin = pinByIndex[i];
      int currentState = digitalRead(pin);
      if (currentState != oldState) {        
        buttonStates[i] = currentState;
        button_changed(pin, currentState);
      }
    }
  }

  if (timerStart != -1) {
    if (currentTime >= timerStart + timerDuration) {
      timerStart = -1;
      timerDuration = -1;
      timer_expired();
    }
  }
}
