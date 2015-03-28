/////////////////////////////////////////////////////////////////////////////////////////
/*
Author: Neil Panchal
Website: http://neil.engineer/

Copyright 2015 Neil Panchal. All Rights Reserved.

Description: Luma is a palette generator for processing and it uses the Chroma library.

Purpose: Primary objective of Chroma is to help the end user seamlessly & effortlessly create colors that are perceptually uniform.

Usage: Please see the README.md file

References:  Color conversion methods are borrowed from various places as detailed below.

*   Gregory Aisch: https://github.com/gka/chroma.js
*   http://developer.classpath.org/doc/java/awt/Color-source.html
*   http://stackoverflow.com/a/7898685
*   http://www.cs.rit.edu/~ncs/color/t_convert.html

*/
/////////////////////////////////////////////////////////////////////////////////////////

import java.util.ArrayList;


public class Luma {


    // Number of cluster centroids
    private int lumaClusterCount;
    private int maxIter;
    private int quality;
    private float convergenceQuality;
    private boolean converged;

    private float minL;
    private float maxL;
    private float minC;
    private float maxC;
    private float minH;
    private float maxH;

    private Chroma[] lumaColors;
    private ArrayList<LumaData> lumaDomain;
    private ArrayList<LumaCentroid> lumaClusters;


    public Luma(int lumaClusterCount_, int quality_,  float minL_, float maxL_,
                                        float minC_, float maxC_,
                                        float minH_, float maxH_) {

        lumaClusterCount = lumaClusterCount_;
        quality = quality_;
        maxIter = quality_;
        convergenceQuality = map(quality_, 0, 100, 0.1, 0.0001);
        minL = minL_;
        maxL = maxL_;
        minC = minC_;
        maxC = maxC_;
        minH = minH_;
        maxH = maxH_;

        lumaDomain = new ArrayList<LumaData>();
        lumaDomain = createConstantDomain(2500, minL_, maxL_, minC_, maxC_, minH_, maxH_);

        lumaClusters = new ArrayList<LumaCentroid>();
        lumaClusters = createClusters(lumaClusterCount_);

        kMeansClustering();
    }


    // CLUSTER CENTROIDS
    private class LumaCentroid {

        private Chroma lumaChroma;

        public LumaCentroid (float l_, float c_, float h_) {

            this.lumaChroma = new Chroma(l_, c_, h_, ColorSpace.LCH);
        }

        public LumaCentroid (LumaCentroid toClone) {

            float l_ = toClone.getChroma().getLum();
            float c_ = toClone.getChroma().getChr();
            float h_ = toClone.getChroma().getHue();

            this.lumaChroma = new Chroma(l_, c_, h_, ColorSpace.LCH);
        }

        public Chroma getChroma() {

            return this.lumaChroma;
        }

        public void setChroma(float l_, float c_, float h_) {

            this.lumaChroma.setLCH(l_, c_, h_);
        }

        public boolean getClippedStatus() {

            return this.lumaChroma.clipped();
        }

        public String toString() {

            StringBuilder result = new StringBuilder();
            String NEW_LINE = System.getProperty("line.seperator");

            result.append(this.lumaChroma.toString(ColorSpace.LCH));
            return result.toString();

        }
    }


    // DATA SET
    private class LumaData extends LumaCentroid {

        private int clusterID;

        public LumaData(float l_, float c_, float h_, int clusterID_) {

            super(l_, c_, h_);
            this.clusterID = clusterID_;
        }

        public LumaData(float l_, float c_, float h_) {

            this(l_, c_, h_, -1);
        }

        public void setClusterID(int clusterNumber) {
            this.clusterID = clusterNumber;
        }

        public int getClusterID() {
            return this.clusterID;
        }

    }


    public Chroma[] getDomain() {

        int domainSize = this.lumaDomain.size();
        Chroma[] tempDomainArray = new Chroma[domainSize];

        for (int i = 0; i < domainSize; i++) {
            tempDomainArray[i] = lumaDomain.get(i).getChroma();
        }
        return tempDomainArray;
    }


    public Chroma[] getClusters() {

        int clusterSize = this.lumaClusters.size();
        Chroma[] tempClusterArray = new Chroma[clusterSize];

        for (int i = 0; i < clusterSize; i++) {
            tempClusterArray[i] = lumaClusters.get(i).getChroma();
        }
        return tempClusterArray;
    }


