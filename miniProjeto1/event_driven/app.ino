#include "app.h"
#include "pindefs.h"
#include "event_driven.h"

#define DEBOUNCE_DURATION_MS 50

#define DEBOUNCE_1_INDEX 0
#define DEBOUNCE_2_INDEX 1
#define DEBOUNCE_3_INDEX 2

#define TIMER_DEBOUNCE_1 1
#define TIMER_DEBOUNCE_2 2
#define TIMER_DEBOUNCE_3 3

static int isDebounceBlocked[3] = {0, 0, 0};
static const int timerByDebounceInx[3] = {TIMER_DEBOUNCE_1, TIMER_DEBOUNCE_2, TIMER_DEBOUNCE_3};

static void debouncedButtonChanged();

static void buttonChanged(int pin, int value);

void appinit(void) {
}

void button_changed(int p, int v) {
  switch(p) {
    case KEY1:
      debouncedButtonChanged(DEBOUNCE_1_INDEX, p, v);
      break;
    case KEY2:
      debouncedButtonChanged(DEBOUNCE_2_INDEX, p, v);
      break;
    case KEY3:
      debouncedButtonChanged(DEBOUNCE_3_INDEX, p, v);
      break;
  }
}

void timer_expired(int timer) {
  switch(timer) {
    case TIMER_DEBOUNCE_1:
      isDebounceBlocked[DEBOUNCE_1_INDEX] = 0;
      break;
    case TIMER_DEBOUNCE_2:
      isDebounceBlocked[DEBOUNCE_2_INDEX] = 0;
      break;
    case TIMER_DEBOUNCE_3:
      isDebounceBlocked[DEBOUNCE_3_INDEX] = 0;
      break;
  }
}

static void buttonChanged(int pin, int value) {
  
}

void debouncedButtonChanged(int debounceInx, int pin, int value) {

  int debounceTimer = timerByDebounceInx[debounceInx];
  
  timer_set(debounceTimer, DEBOUNCE_DURATION_MS);
  
  if (!isDebounceBlocked[debounceInx]) {
    isDebounceBlocked[debounceInx] = 1;
    
    buttonChanged(pin, value);
  }
}
