.. _optimization:

============
Optimization
============

.. class:: CALOptimize(target_obj,opt_params,proj_params,verbose)

    Constructor for the :class:`CALOptimize` class that handles optimization for a given input target object, ``target_obj``.


    :Parameters:    * target_obj - :class:`TargetObj` containing the target (output from :func:`CALPrepTarget`)
                    
                    * opt_params - structure of optimization parameters defining the optimization configuration
                        * parallel     -  activates parallel processing if set to 1                                                                                   
                        * max_iter     -  number of iterations used in the iterative optimization                                                                     
                        * learning_rate- step size in gradient descent                                                                                                
                        * sigmoid      - width of the sigmoid thresholding function, smaller corresponds to higher contrast photoresist                               
                        * threshold    - threshold value from 0 to 1, if NaN, the threshold will float to the optimum during optimization
                        * Beta         - optimization memory/momentum, 0 to 1, higher value gives more weight to previous gradients and can lead to faster convergence
                        * Theta        - relaxation of positivity constraint, 0 to 1, higher value relaxes positivity constraint more                                                                                       
                        * Rho          - robustness for dilation and erosion, 0 to 1, higher value enforces higher accuracy in thin region around target contour                                                                                         
                        +------------------------+-----------------+
                        | **opt_params.x**       |**Default value**|
                        +------------------------+-----------------+
                        | parallel               |    0            |
                        +------------------------+-----------------+
                        | max_iter               |    10           |
                        +------------------------+-----------------+
                        | learning_rate          |   0.005         |
                        +------------------------+-----------------+
                        | sigmoid                |   0.01          |
                        +------------------------+-----------------+
                        | threshold              |   NaN           |
                        +------------------------+-----------------+
                        | Beta                   |   0             |
                        +------------------------+-----------------+
                        | Theta                  |   0             |
                        +------------------------+-----------------+
                        | Rho                    |   0             |
                        +------------------------+-----------------+

                    * proj_params - structure of projection parameters defining the projection configuration
                        * angles - vector of angles at which to perform forward and back projection
                        * bit8 - activates projection with simulated 8-bit intensity (pixel intensities are binned into 256 bins)
                        +------------------------+-----------------+
                        | **proj_params.x**      |**Default value**|
                        +------------------------+-----------------+
                        | angles                 |    [0:1:179]    |
                        +------------------------+-----------------+
                        | bit8                   |    0            |
                        +------------------------+-----------------+


                    * verbose - to show additional details and plots during runtime

    :Returns:       * obj - instance of :class:`CALOptimize`

    .. classmethod:: run(obj) 

    :Parameters:    * None

    :Returns:       * opt_proj_obj - :class:`ProjObj` containing the optimized projections
                    * opt_recon_obj - :class:`ReconObj` containing the optimized reconstruction
                    * obj - updated instance of :class:`CALOptimize` containing the error and thresholds (if floating) calculated during optimization.

    .. classmethod:: getInds(obj)
    
    :Parameters:    * None

    :Returns:       * gel_inds - indices for the voxels/pixels inside the target
                    * void_inds - indices for the voxels/pixels outside the target and inside the inscribed reconstruction circle

    .. classmethod:: evalError(obj,x)
        
    :Parameters:    * x - reconstruction on which to evaluate the error

    :Returns:       * VER - voxel error rate, the error evaluated as :math:`VER=\frac{W}{N}` where :math:`W` is the number void voxels that receive more dose than the dose of the minimum gel voxel and :math:`N` is the total number of gel and void voxels

    .. classmethod:: sigmoid(x,g)
    
    :Parameters:    * x - reconstruction to threshold
                    * g - sigmoid width
        

    :Returns:       * y - sigmoid thresholded reconstruction

