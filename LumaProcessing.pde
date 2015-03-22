/////////////////////////////////////////////////////////////////////////////////////////
/*
Author: Neil Panchal
Website: http://neil.engineer/

Copyright 2015 Neil Panchal. All Rights Reserved.

Description: Chroma is a color conversion class for Processing.

Purpose: Primary objective of Chroma is to help the end user seamlessly & effortlessly create colors that are perceptually uniform.

Usage: Please see the README.md file

References:  Color conversion methods are borrowed from various places as detailed below.

*   Gregory Aisch: https://github.com/gka/chroma.js
*   http://developer.classpath.org/doc/java/awt/Color-source.html
*   http://stackoverflow.com/a/7898685
*   http://www.cs.rit.edu/~ncs/color/t_convert.html

*/
/////////////////////////////////////////////////////////////////////////////////////////

Chroma testColor;

void setup() {

    size(600, 600, "processing.core.PGraphicsRetina2D");
    smooth();
    noStroke();
    frameRate(30);

    testColor = new Chroma();
    rectMode(CENTER);

}

void draw() {
    background(255);
    fill(testColor.getColor());
    rect(width/2, height/2, 100, 100);

}
