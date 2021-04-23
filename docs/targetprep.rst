==================
Target preparation
==================
.. highlight:: matlab

.. function:: CALPrepTarget(stl_filename,resolution,verbose)

    This function is used to prepare a target for optimization. It accepts a .stl file, 
    a 3D matrix, or 2D matrix as the input. For .stl files, the function will voxelize the 
    .stl file into a 3D matrix defined by the ``resolution`` input. For direct 2D or 3D matrices,
    the function will morphologically dilate the 

    For 3D matrices it should be used as: 
    ::
        T = CALPrepTarget([],[],verbose,target_3D);

    For 2D matrices it should be used as: 
    ::
        T = CALPrepTarget([],[],verbose,target_2D);

        
    :Parameters:    * stl_filename - filepath to the .stl file
                    * resolution - number of layers to slice the .stl file in the z-direction
                    * verbose - to show additional details and plots during runtime
                    * target_2D or target_3D - (optional) 2D or 3D matrix containing a binary target


    :Returns:       * target_obj - :class:`TargetObj` object containing voxelized target (or 2D or 3D matrix), dilated target, and other relevant properties
    

Supporting Functions
--------------------
.. function:: prepTarget(target,verbose)

    :Parameters:    * target - 2D or 3D matrix containing the binary target
                    * verbose


    :Returns:       * prepped_target - prepared target, dilated target, and other relevant properties
                    * target_care_area - dilated target



.. function:: voxelizeTarget(stl_filename,resolution,verbose)

    :Parameters:    * stl_filename - filepath to the .stl file
                    * resolution - number of layers to slice the .stl file in the z-direction
                    * verbose


    :Returns:       * voxelized_target - 3D matrix of voxelized .stl file
                    * target_care_area - dilated target