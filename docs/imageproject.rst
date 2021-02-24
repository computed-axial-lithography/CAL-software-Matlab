.. _imageproject:

=========================
Image sequence projection
=========================

.. class:: CALProjectImageSet(image_set_obj,rot_vel,varargin)

    Constructor for the :class:`CALProjectImageSet` class that handles image sequence projection for a given input image set object, ``image_set_obj``.

    To use with optional parameters:
    ::
        T = CALProjectImageSet(image_set_obj,rot_vel,monitor_id,blank_when_paused);

    :Parameters:    * image_set_obj - :class:`ImageSetObj` containing the image set (output from :func:`CALCreateImageSet.run`)
                    
                    * rot_vel - structure of optimization parameters defining the optimization configuration
                    * varargin - optional arguments
                    * monitor_id(*optional*) - number corresponding to the monitor to be used for projection, default is 2 (second monitor)
                    * blank_when_paused(*optional*) - display a blank (black) image when projection is paused, 1 or 0, default is 1
                                                                        

    :Returns:       * obj - instance of :class:`CALProjectImageSet`

    .. classmethod:: startProjecting(obj,varargin) 

    :Parameters:    * varargin - optional arguments
                    * wait_to_start(*optional*) - wait for user to press space bar before beginning projection, 1 or 0, default is 1

    :Returns:       * obj - :class:`CALProjectImageSet`
                    * total_run_time - image sequence time from start of first press of **space bar** to stop with **esc key**


User interaction
----------------

This table summarizes the key actions the user can take during the image sequence projection:

+------------------------+-----------------+
| **Key**                |**Action**       |
+------------------------+-----------------+
| space bar              | play or resume  |
+------------------------+-----------------+
| tab                    |    pause        |
+------------------------+-----------------+
| esc                    |   stop          |
+------------------------+-----------------+
