Luma testLuma;
Chroma[] lumaClusters;
Chroma[] lumaDomain;

int startTime;
int endTime;
int totalTime;

int lumaNumber = 8;
int lumaQuality = 75;

int lumaMinL = 0;
int lumaMaxL = 30;

int lumaMinC = 80;
int lumaMaxC = 100;

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
    background(0);
    plotLuma();
    plotLumaCentroids();

}

void plotLuma() {
    for (int i=0 ; i< lumaDomain.length; i++) {
        fill(lumaDomain[i].getColor());
        ellipse(map(lumaDomain[i].getHue(), 0, 360, 0, width), map(lumaDomain[i].getChr(), 0, 132, 0, height), 5, 5);
    }
}

void plotLumaCentroids() {
    for(int j = 0; j < lumaClusters.length; j++) {
        fill(lumaClusters[j].getColor());

        ellipse(map(lumaClusters[j].getHue(), 0, 360, 0, width), map(lumaClusters[j].getChr(), 0, 132, 0, height), 10, 10);
    }
}

/**
 * This is a small animation of how one of the best known
 * cluster algorithm - the k-Means - works. The aim of clustering
 * analysis is to group data in such a way that similar objects
 * are in one cluster and objects of different clusters are disimilar.
 * The k-Means algorithm basically consists of three steps:
 * <ol>
 * <li> an initial set of 'k' so-called centroids,
 *     i.e. virtual points in the data space is randomly created,</li>
 * <li> every point of the data set is assigned to its nearest centroid and</li>
 * <li> the position of the centroid is updated by the means of the data points
 *     assigned to that cluster. Hence, the centroid is moved toward the
 *     center of the assigned points.</li>
 * This is done until no centroid was shifted in one iteration resulting
 * in 'k' subsets/cluster.
 * The assignment of points to centroids results in a partitioning of the
 * data space. It results in virtual borders between two centroids, where the distance is
 * equal on each side of the border the distance to one centroid is smaller than to the other.
 * This kind of partitioning is also known as a Voronoi tesselation.
 *
 * In this small animation a grid of points is created with each pixel as one point
 * and 'k' randomly created centroids then the k-Means runs until convergence.
 * After convergence the centroids are again randomly initialized and the k-Means
 * runs again and so on. Since every possible point of the input space is assigned
 * to one centroid the result is a Voronoi tesselation of the input space.
 *
 * @author Fabian Dill, University of Konstanz
 */

// //how often no change until new initialization
// int WAIT_UNTIL_RESET = 2;
// //number of cluster centroids
// int K = 5;
// //size
// int SIZE = 200;

// Point[]centroids = new Point[K];
// Point[]points = new Point[SIZE*SIZE];
// color[]colors = new color[K];
// int nrNotChanged = 0;


// void setup() {
//   size(SIZE, SIZE);
//   // the colors
//   colors[0] = color(83,165,255);
//   colors[1] = color(88,255,51);
//   colors[2] = color(255,255,0);
//   colors[3] = color(255,0,172);
//   colors[4] = color(144,144,144);
//   createInitialPoints();
//   createInitialCentroids();

//   //and paint them

//   noStroke();
//   //smooth();
//   for(int i = 0; i < centroids.length; i++){
//     fill(colors[i]);
//     ellipse(centroids[i].x, centroids[i].y, 7, 7);
// }
// for(int i = 0; i < points.length; i++){
//     point(points[i].x, points[i].y);
// }
// frameRate(30);
// }

// void createInitialPoints(){
//   //create initital points
//   int index = 0;
//   for(int i = 0; i < SIZE; i++){
//     for(int j = 0; j < SIZE; j++){
//       points[index++] = new Point((int)random(SIZE),(int)random(SIZE));
//   }
// }
// }

