#define LED_PIN 13
#define BUTTON A1

void switchLed(int on) {
  if (on) {
    digitalWrite(LED_PIN, LOW);
  }
  else {
    digitalWrite(LED_PIN, HIGH);
  }
}

int getButton() {
  return !digitalRead(BUTTON);
}

unsigned long lastBlink = 0;
int lightsOn = 0;
int needsToGoOff = 0;

void setup() {
  // put your setup code here, to run once:
  pinMode(LED_PIN, OUTPUT);
  pinMode(A1, INPUT_PULLUP);
  switchLed(lightsOn);
}

void loop() {
  // put your main code here, to run repeatedly:
  unsigned long now = millis();

  if (getButton()) {
    lastBlink = now;
    switchLed(1);
    needsToGoOff = 1;
  }
  else {
    if (needsToGoOff) {
      switchLed(0);
      needsToGoOff = 0;
    }
  }
  
  if (now >= lastBlink + 1000) {
    lightsOn = !lightsOn;
    switchLed(lightsOn);
    lastBlink = now;
  }
}