    public void kMeansClustering() {

        int index = 0;
        int convergenceIndex = 0;
        float LARGE_NUMBER = 100000000;
        boolean converged = false;

        while(!converged) {

            ArrayList<LumaCentroid> prevClusters = lumaClusters;

            // First assign each data point to its nearest cluster
            for (int i = 0; i < lumaDomain.size(); i++) {

                float minDistance = LARGE_NUMBER;

                for(int j = 0; j < lumaClusters.size(); j++) {
                    float distance = computeDistance(lumaDomain.get(i), lumaClusters.get(j));

                    if (distance < minDistance) {
                        lumaDomain.get(i).setClusterID(j);
                        minDistance = distance;
                        index++;
                    }
                }
            }

            boolean[] convergenceTest = new boolean[lumaClusters.size()];
            ArrayList<LumaData> freeDomain = new ArrayList<LumaData>(lumaDomain);
            // Now compute the centroid means and check if its within the Domain
            for (int j = 0; j < lumaClusters.size(); j++) {

                int count = 0;
                float[] kMean = new float[]{0.0,0.0,0.0};
                LumaCentroid currentCluster = lumaClusters.get(j);

                for (int i = 0; i < lumaDomain.size(); i++) {
                    // Collect all data points that have the current cluster ID
                    if (lumaDomain.get(i).getClusterID() == j) {

                        count++;
                        kMean[0] += lumaDomain.get(i).getChroma().getLum();
                        kMean[1] += lumaDomain.get(i).getChroma().getChr();
                        kMean[2] += lumaDomain.get(i).getChroma().getHue();

                    }
                }

                if (count!=0) {
                    // The current centroid has at least one assigned data point

                    // Compute the means
                    kMean[0] /= count;
                    kMean[1] /= count;
                    kMean[2] /= count;

                    // Construct a new centroid based on the new location
                    LumaCentroid tempCentroid = new LumaCentroid(kMean[0], kMean[1], kMean[2]);

                    // Check if the new location of the centroid is within the bounds

                    if (validChroma(tempCentroid.getChroma())) {

                        convergenceTest[j] = checkConvergence(tempCentroid, lumaClusters.get(j));
                        println("[Centroid " + (j+1) + "]\t" + tempCentroid + "\tConverged: " +convergenceTest[j]);
                        lumaClusters.set(j,tempCentroid);

                    } else {

                        LumaCentroid randomCentroid = new LumaCentroid(random(this.minL,this.maxL), random(this.minC,this.maxC), random(this.minH, this.maxH));
                        // If the new location is out of bounds, then find the closest data point\

                        // float minDistance = LARGE_NUMBER;
                        // int closest = 0;

                        // for (int i = 0; i < lumaDomain.size(); i++) {

                        //     float distance = computeDistance(lumaDomain.get(i), tempCentroid);
                        //     if (distance < minDistance) {
                        //         minDistance = distance;
                        //         closest = i;
                        //     }
                        // }

                        // LumaCentroid closestCentroid = new LumaCentroid(lumaDomain.get(closest));



                        // Force to compute the kMeans again and see if the centroid converges.
                        convergenceTest[j] = false;

                        println("[Centroid* " + (j+1) + "]\t" + tempCentroid + "\tConverged: " +convergenceTest[j]);
                        println("Out of bounds. Move the centroid to a random location: ");
                        println("[Centroid+ " + (j+1) + "]\t" + randomCentroid + "\tConverged: " + convergenceTest[j]);

                        lumaClusters.set(j,randomCentroid);
                    }

                } else {

                    // Count is ZERO! No data points assigned to this cluster. Find the closest data point and assign its location.

                    float minDistance = LARGE_NUMBER;
                    int closest = 0;

                    for (int i = 0; i < lumaDomain.size(); i++) {

                        float distance = computeDistance(lumaDomain.get(i), currentCluster);
                        if (distance < minDistance) {
                            minDistance = distance;
                            closest = i;
                        }
                    }

                    // Clone the data point and create a centroid at the new location. Cloning is important otherwise the centroid will only get copy the reference to the LumaData object and move the data point itself in subsequent iterations. If the cluster has only one data point, it will not converge.

                    LumaCentroid closestCentroid = new LumaCentroid(lumaDomain.get(closest));

                    println("Assigned closest data point: " + closest);

                    // Force to compute the kMeans again and see if the centroid converges.
                    convergenceTest[j] = false;

                    println("[Centroid " + (j+1) + "]\t" + closestCentroid + "\tConverged: " +convergenceTest[j]);

                    lumaClusters.set(j,closestCentroid);
                }

            }
            println("---------------------------------------------------------------------------------------------------------------");

            convergenceIndex++;
            if(convergenceIndex >= this.maxIter) {
                // println("Reached maximum iterations");
                break;
            }
            converged = checkTrue(convergenceTest);
        }


        println();
        if (convergenceIndex == maxIter) {
            println("Maximum Iterations reached: " + convergenceIndex);
        } else {
            println("Iterations to converge Centroids: " + convergenceIndex);
        }
        println("Iterations to find the closest Centroid: " + index);


        println();

    }


