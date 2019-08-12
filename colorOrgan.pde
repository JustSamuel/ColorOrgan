import ddf.minim.analysis.*;
import ddf.minim.*;
import processing.serial.*;
import java.awt.Color;
import java.awt.Graphics;

import javax.swing.JFrame;
import javax.swing.JPanel;

Serial arduinoPort;
Minim minim;
AudioInput in;
FFT fft;

int buffer_size = 2048;
int c = 256;
float sample_rate = 20000;
float visualMultiplier = 300;
float audioMultiplier = 125;
float red, green, blue;
float previousMaxAmplitude = 0;
float decay = 0.9;
float audioFloor = 1;
boolean window = true;
color audioColor;

void setup(){
 
  surface.setVisible(false);
  if (!window) {
    surface.setVisible(false);
  }
  
  minim = new Minim(this);
  
  String port = Serial.list()[1];
  arduinoPort = new Serial(this, port, 9600);
  
  in = minim.getLineIn(Minim.MONO, buffer_size, sample_rate);
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  
  colorMode(HSB, 100, 100, 100);
  frameRate(10000);
}

void draw(){
  colorMode(HSB, 100);
  background(audioColor);
  stroke(255);
  
  fft.forward( in.mix );
  float maxAmplitude = 0;
  float maxAmplitudeFreq = 0;
  float visualAmplitude = 0;
  float colorAmplitudeFreq = 0;
  float colorAmplitude = 0;
  
  for( int i = 0; i < c; i++) {
    float band = fft.getBand(i)*0.01*i; 
    if (band > maxAmplitude) {
      maxAmplitude = band;
      maxAmplitudeFreq = i;
    }
    visualAmplitude = band * visualMultiplier;
    stroke(((100*i)/c),100,100);  //draw frequency breakdown in band's color
    line( i, height, i, height - visualAmplitude);
      
    stroke(255);      //add a white pixel at top of bar
    line( i, height - visualAmplitude - 1, i, height - visualAmplitude);    
  }
  
  if (maxAmplitude >= previousMaxAmplitude * audioFloor ) { 
    colorAmplitudeFreq = map(maxAmplitudeFreq, 0, c, 0, 100);
    colorAmplitude = maxAmplitude * audioMultiplier;
    previousMaxAmplitude = maxAmplitude;
  } else {
    colorAmplitudeFreq = map(previousMaxAmplitude, 0, c, 0, 100) * decay;
    colorAmplitude = previousMaxAmplitude * audioMultiplier * decay;
    previousMaxAmplitude *= decay;
  }
  
 
  
  audioColor = color(colorAmplitudeFreq, 100, colorAmplitude);
  
  red = audioColor >> 16 & 0xFF;
  green = audioColor >> 8 & 0xFF;
  blue = audioColor & 0xFF;
  
  //noise filter
  if (int(red)+int(green)+int(blue) < 15) {
    arduinoPort.write(0+","+0+","+0+"\n");
  } else {
    arduinoPort.write(int(red)+","+int(green)+","+int(blue)+"\n");
  } 
  //print(int(red)+","+int(green)+","+int(blue)+"\n");
}
