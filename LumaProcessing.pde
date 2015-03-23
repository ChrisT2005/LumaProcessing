Chroma testColor;
Luma testLuma;

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
