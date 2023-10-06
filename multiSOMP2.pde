import processing.javafx.*; //<>//

// Illustrative example for using MultiSOM / ubiSOM in Processing.org v4.2
//
// The wine dataset with simple min-max normalization
// is used as the main input for a first map. In parallel two other 
// maps are trained in the first layer for analysing features related
// with taste and apearance of wine.
// A final map aggregates the results of the three first layer maps 
// and is able to relate the information in the three previous maps 
//  and unsupervisely detect the main clusters in the dataset (correspondent to
//  the omited original classes in the dataset.
//
//  Nuno Marques, September 2023

import commandLine.*;
import csv.*;
import dataStream.*;
import graphs.*;
import multiSOM.*;
import plotMultiDim.*;
import swingUtils.*;
import ubiSOM.*;
import java.io.*;

final int NMAPS = 4;

boolean flag = false;

int maximizedMap = 0;


    
// Submaps:

// Map 1 - Alcohol Content and Phenolic Compounds: 
// focuses on the Alcohol, Total phenols, Flavanoids,
// and Nonflavanoid phenols features. These features
// are the main factors related to the taste of wine,
// Map 2 - Color and Acidity: This map could focus on the Malic acid,
// Ash, Alcalinity of ash, and Color intensity features. 
// These features are related to the color and acidity of the wine, which
// are important factors in the wine's taste and appearance. 


MultiSOMLibrary multiSOM[] = new MultiSOMLibrary[NMAPS];
String[] tasteFS = {"Alcohol","TotPhenols","Flavanoids","NonflavPhenols"};
int[] tasteFN = null;   
String[] appearanceFS = {"MalicAcid","Ash","AshAlcal","ColorInt"};
int[] appearanceFN = null;

static final float mainScale = 0.78f;
static final int mainX = 175;
static final int mainY = 15;

void setup() {
  
    frameRate(10);
    size(1450,768,P2D); // standard render
    //size(1450,768,FX2D); // improved render
    pixelDensity(displayDensity());
    smooth(8);
    textFont(loadFont("Verdana-128.vlw"));
    
    maximizedMap = 0;

    multiSOM[0] = new MultiSOMLibrary(this, 30, "wine.mSOM");
    multiSOM[0].setViewPort(mainX, mainY, mainScale);
    multiSOM[0].setSOMTitle("ini","Wine Initial");
      
    for(int i=1; i<NMAPS; i++) {
      println(i + " multiSOM starting");
      multiSOM[i] = new MultiSOMLibrary(this, 30,""); 
      multiSOM[i].setViewPort(5, 100+i*150, 0.1f);
      println(i + " multiSOM is OK");
    }
    multiSOM[1].setSOMTitle("taste","Wine Taste");
    multiSOM[2].setSOMTitle("asp","Wine Aspect");
    multiSOM[3].setSOMTitle("agt","Wine Aggregatted");
}


int[] initLabels(MultiSOMLibrary ms, int[] FN, int st) {
   for(int i=0; i< FN.length; i++)
       ms.setCatLabel(i+st,multiSOM[0].getCatLabel(FN[i]));
       return FN;
}    

void initAllMaps() {
      tasteFN = initLabels(multiSOM[1], multiSOM[0].getFeatureIndices(tasteFS),0);
      appearanceFN = initLabels(multiSOM[2], multiSOM[0].getFeatureIndices(appearanceFS),0);
      
      multiSOM[1].setColorDim(0);
      multiSOM[1].setAxisTransform(
        new int[]{2238, 29, 216, 5435},
        new int[]{2071, 6384, 8031, 106});

      multiSOM[2].setColorDim(3);
      multiSOM[2].setAxisTransform(
        new int[]{2320, 1719, 10000, 0},
        new int[]{4778, 1627, 168, 10000});  
        
      String aggregatedLabels[] = {"xBmu", "yBmu","nQe"};
      for(int i=0; i< aggregatedLabels.length; i++) multiSOM[3].setCatLabel(i,aggregatedLabels[i]);
      initLabels(multiSOM[3], multiSOM[0].getFeatureIndices(tasteFS),aggregatedLabels.length);
      initLabels(multiSOM[3], multiSOM[0].getFeatureIndices(appearanceFS),aggregatedLabels.length+tasteFS.length);
      multiSOM[3].setColorDim(0);
      multiSOM[3].setAxisTransform( // values where acquired on previous execution by manual adjustment and using the "A" key
              new int[]{2391,     0,  122,   91,   16,   33, 214,  117,   89,  228, 40},
              new int[]{   8, 10000, 2851, 6981, 1898, 3345, 802, 4811, 1316, 1916, 76});

}

