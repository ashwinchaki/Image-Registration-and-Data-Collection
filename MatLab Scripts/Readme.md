# MATLAB Scripts

These are scripts to create images from already run PCA .mat files.

## Instructions
All of your .mat files should be in 1 directory (the folder can have other things as well). 

To run:
```
addpath('foldername')
```

In order for MATLAB to communicate with the custom ImageJ plugins, it's necessasry that the path to the macro is added correctly. This is found in the `sortandregister.m` file.

Add this to the path, and navigate to the folder containing the .mat files. 

Then use `createImages` to create the black and white `.png` files

From that point on it should be automated fully. 