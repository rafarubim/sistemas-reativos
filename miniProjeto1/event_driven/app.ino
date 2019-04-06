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
#define TIMER_STOPWATCH 7
#define TIMER_RESET_MODE 8

#define SECOND_IN_MS 1000ul
#define MINUTE_IN_MS 60000ul

#define LEDS_AMOUNT 4
#define INTERNAL_MODE_AMOUNT 8
#define MODE_AMOUNT 6
#define MAX_SIMULTANEOUS_MODE_LEDS 2

#define DISPLAY_BLINK_ON_TIME_MS 500
#define DISPLAY_BLINK_OFF_TIME_MS 250

#define RESET_MODE_IDLE_TIME_MS 10000ul

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
 void increaseMinute() {
  minutes++;
  if (minutes >= 60) {
    minutes = 0;
  }
 }
 void decreaseMinute() {
  minutes--;
  if (minutes <= 0) {
    minutes = 59;
  }
 }
 void increaseHour() {
  hours++;
  if (hours >= 24) {
    hours = 0;
  }
 }
 void decreaseHour() {
  hours--;
  if (hours <= 0) {
    hours = 23;
  }
 }
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
static ClockTime stopwatchTime = {0, 0};

static const ClockTime* displayPointerByInternalMode[INTERNAL_MODE_AMOUNT] = {&currentTime, &currentTime, &alarmTime, &currentTime, &currentTime, &alarmTime, &alarmTime, &stopwatchTime};

static unsigned char isStopwatchRunning = 0;

static void debouncedButtonChanged();
void writeBlankToSegment(byte segment);
static void buttonChanged(int pin, int value);

static void setInternalMode(int newInternalMode);
static int getNextInternalMode(int internalMode);
static void setModeLeds(int internalMode);
static void setInternalModeDisplay(int internalMode);
static void updateInternalModeTimers(int internalMode);

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
  button_listen(KEY1);
  button_listen(KEY2);
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
      currentTime.increaseMinute();
      if (currentTime.minutes == 0) {
        currentTime.increaseHour();
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
    case TIMER_STOPWATCH:
      stopwatchTime.increaseMinute();
      if (stopwatchTime.minutes == 0) {
        stopwatchTime.increaseHour();
      }
      timer_set(TIMER_STOPWATCH, SECOND_IN_MS);
      break;
    case TIMER_RESET_MODE:
      int internalModeBefore = internalMode;
      setInternalMode(0);
      break;
  }
}

static void buttonChanged(int pin, int value) {
  int pressed = !value;
  switch(pin) {
    case KEY1:
      if (pressed) {
        switch(internalMode) {
          case 3:
            currentTime.decreaseHour();
            break;
          case 4:
            currentTime.decreaseMinute();
            break;
          case 5:
            alarmTime.decreaseHour();
            break;
          case 6:
            alarmTime.decreaseMinute();
            break;
          case 7:
            stopwatchTime.minutes = 0;
            stopwatchTime.hours = 0;
            break;
        }
      }
      break;
    case KEY2:
      if (pressed) {
        switch(internalMode) {
          case 3:
            currentTime.increaseHour();
            break;
          case 4:
            currentTime.increaseMinute();
            break;
          case 5:
            alarmTime.increaseHour();
            break;
          case 6:
            alarmTime.increaseMinute();
            break;
          case 7:
            isStopwatchRunning = !isStopwatchRunning;
            if (isStopwatchRunning) {
              timer_set(TIMER_STOPWATCH, SECOND_IN_MS);
            } else {
              timer_cancel(TIMER_STOPWATCH);
            }
            break;
        }
      }
      break;
    case KEY3:
      if (pressed) {
        int nextInternalMode = getNextInternalMode(internalMode);
        setInternalMode(nextInternalMode);
      }
      break;
  }

  // Pressing buttons 1 or 2 breaks the idleness
  if (pressed) {
    switch(pin) {
      case KEY1: case KEY2:
        switch(internalMode) {
          case 3: case 4: case 5: case 6:
            timer_set(TIMER_RESET_MODE, RESET_MODE_IDLE_TIME_MS);
            break;
        }
        break;
    }
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

static void setInternalMode(int newInternalMode) {
  int internalModeBefore = internalMode;
  internalMode = newInternalMode;
  setModeLeds(newInternalMode);
  setInternalModeDisplay(newInternalMode);
  updateInternalModeTimers(internalModeBefore, newInternalMode);
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

static void updateInternalModeTimers(int internalModeBefore, int newInternalMode) {
  // Freeze/unfreeze current time
  if (internalMode == 3 || internalMode == 4) {
    timer_cancel(TIMER_CURRENT_TIME);
  } else if ((internalModeBefore == 3 || internalModeBefore == 4) && newInternalMode != 3 && newInternalMode != 4) {
    timer_set(TIMER_CURRENT_TIME, MINUTE_IN_MS);
  }

  // Changing mode breaks the idleness
  if (internalModeBefore != newInternalMode) {
    timer_cancel(TIMER_RESET_MODE);
  }
  // Countdown to mode reset because of idleness
  switch(newInternalMode) {
    case 3: case 4: case 5: case 6:
      timer_set(TIMER_RESET_MODE, RESET_MODE_IDLE_TIME_MS);
      break;
  }
}
