Luma testLuma;
Chroma[] lumaClusters;
Chroma[] lumaDomain;

int startTime;
int endTime;
int totalTime;

int lumaNumber = 10;
int lumaQuality = 100;

int lumaMinL = 40;
int lumaMaxL = 60;

int lumaMinC = 40;
int lumaMaxC = 128;

int lumaMinH = 0;
int lumaMaxH = 360;

void setup() {

    size(600, 600, "processing.core.PGraphicsRetina2D");
    rectMode(CENTER);
    smooth();
    noStroke();
    frameRate(30);


    startTime = millis();

    testLuma = new Luma(lumaNumber, lumaQuality, lumaMinL, lumaMaxL, lumaMinC, lumaMaxC, lumaMinH, lumaMaxH);

    lumaClusters = testLuma.getClusters();
    lumaDomain = testLuma.getDomain();

    endTime = millis();


    println("lumaClusters Length: " + lumaClusters.length);
    println("lumaDomain Length: " + lumaDomain.length);

    println("Start Time(ms): " + startTime);
    println("End Time(ms): " + endTime);
    println("Total Time(ms): " + (endTime-startTime));
    println();

}

void draw() {
    background(255);
    plotLuma();
    plotLumaCentroids();

}

void plotLuma() {
    for (int i=0 ; i< lumaDomain.length; i++) {
        // fill(lumaDomain[i].getColor());
        stroke(lumaDomain[i].getColor());
        strokeWeight(5);
        point(map(lumaDomain[i].getHue(), 0, 360, 0, width), map(lumaDomain[i].getChr(), 0, 132, 0, height));
    }
}

void plotLumaCentroids() {
    for(int j = 0; j < lumaClusters.length; j++) {
        fill(lumaClusters[j].getColor());
        stroke(0);
        strokeWeight(2);
        rect(map(lumaClusters[j].getHue(), 0, 360, 0, width), map(lumaClusters[j].getChr(), 0, 132, 0, height), 20, 20);
    }
}
