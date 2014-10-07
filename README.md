RFPoseEstimation
================

This is a Matlab/Mex implementation of a 2D human pose estimator that was used
in the paper "Multi-view Body Part Recognition with Random Forests".

For more information please refer to my homepage: http://www.csc.kth.se/~vahidk/

If you plan to use this source code please cite:

```
@inproceedings{kazemi2013multi,
  title={Multi-view Body Part Recognition with Random Forests},
  author={Kazemi, Vahid and Burenius, Magnus and Azizpour, Hossein and Sullivan, Josephine},
  booktitle={BMVC},
  year={2013}
}
```

You need matlab to run this code. 
To compile and run the code simply run:

````
cd {RFPoseEstimationDirectory}/code
make
globals
football_test
```

This runs the code for testing the model on the pretrained football dataset.
To train a new model run:

```
globals
football_train
```

You can change the code to read your own dataset. Look at how it's done in 
football_train.m and football_test.m

Vahid Kazemi

