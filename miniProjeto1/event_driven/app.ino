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
#define TIMER_DISPLAY_LOOP 4

/* >>> Copied from internet */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
 
static const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
static const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

void writeNumberToSegment(byte segment, byte value);
/* <<< */

static int isDebounceBlocked[3] = {0, 0, 0};
static const int timerByDebounceInx[3] = {TIMER_DEBOUNCE_1, TIMER_DEBOUNCE_2, TIMER_DEBOUNCE_3};

static int displayMinutes = 0;
static int displayHours = 0;

static void debouncedButtonChanged();

static void buttonChanged(int pin, int value);

void appinit(void) {
  /* >>> Copied from internet */
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);
  /* <<< */
  timer_set(TIMER_DISPLAY_LOOP, 0);
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
    case TIMER_DISPLAY_LOOP:
      writeNumberToSegment(0, displayHours / 10);
      writeNumberToSegment(1, displayHours % 10);
      writeNumberToSegment(2, displayMinutes / 10);
      writeNumberToSegment(3, displayMinutes % 10);
      timer_set(TIMER_DISPLAY_LOOP, 0);
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

/* >>> Copied from internet */
void writeNumberToSegment(byte segment, byte value)
{
  digitalWrite(LATCH_DIO, LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_MAP[value]);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[segment]);
  digitalWrite(LATCH_DIO, HIGH);
}
/* <<< */
