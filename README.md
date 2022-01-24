# COCOA: Capacity Planner for In-House FaaS

This is the repository for COCOA, a cold start aware capacity planner for private FaaS platforms, which we presented in [MASCOTS 2020](https://ieeexplore.ieee.org/document/9285966).

COCOA is built using Matlab. To run the tool, simply execute the script Controller.m. To understand the parameters, please refer to our paper in MASCOTS. The output produced by COCOA can be verified with our [FaasSim](https://github.com/alimulgias/FaasSim) tool.

COCOA has the following dependencies:
+ [Matlab Parallel Computing toolbox](https://www.mathworks.com/products/parallel-computing.html)
+ [LINE solver](http://line-solver.sourceforge.net/) (we tested it with version 2.0.4)
+ [QMAM solver](https://bitbucket.org/qmam/qmam/src/master/)
+ [MAMSolver](https://www.cs.wm.edu/MAMSolver/)

When running the Controller.m script, please ensure all the solvers are added in the Matlab path.
