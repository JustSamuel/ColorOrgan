
//PWM pins
const int pwmR = 10;
const int pwmG = 6;
const int pwmB = 9;
int red = 0;
int green = 0;
int blue = 0;


void setup() {
  Serial.begin(9600);
  pinMode(pwmR, OUTPUT);
  pinMode(pwmG, OUTPUT);
  pinMode(pwmB, OUTPUT);
}

void loop() {
  analogWrite(pwmR, 0);
  analogWrite(pwmG, 0);
  analogWrite(pwmB, 0);
  while (Serial.available() > 0){
    Serial.end();      // close serial port
    Serial.begin(9600); // reenable serial again
      red = Serial.parseInt();
      green = Serial.parseInt();
      blue = Serial.parseInt();
      if (Serial.read() == '\n') {
      analogWrite(pwmR, red);
      analogWrite(pwmG, green);
      analogWrite(pwmB, blue);
      delay(10); 
    }
   }
}
