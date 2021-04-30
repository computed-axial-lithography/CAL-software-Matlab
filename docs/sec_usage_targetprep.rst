.. highlight:: matlab


Target preparation
##################

To begin the optimization process, first the target is prepared. The target may be a 2D matrix, a 3D matrix, or a .stl file. In general,
the :func:`CALPrepTarget` is used. Run the function with .stl filename (full path to the .stl file) and the z-slicing resolution. This will
create a :class:`TargetObj` which is saved as ``target_obj`` here:
::
    % prepare the target (.stl)
    verbose = 1;
    resolution = 100;
    stl_filename = 'C:\...\test.stl';
    target_obj = CALPrepTarget(stl_filename,resolution,verbose);

Alternatively, for directly inputting a 2D or 3D matrix, the function should be run as:
::
    % prepare the target (2D matrix)
    target_2D = double(phantom(256)>0.01);
    target_obj = CALPrepTarget([],[],verbose,target_2D);

    % prepare the target (3D matrix)
    target_3D = repmat(double(phantom(256)>0.01),[1,1,50]);
    target_obj = CALPrepTarget([],[],verbose,target_3D);

----

