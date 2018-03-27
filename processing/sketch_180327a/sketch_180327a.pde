import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import processing.serial.*;


Capture video;
OpenCV opencv;

//Screen Size Parameters
int width = 320;
int height = 240;

Serial port; 

//Variables for keeping track of the current servo positions.
char servoPanPosition = 90;
//The pan/tilt servo ids for the Arduino serial command interface.
char panChannel = 1;

//These variables hold the x and y location for the middle of the detected face.
int midFaceY=0;
int midFaceX=0;

//The variables correspond to the middle of the screen, and will be compared to the midFace values
int midScreenY = (height/2);
int midScreenX = (width/2);
int midScreenWindow = 10;  //This is the acceptable 'error' for the center of the screen

//The degree of change that will be applied to the servo each time we update the position.
int stepSize=2;



void setup() {
  
    
  printArray(Serial.list()); // List COM-ports (Use this to figure out which port the Arduino is connected to)
  printArray(Capture.list());
  
  size(640,480);
  video = new Capture(this, 640/2, 480/2, Capture.list()[3], 30);
  opencv = new OpenCV(this, 640, 480);

  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();
  
   //select first com-port from the list (change the number in the [] if your sketch fails to connect to the Arduino)
  port = new Serial(this, Serial.list()[3], 57600);   //Baud rate is set to 57600 to match the Arduino baud rate.  

  //Send the initial pan angles to the Arduino to set the device up to look straight forward.
  port.write(panChannel);         //Send the Pan Servo ID
  port.write(servoPanPosition);   //Send the Pan Position (currently 90 degrees)   
}

void draw() {
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  
  Rectangle[] faces = opencv.detect();
  

  for (int i = 0; i < faces.length; i++) {
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  
  //Find out if any faces were detected.
  if(faces.length > 0){
    //If a face was found, find the midpoint of the first face in the frame.
    //NOTE: The .x and .y of the face rectangle corresponds to the upper left corner of the rectangle,
    //      so we manipulate these values to find the midpoint of the rectangle.
    midFaceY = faces[0].y + (faces[0].height/2);
    midFaceX = faces[0].x + (faces[0].width/2);
    
    //midFaceX = Midpoint of my face along the X axis
    //midScreenX = 320
    //midScreenWindow = 10 (This is the acceptable 'error' for the center of the screen)
    if (midFaceX > (midScreenX + midScreenWindow)) {
      if (servoPanPosition >= 5)servoPanPosition += stepSize; //Update the pan position variable to move the servo to the left.
      //if (midFaceX != midScreenX)servoPanPosition += stepSize;
      
    }
    //Find out if the X component of the face is to the right of the middle of the screen.
    else if (midFaceX < (midScreenX - midScreenWindow)) {
      if (servoPanPosition <= 175)servoPanPosition -= stepSize; //Update the pan position variable to move the servo to the right.
    }
    
    

    
    
  }
  //Update the servo positions by sending the serial command to the Arduino.
  port.write(panChannel);        //Send the Pan servo ID
  port.write(servoPanPosition);  //Send the updated pan position.
}

void captureEvent(Capture c) {
  c.read();
}
