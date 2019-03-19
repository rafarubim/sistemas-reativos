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
int lightsOn = 0;
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
  // put your setup code here, to run once:
  pinMode(LED_PIN, OUTPUT);
  pinMode(A1, INPUT_PULLUP);
  pinMode(A2, INPUT_PULLUP);
  switchLed(lightsOn);
}

void loop() {
  // put your main code here, to run repeatedly:
  unsigned long now = millis();

  int button1Pressed = getButton1();
  int button2Pressed = getButton2();

  if (button1Pressed && button2Pressed && trigger500MsButton1 && trigger500MsButton2) {
    trigger500MsButton1 = 0;
    trigger500MsButton2 = 0;
    hasStoped = 1;
    switchLed(0);
  }

  if (button1Pressed) {
    if (triggerButton1Pressed) {
      triggerButton1Pressed = 0;
      timer500MsStart = now;
    }
    if (trigger500MsButton1 && now >= timer500MsStart + 500) {
      trigger500MsButton1 = 0;
      blinkFaster();
    }
  } else {
    if (trigger500MsButton1 && !triggerButton1Pressed) {
      blinkFaster();
    }
    triggerButton1Pressed = 1;
    trigger500MsButton1 = 1;
    hasStoped = 0;
  }

  if (button2Pressed) {
    if (triggerButton2Pressed) {
      triggerButton2Pressed = 0;
      timer500MsStart = now;
    }
    if (trigger500MsButton2 && now >= timer500MsStart + 500) {
      trigger500MsButton2 = 0;
      blinkSlower();
    }
  } else {
    if (trigger500MsButton2 && !triggerButton2Pressed) {
      blinkSlower();
    }
    triggerButton2Pressed = 1;
    trigger500MsButton2 = 1;
    hasStoped = 0;
  }
  
  if (!hasStoped && now >= lastBlink + 1000 / blinkSpeed) {
    lightsOn = !lightsOn;
    switchLed(lightsOn);
    lastBlink = now;
  }
}
