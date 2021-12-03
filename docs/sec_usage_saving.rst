.. highlight:: matlab


Saving data for later use
#########################

If you would like to use any data at later time, any of :class:`TargetObj`, :class:`ProjObj`, :class:`ReconObj`, and :class:`ImageSetObj` objects can be saved. Often it will be useful to save the projections and image sets (:class:`ProjObj` and :class:`ImageSetObj`) for later use.

Use Matlab's ``save()`` as you would for any other Matlab variable. For the examples, one would use the following code to save these objects:
::
    % 'Example.mat' is the intended saved filename
    % 'target_obj','proj_obj','recon_obj','image_set_obj' are the variables (objects in this case) being saved into Example.mat
    save('Example.mat','target_obj','proj_obj','recon_obj','image_set_obj')

    