// void createInitialCentroids(){
//   //create the initial prototypes
//   for(int i = 0; i < K; i++){
//     int x = int(random(0, SIZE));
//     int y = int(random(0, SIZE));
//     centroids[i] = new Point(x,y);
// }
// }

// void draw(){
//   background(0);
//   assignPoints2Clusters();
//     //now draw them
//   //smooth();
//   for(int i = 0; i < points.length; i++){
//     stroke(colors[points[i].clusterIdx]);
//     point(points[i].x, points[i].y);
// }
// stroke(0);
// for(int i = 0; i < centroids.length; i++){
//     fill(255);
//     ellipse(centroids[i].x, centroids[i].y, 10, 10);
// }
// boolean changed = calculateNewCentroids();
//   //check if any centroid was moved
//   if(!changed){
//     //nothing changed
//     nrNotChanged++;
//     if(nrNotChanged == WAIT_UNTIL_RESET){
//       /*
//        * if more than WAIT_UNTIL_RESET times nothing changed
//        * start a new run with new randomly initialized centroids
//        */
//        nrNotChanged = 0;
//        resetPoints();
//        createInitialCentroids();
//    }
// }else{
//     //something has changed
//     nrNotChanged = 0;
// }
// }

// void assignPoints2Clusters(){
//     for(int i = 0; i < points.length; i++){
//       points[i].dist2Centroid = SIZE*SIZE;
//       for(int j = 0; j < centroids.length; j++){
//         //find the centroid with the smallest distance
//         float distance = dist(points[i].x, points[i].y, centroids[j].x, centroids[j].y);
//         if(distance < points[i].dist2Centroid){
//           points[i].dist2Centroid = distance;
//           points[i].clusterIdx = j;
//       }
//   }
// }
// }

// /*
//  * Calculates the new centroids based on the mean of the points
//  * assigned to the referring cluster.
//  * @return true, if any centroid was changed, false otherwise.
//  */
//  boolean calculateNewCentroids(){
//   //now calculate the new centroids
//   /*
//    * This is a hack! The Point class structure is abused:
//    * x holds the cumulate x values for all points of the referring cluster,
//    * y holds the cumulated y values for all points of the referring cluster,
//    * dist2Centroid holds the number of points belonging to the referring cluster.
//    * The cluster is identified by it's index in the centroid array.
//    */
//    Point[]tempCentroids = new Point[K];
//    for(int i = 0; i < tempCentroids.length; i++){
//     tempCentroids[i] = new Point(0,0);
//     tempCentroids[i].dist2Centroid = 0;
// }
// for(int i = 0; i < points.length; i++){
//   int idx = points[i].clusterIdx;
//   tempCentroids[idx].x += points[i].x;
//   tempCentroids[idx].y += points[i].y;
//   tempCentroids[idx].dist2Centroid++;
// }
// boolean changed = false;
// for(int i = 0; i < centroids.length; i++){
//     int newX = int((tempCentroids[i].x/tempCentroids[i].dist2Centroid));
//     int newY = int((tempCentroids[i].y / tempCentroids[i].dist2Centroid));
//     if(centroids[i].x != newX || centroids[i].y != newY){
//       changed = true;
//   }
//   centroids[i].x = newX;
//   centroids[i].y = newY;
// }
// return changed;
// }

// /**
//  * Resets for all points the assignment to a cluster.
//  */
//  void resetPoints(){
//   for(int i = 0; i < points.length; i++){
//     points[i].clusterIdx = -1;
//     points[i].dist2Centroid = SIZE*SIZE;
// }
// }

// /*
//  * Helper class to store the x and the y dimension
//  * and the index of the cluster it is assigned to.
//  * Also the distance to that cluster is stored.
//  */
//  class Point{
//   int x;
//   int y;
//   int clusterIdx;
//   float dist2Centroid;

//   Point(int _x, int _y){
//     x = _x;
//     y = _y;
//     clusterIdx = -1;
//     dist2Centroid = SIZE*SIZE;
// }
// }
