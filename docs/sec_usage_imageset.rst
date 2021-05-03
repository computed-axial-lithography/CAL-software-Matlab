.. highlight:: matlab


Creating image sets
###################

.. image:: images/image_set_create.png
   :width: 1000

Image sets are what is typically used to when commanding the projector system during a CAL print. They are generated from the optimized projections given some image parameters that perform scaling, rotation, multiplication, etc. based on the configuration of the CAL system and the desired print characteristics. More information on the image parameters can be found in :ref:`imagesetcreation` in the code reference.

To generate an image set, you can use the :class:`CALCreateImageSet` class. First, initialize the class with the :class:`ProjObj`, generated during optimization, and the image parameters:
::
    image_params.size_scale_factor = 2; % size scale of the projection within the image
    image_params.z_offset = 200;        % offset in vertical direction in # of pixels
    C = CALCreateImageSet(proj_obj,image_params);

Then use the class function :func:`run` to start creating the image set:
::
    image_set_obj = C.run();

Here :func:`run` creates an :class:`ImageSetObj` and it is saved to ``image_set_obj`` in this example case. 



Saving images from an image set
-------------------------------

If you would like to save the image set as individual images, the class function :func:`saveImages` can be used. You can use the instance of the :class:`CALCreateImageSet` class created above as:
::
    % saveImages(ImageSetObj,save filepath,image filetype)
    C.saveImages(image_set_obj,pwd,'.png');

Or you can run the class function :func:`saveImages` standalone if you only have the :class:`ImageSetObj` as:
::
    CALCreateImageSet.saveImages(image_set_obj,pwd,'.png');

A folder called ``images`` will be created at the specified filepath (here the current working directory is used) and the images will be saved individually into the folder with filenames ``0001.png``, ``0002.png``, and so on.


Backward compatibility
----------------------

Previous versions of the CAL-software-Matlab toolbox have used a "plain" 3D projection matrix when generating the image set. In the current and all future versions of the toolbox, the projection matrix is contained in the :class:`ProjObj` along with all of the parameters that were used to create the optimized projection matrix. 

:class:`CALCreateImageSet` takes in a :class:`ProjObj` and uses these parameters to generate the correct image set. However, it has also been designed to accept a "plain" 3D projection matrix in place of the :class:`ProjObj` as long as the image parameter ``angles`` is set to the angles at which this "plain" projection matrix was calculated. 


----

