#include "event_driven.h"
#include "pindefs.h"
#include "app.h"

#define MAX_TIMERS 10

static int buttonStates[3] = {-1, -1, -1};
static unsigned long timerStart[MAX_TIMERS];
static unsigned long timerDuration[MAX_TIMERS];

static const int pinByIndex[3] = {KEY1, KEY2, KEY3};
static int getPinIndex(int pin);

/* Funções de registro: */
void button_listen(int pin)
{
  pinMode(pin, INPUT_PULLUP);
  int inx = getPinIndex(pin);
  buttonStates[inx] = digitalRead(pin);
}
void timer_set(int timer, int ms)
{
  int timerInx = timer - 1;
  timerStart[timerInx] = millis();
  timerDuration[timerInx] = (unsigned int) ms;
}

/* Programa principal: */
void setup()
{
  for (int i = 0; i < MAX_TIMERS; i++) {
    timerStart[i] = -1;
    timerDuration[i] = -1;
  }
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

  for (int i = 0; i < MAX_TIMERS; i++) {
    if (timerStart[i] != -1) {
      if (currentTime >= timerStart[i] + timerDuration[i]) {
        timerStart[i] = -1;
        timerDuration[i] = -1;
        timer_expired(i + 1);
      }
    }
  }
}

static int getPinIndex(int pin) {
  switch(pin) {
    case KEY1:
      return 0;
    case KEY2:
      return 1;
    case KEY3:
      return 2;
  }
}
