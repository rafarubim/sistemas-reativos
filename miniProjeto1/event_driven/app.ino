#include "app.h"
#include "pindefs.h"
#include "event_driven.h"

#define null 0

#define DEBOUNCE_DURATION_MS 50

#define DEBOUNCES_AMOUNT 3

#define DEBOUNCE_1_INDEX 0
#define DEBOUNCE_2_INDEX 1
#define DEBOUNCE_3_INDEX 2

#define TIMER_DEBOUNCE_1 1
#define TIMER_DEBOUNCE_2 2
#define TIMER_DEBOUNCE_3 3
#define TIMER_DISPLAY_LOOP 4
#define TIMER_BLINK_DISPLAY 5
#define TIMER_CURRENT_TIME 6

#define MINUTE_IN_MS 60000ul

#define LEDS_AMOUNT 4
#define INTERNAL_MODE_AMOUNT 8
#define MODE_AMOUNT 6
#define MAX_SIMULTANEOUS_MODE_LEDS 2

#define DISPLAY_BLINK_ON_TIME_MS 500
#define DISPLAY_BLINK_OFF_TIME_MS 250

/* >>> Copied from internet */
#define LATCH_DIO 4
#define CLK_DIO 7
#define DATA_DIO 8
 
static const byte SEGMENT_MAP[] = {0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0X80,0X90};
static const byte SEGMENT_SELECT[] = {0xF1,0xF2,0xF4,0xF8};

void writeNumberToSegment(byte segment, byte value);
/* <<< */

static unsigned char displayBlinkMask[] = {0, 0, 0, 0};
static unsigned char isBlinking = 0;

typedef struct ClockTimeStruct {
 int minutes;
 int hours;
} ClockTime;

static int isDebounceBlocked[DEBOUNCES_AMOUNT] = {0, 0, 0};
static const int timerByDebounceInx[DEBOUNCES_AMOUNT] = {TIMER_DEBOUNCE_1, TIMER_DEBOUNCE_2, TIMER_DEBOUNCE_3};

static ClockTime* displayTime = null;
static const int allLeds[LEDS_AMOUNT] = {LED1, LED2, LED3, LED4};

static int internalMode = 0;
static const int modeByInternalMode[INTERNAL_MODE_AMOUNT] = {0, 1, 2, 3, 3, 4, 4, 5};
static const int ledsByMode[MODE_AMOUNT][MAX_SIMULTANEOUS_MODE_LEDS] = {{LED1, null}, {LED2, null}, {LED3, null}, {LED4, null}, {LED1, LED2}, {LED2, LED3}};

static ClockTime currentTime = {0, 0};
static ClockTime alarmTime = {0, 0};
static ClockTime stopWatchTime = {0, 0};

static const ClockTime* displayPointerByInternalMode[INTERNAL_MODE_AMOUNT] = {&currentTime, &currentTime, &alarmTime, &currentTime, &currentTime, &alarmTime, &alarmTime, &stopWatchTime};

static void debouncedButtonChanged();
void writeBlankToSegment(byte segment);
static void buttonChanged(int pin, int value);

static void nextInternalMode();
static int getNextInternalMode(int internalMode);
static void setModeLeds(int internalMode);
static void setInternalModeDisplay(int internalMode);

void appinit(void) {
  /* >>> Copied from internet */
  pinMode(LATCH_DIO,OUTPUT);
  pinMode(CLK_DIO,OUTPUT);
  pinMode(DATA_DIO,OUTPUT);
  /* <<< */
  timer_set(TIMER_DISPLAY_LOOP, 0);
  timer_set(TIMER_BLINK_DISPLAY, DISPLAY_BLINK_ON_TIME_MS);

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(LED4, OUTPUT);
  button_listen(KEY3);
  
  digitalWrite(LED1, LOW);
  digitalWrite(LED2, HIGH);
  digitalWrite(LED3, HIGH);
  digitalWrite(LED4, HIGH);
  
  setInternalModeDisplay(internalMode);
  timer_set(TIMER_CURRENT_TIME, MINUTE_IN_MS);
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
      if (displayTime != null) {
        // Iterate over each display segment
        for (int i = 0; i < 4; i++) {
          if (displayBlinkMask[i] && isBlinking) {
            writeBlankToSegment(i);
          } else {
            // Number to display in the current segment
            int displayNumber =
              i == 0 ? displayTime->hours / 10 :
              i == 1 ? displayTime->hours % 10 :
              i == 2 ? displayTime->minutes / 10 :
              displayTime->minutes % 10;
            writeNumberToSegment(i, displayNumber);
          }
        }
      }
      timer_set(TIMER_DISPLAY_LOOP, 0);
      break;
    case TIMER_CURRENT_TIME:
      currentTime.minutes += 1;
      if (currentTime.minutes >= 60) {
        currentTime.minutes = 0;
        currentTime.hours += 1;
        if (currentTime.hours >= 24) {
          currentTime.hours = 0;
        }
      }
      timer_set(TIMER_CURRENT_TIME, MINUTE_IN_MS);
      break;
    case TIMER_BLINK_DISPLAY:
      isBlinking = !isBlinking;
      if (isBlinking) {
        timer_set(TIMER_BLINK_DISPLAY, DISPLAY_BLINK_OFF_TIME_MS);
      } else {
        timer_set(TIMER_BLINK_DISPLAY, DISPLAY_BLINK_ON_TIME_MS);
      }
      break;
  }
}

static void buttonChanged(int pin, int value) {
  int pressed = !value;
  switch(pin) {
    case KEY3:
      if (pressed) {
        nextInternalMode();
      }
      break;
  }
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

void writeBlankToSegment(byte segment)
{
  digitalWrite(LATCH_DIO, LOW);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, 0xFF);
  shiftOut(DATA_DIO, CLK_DIO, MSBFIRST, SEGMENT_SELECT[segment]);
  digitalWrite(LATCH_DIO, HIGH);
}

static void nextInternalMode() {
  internalMode = getNextInternalMode(internalMode);
  setModeLeds(internalMode);
  setInternalModeDisplay(internalMode);
}

static int getNextInternalMode(int internalMode) {
  internalMode++;
  if (internalMode >= INTERNAL_MODE_AMOUNT) {
    internalMode = 0;
  }
  return internalMode;
}

static void setModeLeds(int internalMode) {
  for (int i = 0; i < LEDS_AMOUNT; i++) {
    digitalWrite(allLeds[i], HIGH);
  }
  int mode = modeByInternalMode[internalMode];
  int* modeLeds = ledsByMode[mode];
  for (int i = 0; i < MAX_SIMULTANEOUS_MODE_LEDS; i++) {
    digitalWrite(modeLeds[i], LOW);
  }
}

static void setInternalModeDisplay(int internalMode) {
  displayTime = displayPointerByInternalMode[internalMode];
  for (int i = 0; i < 4; i++) {
    displayBlinkMask[i] = 0;
  }
  switch(internalMode) {
    case 3: case 5:
      displayBlinkMask[0] = 1;
      displayBlinkMask[1] = 1;
      break;
    case 4: case 6:
      displayBlinkMask[2] = 1;
      displayBlinkMask[3] = 1;
      break;
  }
}
