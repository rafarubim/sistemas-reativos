#include "app.h"
#include "pindefs.h"
#include "event_driven.h"

#define TIMER_LED 1
#define TIMER_END_TIME_FRAME 2

static int lightsState = 0;

static int blinkSpeed = 1;
static unsigned long blinkDelay = 1000;
static int hasStopedBlinking = 0;

static int isInTimeFrame = 0;

static void switchLed(int on);
static void toggleLed();
static void blinkSlower();
static void blinkFaster();
static void stopBlinking();

void appinit(void) {
  pinMode(LED1, OUTPUT);
  switchLed(0);
  
  timer_set(TIMER_LED, blinkDelay);

  button_listen(KEY1);
  button_listen(KEY2);
}

void button_changed(int p, int v) {
  int wasKeyPressed = !v;
  if (wasKeyPressed) {
    if (isInTimeFrame) {
      stopBlinking();
    } else {
      isInTimeFrame = 1;
      timer_set(TIMER_END_TIME_FRAME, 500);
    }
    switch(p) {
      case KEY1:
        blinkFaster();
        break;
      case KEY2:
        blinkSlower();
        break;
    }
  } else { // Button released
    isInTimeFrame = 0;
  }
}

void timer_expired(int timer) {
  switch(timer) {
    case TIMER_LED:
      if (!hasStopedBlinking) {
        toggleLed();
        timer_set(TIMER_LED, blinkDelay);
      }
      break;
    case TIMER_END_TIME_FRAME:
      isInTimeFrame = 0;
  }
}

static void switchLed(int on) {
  if (on) {
    digitalWrite(LED1, LOW);
    lightsState = 1;
  }
  else {
    digitalWrite(LED1, HIGH);
    lightsState = 0;
  }
}

static void toggleLed() {
  lightsState = !lightsState;
  switchLed(lightsState);
}

static void blinkSlower() {
  blinkSpeed -= 1;
  if (blinkSpeed <=0) {
    blinkSpeed = 1;
  }
  blinkDelay = 1000 / blinkSpeed;
}

static void blinkFaster() {
  blinkSpeed += 1;
  blinkDelay = 1000 / blinkSpeed;
}

static void stopBlinking() {
  hasStopedBlinking = 1;
  switchLed(0);
}
