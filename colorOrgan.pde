import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;

Serial arduinoPort; //serial connection to the arduino
Minim minim;        //minim object for the audio
AudioInput in;      //audio input line for the sound
FFT fft;            //fft object to decompose sound

int buffer_size = 2048; //large buffer size for better uninterrupted calculations
float audioMultiplier = 125;
float red, green, blue;
float previousMaxAmplitude = 0;
float decay = 0.95;
float audioFloor = 1;
float specSize;
color audioColor;

void setup(){
  surface.setVisible(false);

  minim = new Minim(this);
  
  String port = Serial.list()[1];
  arduinoPort = new Serial(this, port, 9600);
  
  in = minim.getLineIn();
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  
  specSize = fft.specSize();
  
  colorMode(HSB, 100, 100, 100);
  frameRate(10000);
}

void draw(){
  
  fft.forward( in.mix );
  
  float maxAmplitude = 0;
  float maxAmplitudeFreq = 0;
  float colorAmplitudeFreq = 0;
  float colorAmplitude = 0;
  
  for( int i = 0; i < specSize; i++) {
    float band = fft.getBand(i)*0.01*i; 
    if (band > maxAmplitude) {
      maxAmplitude = band;
      maxAmplitudeFreq = i;
    }
  }
  
  if (maxAmplitude >= previousMaxAmplitude * audioFloor ) { 
    colorAmplitudeFreq = map(maxAmplitudeFreq, 0, specSize, 0, 100);
    colorAmplitude = maxAmplitude * audioMultiplier;
    previousMaxAmplitude = maxAmplitude;
  } else {
    colorAmplitudeFreq = map(previousMaxAmplitude, 0, specSize, 0, 100) * decay;
    colorAmplitude = previousMaxAmplitude * audioMultiplier * decay;
    previousMaxAmplitude *= decay;
  }
  
  audioColor = color(colorAmplitudeFreq, 100, colorAmplitude);
  
  red = audioColor >> 16 & 0xFF;
  green = audioColor >> 8 & 0xFF;
  blue = audioColor & 0xFF;
  
  //noise filter
  if (int(red)+int(green)+int(blue) < 5) {
    arduinoPort.write(0+","+0+","+0+"\n");
  } else {
    arduinoPort.write(int(red)+","+int(green)+","+int(blue)+"\n");
  } 
  //print(int(red)+","+int(green)+","+int(blue)+"\n");
}
