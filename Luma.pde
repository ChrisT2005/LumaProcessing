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
        lumaDomain = createDomain(minL_, maxL_, minC_, maxC_, minH_, maxH_);

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

        boolean converged = false;

        while(!converged) {

            ArrayList<LumaCentroid> prevClusters = lumaClusters;

            // First assign each data point to its nearest cluster
            for (int i = 0; i < lumaDomain.size(); i++) {

                float minDistance = 100000000;

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
            // Now compute the centroid means and check if its within the Domain
            for (int j = 0; j < lumaClusters.size(); j++) {

                int count = 0;
                float[] kMean = new float[]{0.0,0.0,0.0};
                for (int i = 0; i < lumaDomain.size(); i++) {
                    if (lumaDomain.get(i).getClusterID() == j) {

                        count++;
                        kMean[0] += lumaDomain.get(i).getChroma().getLum();
                        kMean[1] += lumaDomain.get(i).getChroma().getChr();
                        kMean[2] += lumaDomain.get(i).getChroma().getHue();

                    }
                }
                if (count!=0) {
                    kMean[0] /= count;
                    kMean[1] /= count;
                    kMean[2] /= count;
                }

                LumaCentroid tempCentroid = new LumaCentroid(kMean[0], kMean[1], kMean[2]);

                if (count!=0 && !tempCentroid.getClippedStatus()) {

                    // println("Centroid Added: " +j + tempCentroid);
                    convergenceTest[j] = checkConvergence(tempCentroid, lumaClusters.get(j));
                    lumaClusters.set(j,tempCentroid);
                } else {
                    println("CENTROID OUT OF BOUNDS!!!");
                }

            }

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


    private ArrayList<LumaCentroid> createClusters(int lumaClusterCount_) {

        ArrayList<LumaCentroid> lumaClusters_ = new ArrayList<LumaCentroid>();

        for (int i = 0; i < lumaClusterCount_; i++) {

            boolean foundValidCentroid = false;

            // Try until the centroid is not clipped
            while(!foundValidCentroid) {
                LumaCentroid tempCentroid = new LumaCentroid(random(this.minL,this.maxL), random(this.minC,this.maxC), random(this.minH, this.maxH));

                if (!tempCentroid.getClippedStatus()) {

                    lumaClusters_.add(tempCentroid);
                    foundValidCentroid = true;

                }
            }
        }
        return lumaClusters_;
    }


    // MATH & UTILITY METHODS


    private boolean validColor(Chroma chromaColor_) {
        return chromaColor_.clipped();
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
