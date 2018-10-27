# Touche with SVM classification


## 1. DataCollection
You can save relationship between the feature values of Capacitance and the gesture by clicking square on the board.

You should press "s" to save the all data before exiting.

The data are saved to "Processing/DataCollection/data/.."


## 2. Classification
You can create the classification model with SVM based on your data (**Need to specify the path of data**).

Then you can receive the feature values of capacitance from Processing and return gesture to Processing.

This scripts needs to start before *Actuation.pde* starts.


## 3. Actuation
You can see the gesture based on your own data (collected in DataCollection) and drive electromagnets.

The classifier is SVM (Support Vector Machine) on Python.

This scripts needs to start after *Classification.ipynb* starts.
