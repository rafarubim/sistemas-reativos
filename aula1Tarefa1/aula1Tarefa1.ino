#define LED_PIN 13
#define BUTTON1 A1
#define BUTTON2 A2

void switchLed(int on) {
  if (on) {
    digitalWrite(LED_PIN, LOW);
  }
  else {
    digitalWrite(LED_PIN, HIGH);
  }
}

int getButton1() {
  return !digitalRead(BUTTON1);
}

int getButton2() {
  return !digitalRead(BUTTON2);
}

unsigned long lastBlink = 0;
int blinkSpeed = 1;
int lightsState = 0;
int triggerButton1Pressed = 1;
int triggerButton2Pressed = 1;

unsigned long timer500MsStart = 0;
int trigger500MsButton1 = 1;
int trigger500MsButton2 = 1;
int hasStoped = 0;

void blinkSlower() {
  blinkSpeed -= 1;
  if (blinkSpeed <=0) {
    blinkSpeed = 1;
  }
}

void blinkFaster() {
  blinkSpeed += 1;
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  pinMode(A1, INPUT_PULLUP);
  pinMode(A2, INPUT_PULLUP);
  switchLed(lightsState);
}

void loop() {
  unsigned long currentTime = millis();

  int button1Pressed = getButton1();
  int button2Pressed = getButton2();

  // If both buttons are on and none has been triggered for being held for 500ms
  if (button1Pressed && button2Pressed && trigger500MsButton1 && trigger500MsButton2) {
    // Don't trigger these buttons for being held ever again
    trigger500MsButton1 = 0;
    trigger500MsButton2 = 0;
    // Turn off the led and stop blinking
    hasStoped = 1;
    switchLed(0);
  }

  if (button1Pressed) {
    // Trigger button for being pressed only once until it is pressed again
    if (triggerButton1Pressed) {
      triggerButton1Pressed = 0;

      // Mark the current time as when we started counting
      timer500MsStart = currentTime;
    }

    // If 500ms have passed, this will be triggered only once
    if (trigger500MsButton1 && currentTime >= timer500MsStart + 500) {
      trigger500MsButton1 = 0;
      
      blinkFaster();
    }
  } else { // Button is not pressed

    // If the button is being released, this will trigger only once
    // This will only trigger if the button was held for less than 500ms
    if (trigger500MsButton1 && !triggerButton1Pressed) {
      blinkFaster();
    }
    // Allow "trigger once" variables to trigger things again
    triggerButton1Pressed = 1;
    trigger500MsButton1 = 1;
  }

  if (button2Pressed) {
    // Trigger button for being pressed only once until it is pressed again
    if (triggerButton2Pressed) {
      triggerButton2Pressed = 0;

      // Mark the current time as when we started counting
      timer500MsStart = currentTime;
    }

    // If 500ms have passed, this will be triggered only once
    if (trigger500MsButton2 && currentTime >= timer500MsStart + 500) {
      trigger500MsButton2 = 0;
      
      blinkSlower();
    }
  } else { // Button is not pressed

    // If the button is being released, this will trigger only once
    // This will only trigger if the button was held for less than 500ms
    if (trigger500MsButton2 && !triggerButton2Pressed) {
      blinkSlower();
    }

    // Allow "trigger once" variables to trigger things again
    triggerButton2Pressed = 1;
    trigger500MsButton2 = 1;
  }
  
  unsigned long blinkDelay = 1000 / blinkSpeed;

  // This will only happen if the lights haven't stopped and if there's a delay from the last time it blinked
  if (!hasStoped && currentTime >= lastBlink + blinkDelay) {
    lastBlink = currentTime;

    // Change light state (effectively blinking wooow)
    lightsState = !lightsState;
    switchLed(lightsState);
  }
}#define LED_PIN 13
#define BUTTON1 A1
#define BUTTON2 A2

void switchLed(int on) {
  if (on) {
    digitalWrite(LED_PIN, LOW);
  }
  else {
    digitalWrite(LED_PIN, HIGH);
  }
}

int getButton1() {
  return !digitalRead(BUTTON1);
}

int getButton2() {
  return !digitalRead(BUTTON2);
}

unsigned long lastBlink = 0;
int blinkSpeed = 1;
int lightsState = 0;
int triggerButton1Pressed = 1;
int triggerButton2Pressed = 1;

unsigned long timer500MsStart = 0;
int trigger500MsButton1 = 1;
int trigger500MsButton2 = 1;
int hasStoped = 0;

void blinkSlower() {
  blinkSpeed -= 1;
  if (blinkSpeed <=0) {
    blinkSpeed = 1;
  }
}

void blinkFaster() {
  blinkSpeed += 1;
}

void setup() {
  pinMode(LED_PIN, OUTPUT);
  pinMode(A1, INPUT_PULLUP);
  pinMode(A2, INPUT_PULLUP);
  switchLed(lightsState);
}

void loop() {
  unsigned long currentTime = millis();

  int button1Pressed = getButton1();
  int button2Pressed = getButton2();

  // If both buttons are on and none has been triggered for being held for 500ms
  if (button1Pressed && button2Pressed && trigger500MsButton1 && trigger500MsButton2) {
    // Don't trigger these buttons for being held ever again
    trigger500MsButton1 = 0;
    trigger500MsButton2 = 0;
    // Turn off the led and stop blinking
    hasStoped = 1;
    switchLed(0);
  }

  if (button1Pressed) {
    // Trigger button for being pressed only once until it is pressed again
    if (triggerButton1Pressed) {
      triggerButton1Pressed = 0;

      // Mark the current time as when we started counting
      timer500MsStart = currentTime;
    }

    // If 500ms have passed, this will be triggered only once
    if (trigger500MsButton1 && currentTime >= timer500MsStart + 500) {
      trigger500MsButton1 = 0;
      
      blinkFaster();
    }
  } else { // Button is not pressed

    // If the button is being released, this will trigger only once
    // This will only trigger if the button was held for less than 500ms
    if (trigger500MsButton1 && !triggerButton1Pressed) {
      blinkFaster();
    }
    // Allow "trigger once" variables to trigger things again
    triggerButton1Pressed = 1;
    trigger500MsButton1 = 1;
  }

  if (button2Pressed) {
    // Trigger button for being pressed only once until it is pressed again
    if (triggerButton2Pressed) {
      triggerButton2Pressed = 0;

      // Mark the current time as when we started counting
      timer500MsStart = currentTime;
    }

    // If 500ms have passed, this will be triggered only once
    if (trigger500MsButton2 && currentTime >= timer500MsStart + 500) {
      trigger500MsButton2 = 0;
      
      blinkSlower();
    }
  } else { // Button is not pressed

    // If the button is being released, this will trigger only once
    // This will only trigger if the button was held for less than 500ms
    if (trigger500MsButton2 && !triggerButton2Pressed) {
      blinkSlower();
    }

    // Allow "trigger once" variables to trigger things again
    triggerButton2Pressed = 1;
    trigger500MsButton2 = 1;
  }
  
  unsigned long blinkDelay = 1000 / blinkSpeed;

  // This will only happen if the lights haven't stopped and if there's a delay from the last time it blinked
  if (!hasStoped && currentTime >= lastBlink + blinkDelay) {
    lastBlink = currentTime;

    // Change light state (effectively blinking wooow)
    lightsState = !lightsState;
    switchLed(lightsState);
  }
}
