# Touche with SVM classification

## DataCollection
You can save relationship between the feature values of Capacitance and the gesture by clicking square on the board.

Edit *kindOfMaterial* for your touch sensing object. ex) water, sand, hand...

You should press "s" to save the all data before exitting.

The data are saved to Processing_collect_data/data/YOUR_MATERIAL_NAME/..

## Visualization
You can classify the gesture based on your own data (collected in Processing_collect_data).

The classifier is SVM (Support Vector Machine).

This scripts needs to start after *SVM Classification.py* starts.

## Classification
Run　the first column　to create the classification model with SVM based on your data (**Need to specify the path of data**).

Run the second column to receive the feature values of Capacitance from Processing and return gesture to Processing.

This scripts needs to start before *Processing_graph_from_python.pde* starts.
