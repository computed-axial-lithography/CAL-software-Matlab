.. _examples:

========
Examples
========
.. highlight:: matlab


Projection generation and optimization
**************************************

2D matrix example
-----------------
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




3D matrix example
-----------------
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



STL example
-----------
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


------



Image set creation
******************

Typical example
---------------
This example shows how to set the image parameters and create an image set from a projection object. If the STL example above is run before this example the image set should appear as in the image below.
::
    image_params.size_scale_factor = 3;
    image_params.invert_vert = 1;
    image_params.intensity_scale_factor = 1;
    image_params.t_offset = 0;
    image_params.z_offset = 100;
    image_params.array_num = 2;
    image_params.array_offset = 300;
    image_params.image_width = 1920;
    image_params.image_height = 1080;

    C = CALCreateImageSet(proj_obj,image_params);

    image_set_obj = C.run();

    Display.showImageSet(image_set_obj)
    
    % Images may be saved also
    % C.saveImages(image_set_obj,pwd,'.png');


.. image:: images/image_set_ex.png
   :width: 400

Backward compatibility example
------------------------------
This example shows how to set the image parameters and create an image set from a projection matrix (for backward compatibility). 
::
    image_params.size_scale_factor = 3;
    image_params.invert_vert = 1;
    image_params.intensity_scale_factor = 1;
    image_params.t_offset = 0;
    image_params.z_offset = 100;
    image_params.array_num = 2;
    image_params.array_offset = 300;
    image_params.image_width = 1920;
    image_params.image_height = 1080;
    image_params.angles = linspace(0,179,180); % this parameter must be added 

    C = CALCreateImageSet(optimized_projections,image_params); % Note: now a 3D matrix is in the place of the typical projection object

    image_set_obj = C.run();

    Display.showImageSet(image_set_obj)

    % Images may be saved also
    % C.saveImages(image_set_obj,pwd,'.png');



-----

Image sequence projection
*************************

Default settings example
------------------------
This example shows how to set up image sequence projection with an :class:`ImageSetObj` and a specified rotation velocity.
::
    % set the rotation velocity in deg/s
    rot_vel = 24;

    % initialize the CALProjectImageSet class
    DLP = CALProjectImageSet(image_set_obj,24);

    % begin projecting images
    DLP.startProjecting(); 


Custom settings example
-----------------------
This example shows how to set up image sequence projection with an :class:`ImageSetObj`, a specified rotation velocity, custom monitor ID, and no blank image when paused.
::
    % set the rotation velocity in deg/s
    rot_vel = 24;

    % set the monitor ID
    monitor_id = 3

    % initialize the CALProjectImageSet class
    DLP = CALProjectImageSet(image_set_obj,24,monitor_id,0); % Note: 0 sets blank_when_paused to deactivated

    % begin projecting images
    DLP.startProjecting(); 