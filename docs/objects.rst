.. _objects:

=======
Objects
=======



TargetObj
~~~~~~~~~

.. class:: TargetObj(target,target_care_area,resolution,varargin)

   This class creates an object that contains projections and relevant properties.

   :Parameters:   * target - 2D or 3D matrix of sinograms
                  * target_care_area - vector of angles of projection in degrees
                  * resolution - number of slices in the z-direction
                  * dim - number of dimensions of the target
                  * varargin - (optional) stl_filename 

   :Returns:      * obj - instance of :class:`TargetObj` containing the target, dilated target, and z-slice resolution if 3D target. stl_filename is present if the :class:`TargetObj` was generated from a .stl





ProjObj
~~~~~~~

.. class:: ProjObj(projection,proj_params_used,opt_params_used)

   This class creates an object that contains projections and the parameters that were used in creation of the projections.

   :Parameters:   * projection - 2D or 3D matrix of sinograms
                  * proj_params_used - structure of projection parameters
                  * opt_params_used - structure of optimization parameters

   :Returns:      * obj - instance of :class:`ProjObj` containing projections, projection parameters, and optimization parameters




ReconObj
~~~~~~~~

.. class:: ReconObj(reconstruction,,proj_params_used,opt_params_used)

   This class creates an object that contains a reconstruction and the parameters that were used in creation of the reconstruction.

   :Parameters:   * projection - 2D or 3D matrix of reconstruction
                  * proj_params_used - structure of projection parameters
                  * opt_params_used - structure of optimization parameters

   :Returns:      * obj - instance of :class:`ReconObj` containing a reconstruction, projection parameters, and optimization parameters



ProjSetObj
~~~~~~~~~~

.. class:: ImageSetObj(image_set,,proj_params_used,opt_params_used)

   This class creates an object that contains a reconstruction and the parameters that were used in creation of the reconstruction.

   :Parameters:   * image_set - cell array of images (used for image projection)
                  * image_params_used - structure of image parameters
                  * proj_params_used - structure of projection parameters
                  * opt_params_used - structure of optimization parameters

   :Returns:      * obj - instance of :class:`ImageSetObj` containing an image set, image parameters, projection parameters, and optimization parameters

