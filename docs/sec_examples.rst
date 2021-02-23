.. _examples:

========
Examples
========
.. highlight:: matlab




2D Matrix Example
*****************
This example shows how to use the CAL-software Toolbox to generate projections for directly specified 3D matrix. The function :func:`createTarget()`
will create an example 2D matrix to optimize. 
::
    clear all
    close all

    % set projection parameters
    proj_params.angles = linspace(0,179,180);

    % set optimization parameters
    opt_params.max_iter = 50;
    opt_params.threshold = 0.85;

    verbose = 1;

    % create an example 2D target
    target_2D = createTarget(201,'L',2);

    % prepare the target
    target_obj = CALPrepTarget([],[],verbose,target_2D);

    % instantiate the optimization class
    Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

    % run the optimization
    [proj_obj,recon_obj,Opt] = Opt.run();

----


3D Matrix Example
*****************
This example shows how to use the CAL-software Toolbox to generate projections for directly specified 3D matrix. The function :func:`createTarget()`
will create an example 3D matrix to optimize. 
::
    clear all
    close all

    % set projection parameters
    proj_params.angles = linspace(0,179,180);

    % set optimization parameters
    opt_params.max_iter = 40;
    opt_params.threshold = 0.85;

    verbose = 1;

    % create an example 3D target
    target_3D = createTarget(201,'L',3);

    % prepare the target
    target_obj = CALPrepTarget([],[],verbose,target_3D);

    % instantiate the optimization class
    Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

    % run the optimization
    [proj_obj,recon_obj,Opt] = Opt.run();

----

STL Example
***********

This example shows how to use the CAL-software Toolbox to generate projections for a .stl file. NOTE: ``stl_filename`` should be 
replaced with the filepath to the .stl file you would like to use. This example loads the filepath to a .stl file that is included
in the toolbox for convenience of testing the installation.
::
    clear all
    close all

    % set projection parameters
    proj_params.angles = linspace(0,179,180);
    proj_params.bit8 = 1;

    % set optimization parameters
    opt_params.max_iter = 50;
    opt_params.threshold = 0.8;
    opt_params.learning_rate = 0.005;

    verbose = 1;

    % prepare the target
    resolution = 140;
    stl_filename = loadExStlFilename('bear'); % acceptable inputs 'bear', 'thinker', 'octet', 'octahedron'
    target_obj = CALPrepTarget(stl_filename,resolution,verbose);

    % instantiate the optimization class
    Opt = CALOptimize(target_obj,opt_params,proj_params,verbose);

    % run the optimization
    [proj_obj,recon_obj,Opt] = Opt.run();