==========
Projectors
==========

The projector performs the transformation from target or object space :math:`X` to projection or sinogram space :math:`Y` or vice versa. Specifically, forward projection
refers to the transformation from object space to projection space and backward projection (or back projection) refers to the transformation
from projection space to object space.

Forward projection :math:`A: X \rightarrow Y` can be written as 

.. math:: b = Ax

where :math:`b` is the projection, :math:`x` is the object, and :math:`A` is the forward projector. The backward projection :math:`A^*: Y \rightarrow X` is the adjoint
of the forward projector and can be written as

.. math:: x = A^*b

where :math:`A^*` is the back projector.

The projectors currently available in the toolbox make some assumptions about the light propagation in CAL. First, because they use  
Matlab's :func:`radon` and :func:`iradon` functions, they assume the light rays are travelling parallel and there is no convergence and
divergence of the image. For projection systems with long focal length relative to the print container diameter, this assumption is valid. Second,
they assume light intensity decay due to absorption is negligible. This is only valid if the penetration depth of the resin-photoinitiator formulation
(:math:`d=1/\alpha` where :math:`\alpha` is the absorption coefficient of the resin-photoinitiator formulation) is somewhat large relative to the print
container radius. Good print results have been acheived with :math:`d \geq` ~1-10 :math:`R` where :math:`R` is the print container radius.

Constructor
-----------

.. function:: CALProjectorConstructor(target_obj,proj_params,parallel)

    Constructs a :class:`ProjectorObj` for performing forward and back projection. The projector used will depend on the dimension of the
    ``target_obj`` input.


    :Parameters:    * target_obj - :class:`TargetObj` containing the target (output from :func:`CALPrepTarget`)
                    * proj_params - structure of projection parameters defining the projection configuration
                        * proj_params.angles - vector of angles at which to perform forward and back projection
                        * proj_params.CUDA - en/disables usage of Astra toolbox GPU accelerated projector
                        * proj_params.inclination_angle - angle of elevation from normal tomographic plane
                        * proj_params.cone_angle - angle of maximum ray divergence along rotation axis in cone beam geometry
                    * parallel - whether or not to use parallel processing when performing forward and back projection

    :Returns:       * ProjectorObj - :class:`ProjectorObj` that links to the correct projector depending on the target dimensions

3D (Matlab)  
-----------

.. class:: Projector3DParallel(proj_params,parallel)

    Constructs a :class:`Projector3DParallel` object for performing 3D forward and back projection with **parallel ray geometry** using Matlab's ``radon`` and ``iradon`` functions. 


    :Parameters:   * proj_params - structure of projection parameters defining the projection configuration
                        * proj_params.angles - vector of angles at which to perform forward and back projection
                    * parallel - whether or not to use parallel processing when performing forward and back projection

    :Returns:       * obj - :class:`Projector3DParallel`

    .. classmethod:: forward(x)

        Performs 3D forward projection using Matlab's :func:`radon`. NOTE: this assumes parallel projection. 

        :Parameters:   * x - 3D matrix of target

        :Returns:      * b - 3D matrix of sinograms. Dimensions will be ``[nT,nTheta,nZ]`` where ``nT`` is the number of elements in the transverse/radial direction, ``nTheta`` is the number of angles, and ``nZ`` is the number of z-slices

    .. classmethod:: backward(b)

        Performs 3D back projection using Matlab's :func:`iradon`. NOTE: this assumes parallel projection. 

        :Parameters:   * b - 3D matrix of sinograms

        :Returns:      * x - 3D matrix of reconstruction. Dimensions will be ``[nT,nT,nZ]`` where ``nT`` is the number of elements in the transverse/radial direction and ``nZ`` is the number of z-slices

3D (Astra)  
----------
.. class:: Projector3DCUDA(proj_params)

    Constructs a :class:`Projector3DCUDA` object for performing 3D forward and back projection with **parallel and cone beam geometry** using Astra Toolbox GPU accelerated projectors. 


    :Parameters:   * proj_params - structure of projection parameters defining the projection configuration
                        * proj_params.angles - vector of angles at which to perform forward and back projection
                        * proj_params.CUDA - en/disables usage of Astra toolbox GPU accelerated projector
                        * proj_params.inclination_angle - angle of elevation from normal tomographic plane
                        * proj_params.cone_angle - angle of maximum ray divergence along rotation axis in cone beam geometry


    :Returns:       * obj - :class:`Projector3DCUDA`

    .. classmethod:: forward(x)

        Performs 3D forward projection using Astra's GPU accelerated 3D projectors. 

        :Parameters:   * x - 3D matrix of target

        :Returns:      * b - 3D matrix of sinograms. Dimensions will be ``[nT,nTheta,nZ]`` where ``nT`` is the number of elements in the transverse/radial direction, ``nTheta`` is the number of angles, and ``nZ`` is the number of z-slices

    .. classmethod:: backward(b)

        Performs 3D back projection using Astra's GPU accelerated 3D projectors. 

        :Parameters:   * b - 3D matrix of sinograms

        :Returns:      * x - 3D matrix of reconstruction. Dimensions will be ``[nT,nT,nZ]`` where ``nT`` is the number of elements in the transverse/radial direction and ``nZ`` is the number of z-slices

2D (Matlab)
-----------

.. class:: Projector2DParallel(proj_params)

    Constructs a :class:`Projector2DParallel` object for performing 2D forward and back projection with **parallel beam geometry** using Matlab's :func:`radon` and :func:`iradon` functions.


    :Parameters:   * proj_params - structure of projection parameters defining the projection configuration
                        * proj_params.angles - vector of angles at which to perform forward and back projection

    :Returns:       * obj - :class:`Projector2DParallel`

    .. classmethod:: forward(x)

        Performs 2D forward projection using Matlab's :func:`radon`. NOTE: this assumes parallel projection. 

        :Parameters:   * x - 2D matrix of target

        :Returns:      * b - 2D matrix of sinograms. Dimensions will be ``[nT,nTheta,nZ]`` where ``nT`` is the number of elements in the transverse/radial direction, ``nTheta`` is the number of angles, and ``nZ`` is the number of z-slices

    .. classmethod:: backward(b)

        Performs 2D back projection using Matlab's :func:`iradon`. NOTE: this assumes parallel projection. 

        :Parameters:   * b - 2D matrix of sinograms

        :Returns:      * x - 2D matrix of reconstruction. Dimensions will be ``[nT,nT]`` where ``nT`` is the number of elements in the transverse/radial direction
