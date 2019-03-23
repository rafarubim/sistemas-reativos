#include "app.h"
#include "pindefs.h"
#include "event_driven.h"

void appinit(void) {
  pinMode(LED1, OUTPUT);
  digitalWrite(LED1, HIGH);
  button_listen(KEY1);
}

void button_changed(int p, int v) {
  digitalWrite(LED1, v);
}

void timer_expired(void) {
  
}
