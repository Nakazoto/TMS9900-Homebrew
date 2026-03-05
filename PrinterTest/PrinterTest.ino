// Define the input and output pins
int prbusy = 2;
int strobe = 3;
int dtout0 = 4;
int dtout1 = 5;
int dtout2 = 6;
int dtout3 = 7;
int dtout4 = 8;
int dtout5 = 9;
int dtout6 = 10;
int busyrd = 0;

const char *str = "HELLORLD FROM USAGI ELECTRIC!'\r\n'";

// Initialize all the pins and set the outputs low
void setup() {
  pinMode(prbusy, INPUT);
  pinMode(strobe, OUTPUT);
  pinMode(dtout0, OUTPUT);
  pinMode(dtout1, OUTPUT);
  pinMode(dtout2, OUTPUT);
  pinMode(dtout3, OUTPUT);
  pinMode(dtout4, OUTPUT);
  pinMode(dtout5, OUTPUT);
  pinMode(dtout6, OUTPUT);
  digitalWrite(strobe, LOW);
  digitalWrite(dtout0, LOW);
  digitalWrite(dtout1, LOW);
  digitalWrite(dtout2, LOW);
  digitalWrite(dtout3, LOW);
  digitalWrite(dtout4, LOW);
  digitalWrite(dtout5, LOW);
  digitalWrite(dtout6, LOW);
}

// Main loop that prints a test thing over and over 
void loop() {
    for(const char *p = str; *p != '\0'; p++) {
  
      // If Printer Busy break out of while loop
      busyrd = 1;
      while (digitalRead(prbusy) == HIGH) {
        delay(100);
      }      
        
      digitalWrite(dtout0, (*p & (1<<0))? HIGH : LOW);
      digitalWrite(dtout1, (*p & (1<<1))? HIGH : LOW);
      digitalWrite(dtout2, (*p & (1<<2))? HIGH : LOW);
      digitalWrite(dtout3, (*p & (1<<3))? HIGH : LOW);
      digitalWrite(dtout4, (*p & (1<<4))? HIGH : LOW);
      digitalWrite(dtout5, (*p & (1<<5))? HIGH : LOW);
      digitalWrite(dtout6, (*p & (1<<6))? HIGH : LOW);
  
      digitalWrite(strobe, HIGH);
      delay(100);
      digitalWrite(strobe, LOW);
    }
  delay(100);
}