void trainAllMaps() {
    DataPattern data = multiSOM[0].getNextPat(); // reference map

    DataPattern tasteData = data.subset(tasteFN, "S1"+data.getLabel());
    DataPattern appearanceData = data.subset(appearanceFN, "S2"+data.getLabel());
    
    multiSOM[0].addSOMDataMPoint(data);
    multiSOM[1].addSOMDataMPoint(tasteData);
    multiSOM[2].addSOMDataMPoint(appearanceData); 
    
    double [] bmuPos = multiSOM[0].getBMUPos(0.035); // Second level map
    
    if(bmuPos != null) {  // only draws submap when QE is acceptable
      DataPattern aggregatedData = new DataPattern(
                MultiSOMLibrary.join(new double[][]{
                                 //new double[] {bmuPos[0],bmuPos[1]},
                                 bmuPos,
                                 multiSOM[1].getBMUPrototype(),
                                 multiSOM[2].getBMUPrototype()}),
                                 "Ag"+data.getLabel());
                                 
      multiSOM[3].addSOMDataMPoint(aggregatedData);
    } else
      multiSOM[3].setSOMIteration(multiSOM[0].getSOMIteration()); // Sync iteration counts (for error plot)
}
      
int nIts = 1;

void draw() {
  
  boolean hasData = true;
  for(int mapInIteration=0;mapInIteration<NMAPS;mapInIteration++) {
    multiSOM[mapInIteration].drawDatastreamSOM();
   if(!multiSOM[mapInIteration].hasTrainData())
      hasData = false;
  }
    
  if(hasData){ // ready SOMs wait until every map is ready for train
    nIts += 1;
    if(tasteFN == null) // on first call features where already read from csv
                        // and maps can be init
      initAllMaps();
    trainAllMaps();
  }
  
  /// Post-Visualization updates
  for(int mapInIteration=0;mapInIteration<NMAPS;mapInIteration++) 
      multiSOM[mapInIteration].postTrainVisualization();
}

boolean pauseNetwork = false;

void setPauseAllNets() {
  for(int i=0; i <NMAPS;i++) {
    multiSOM[i].setPauseNetwork(pauseNetwork);
  }
}

void setSubSOMMaps() {
          for(int i=1; i <NMAPS;i++) {
            int val = multiSOM[0].getStepIterations();
            multiSOM[i].stepSOM(val);
            multiSOM[i].showMessage("_       Train steps sync to "+val+" its.");
          }
}
          


void keyTyped() {
  switch(key) {
        case '0':
          multiSOM[0].setRandomOrder(!multiSOM[0].getRandomOrder());
          multiSOM[maximizedMap].showMessage("_       "+
                (multiSOM[0].getRandomOrder() ? "random":"linear")+" order on data source.");
          break;
        case 'P': // Pause train on all maps
          pauseNetwork = !pauseNetwork;
          setPauseAllNets();
          if (pauseNetwork) {
            multiSOM[maximizedMap].showMessage("_       Pause on Network Information.");
          } else
          multiSOM[maximizedMap].showMessage("_       Activating Network Information.");
          break;
      case 'I':  // interactive terminal on base map
        pauseNetwork = true;
        setPauseAllNets();
        multiSOM[0].keyTyped(key);
        break;
      case 'A': 
        println(multiSOM[maximizedMap].getAxisLabels());
        break;
      case 'W':
        for(int i=0;i<NMAPS;i++) multiSOM[i].saveModel();
        break;
      case 'T': // Force train from base map to all maps
        setSubSOMMaps();
        break;
      case 'C':
        multiSOM[maximizedMap].runPython("prototypes.py");
        break;
      case 'E':
        multiSOM[maximizedMap].runPython("plot_log.py", true, "178", Integer.toString(nIts));
        break;
      case 'V':
        println(sketchPath("prototypes.py") + " --- " + dataPath("") );
        break;
      default:
        multiSOM[maximizedMap].keyTyped(key);
  }
}



void mousePressed() {
  if(multiSOM[maximizedMap].mouseInViewPort())
    multiSOM[maximizedMap].mousePressed(mouseX, mouseY);
  else
   for(int i=0; i<NMAPS; i++) {      
    if(multiSOM[i].mouseInViewPort()) {
       background(200);
       multiSOM[maximizedMap].setViewPort(5, 100+maximizedMap*150, 0.1f);
       multiSOM[i].setViewPort(mainX, mainY, mainScale);
       maximizedMap = i;
       println(maximizedMap + " multiSOM is maximized.");
       multiSOM[maximizedMap].showMessage("_      Maximized SOM "+maximizedMap, 1000);
     } 
   } 
}



void mouseDragged() { 
  multiSOM[maximizedMap].mouseDragged(mouseX,  mouseY,  pmouseX,  pmouseY);
}