    private ArrayList<LumaData> createDomain(float minL_, float maxL_, float minC_, float maxC_, float minH_, float maxH_) {

        ArrayList<LumaData> lumaDomain_ = new ArrayList<LumaData>();

        int l_step = (int)map(this.quality, 0, 100, 8, 2);
        int c_step = (int)map(this.quality, 0, 100, 12, 2);
        int h_step = (int)map(this.quality, 0, 100, 24, 4);

        println("Quality: L: " + l_step + "\tC: " + c_step + "\tH: " + h_step);
        for(int l=(int)minL_; l<=(int)maxL_; l+=l_step){
            for(int c=(int)minC_; c<=(int)maxC_; c+=c_step){
                for(int h=(int)minH_; h<=(int)maxH_; h+=h_step){

                    LumaData tempData = new LumaData(l, c, h);

                    //Only add valid chroma to the array
                    if (!tempData.getClippedStatus()) {
                        lumaDomain_.add(tempData);
                    }
                }
            }
        }

        return lumaDomain_;
    }

    private ArrayList<LumaData> createConstantDomain(int size_, float minL_, float maxL_, float minC_, float maxC_, float minH_, float maxH_) {

        ArrayList<LumaData> lumaDomain_ = new ArrayList<LumaData>();

        for (int i = 0; i < size_; i++) {

            boolean foundValidChroma = false;

            // Try until the centroid is not clipped
            while(!foundValidChroma) {
                LumaData tempData = new LumaData(random(this.minL,this.maxL), random(this.minC,this.maxC), random(this.minH, this.maxH));

                if (validChroma(tempData.getChroma())) {
                    lumaDomain_.add(tempData);
                    foundValidChroma = true;
                    // println("[Building " + lumaClusters_.size() + "]\t" + tempData);
                }
            }
        }
        return lumaDomain_;
    }


    private ArrayList<LumaCentroid> createClusters(int lumaClusterCount_) {

        ArrayList<LumaCentroid> lumaClusters_ = new ArrayList<LumaCentroid>();

        for (int i = 0; i < lumaClusterCount_; i++) {

            boolean foundValidCentroid = false;

            // Try until the centroid is not clipped
            while(!foundValidCentroid) {
                LumaCentroid tempCentroid = new LumaCentroid(random(this.minL,this.maxL), random(this.minC,this.maxC), random(this.minH, this.maxH));

                if (validChroma(tempCentroid.getChroma())) {

                    lumaClusters_.add(tempCentroid);
                    foundValidCentroid = true;
                    println("[Building " + lumaClusters_.size() + "]\t" + tempCentroid);


                }
            }
        }
        println("---------------------------------------------------------------------------------------------------------------");
        return lumaClusters_;
    }


    // MATH & UTILITY METHODS


    private boolean validChroma(Chroma chromaColor_) {

        return !chromaColor_.clipped() && validRange(chromaColor_);

    }

    private boolean validRange(Chroma chromaColor_) {

        return (chromaColor_.getLum() > this.minL)
            && (chromaColor_.getLum() < this.maxL)
            && (chromaColor_.getChr() > this.minC)
            && (chromaColor_.getChr() < this.maxC)
            && (chromaColor_.getHue() > this.minH)
            && (chromaColor_.getHue() < this.maxH);
    }


    private float computeDistance(LumaCentroid centroid1_, LumaCentroid centroid2_) {
        return (float)Math.sqrt(    Math.pow(centroid1_.getChroma().getLum() - centroid2_.getChroma().getLum(), 2) +
                                    Math.pow(centroid1_.getChroma().getChr() - centroid2_.getChroma().getChr(), 2) +
                                    Math.pow(centroid1_.getChroma().getHue() - centroid2_.getChroma().getHue(), 2));

    }


    private boolean checkConvergence(LumaCentroid currentCentroid_, LumaCentroid prevCentroid_) {
        return computeDistance(currentCentroid_, prevCentroid_) < this.convergenceQuality;
    }


    private boolean checkTrue(boolean[] testArray_) {
        for (boolean b: testArray_) if(!b) return false;
            return true;
    }

}
