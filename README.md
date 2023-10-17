:construction: This is a work in progress.

# Exploratory Cluster Analysis using Self-Organizing Maps

Complementary materials and source code to the examples provided in the book chapter "Exploratory Cluster Analysis using Self-Organizing Maps": <https://www.igi-global.com/book/philosophy-artificial-intelligence-its-place/319683>.


## Java Neural Networks Framework

The full framework is available in a separate github site <https://github.com/brunomnsilva/UbiquitousNeuralNetworks>. In addition to the codebase, the GitHub repository also provides a wiki <https://github.com/brunomnsilva/UbiquitousNeuralNetworks/wiki> that serves as a comprehensive guide to using the library. The wiki includes detailed explanations on how to use the library effectively. It also provides examples and tutorials, making it a valuable resource for both newcomers to self-organizing maps and experienced users looking to deepen their understanding.

## MultiSOM Processing Sketch and Libraries

The files in this folder are the following:

  - exemplos/wine.csv - A normalized copy of the Wine dataset <https://archive.ics.uci.edu/dataset/109/wine>.
  - code/neuralnetworks.jar - The second edition of the ubiSOM library. The ubiSOM library was already published and presented in [SilvaMarques,2015].
  - code/multiSOM.jar - multiSOM library for running this example. This code is under development and is made available for enabling multiSOM calls in Processing Sketch. Source code is available upon contacting the authors. The multiSOM library was already published and presented in [MarquesSantosSilva2016].
  - data/* - The Processing data folder.  It will be used for storing output files. Some pre-generated processing font files are included.
  - multiSOM_P2.pde - The Processing PDE sketch containing the example for using the multiSOM library in Processing.
  - wine.mSOM - Configuration script for multiSOM.
  - prototypes.py, plot.py - Illustrative Python scripts called inside multiSOM example script. Some folder names may need correction. 

The source code for examples and for some Java classes for the Libraries are available with the free MIT Licence. Complete source code is under development, but available for research purposes. Please contact the authors if you are interested in helping to develop this project: [Prof. Nuno Marques](mailto:nmm@fct.unl.pt?subject=[GitHub]MultiSOM)

## Instalation

Copy the provided files to a directory "multiSOMP2" on your computer and modify folder names in plot.py as necessary. You can further customize configuration parameters in wine.mSOM and prototypes.py. Open the Processing.org IDE by running the sketch multiSOM_P2.pde. Ensure that your Processing.org render settings are adjusted correctly and that you have the required libraries installed, along with accurate folder names.

*CAUTION:* Please note that this is an early release. It has only been tested on macOS (M2 and Intel) with Processing version 4.2 or 4.3. If you don't have Processing.org installed, make sure to install it before proceeding. Execution of python scripts is currently with some folder problems that should be fixed soon.

## References

Silva, B., & Marques, N. (2015). The ubiquitous self-organizing map for non-stationary data streams. Journal of Big Data.
Marques, N. C., Silva, B., & Santos, H. (2016, July). An interactive interface for multi-dimensional data stream analysis. In 2016 20th International Conference Information Visualisation (IV) (pp. 223-229). IEEE.
