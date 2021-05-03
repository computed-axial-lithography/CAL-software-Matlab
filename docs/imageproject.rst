.. _imageproject:

=========================
Image sequence projection
=========================

.. class:: CALProjectImageSet(image_set_obj,rot_vel,varargin)

    Constructor for the :class:`CALProjectImageSet` class that handles image sequence projection for a given input image set object, ``image_set_obj``.

    To use with optional parameters:
    ::
        DLP = CALProjectImageSet(image_set_obj,rot_vel,monitor_id,blank_when_paused);

    :Parameters:    * image_set_obj - :class:`ImageSetObj` containing the image set (output from :func:`CALCreateImageSet.run`)
                    
                    * rot_vel - structure of optimization parameters defining the optimization configuration
                    * varargin - optional arguments
                    * monitor_id(*optional*) - number corresponding to the monitor to be used for projection, default is 2 (second monitor)
                    * blank_when_paused(*optional*) - display a blank (black) image when projection is paused, 1 or 0, default is 1
                                                                        

    :Returns:       * obj - instance of :class:`CALProjectImageSet`

    .. classmethod:: motorInit(obj,MotorSerialNum,Start_Pos,varargin)

    :Parameters:    * MotorSerialNum - serial number of motor stage that is controllable by Thorlabs APT suite
                    * Start_Pos - angular position to start projection in degrees
                    * varargin - optional arguments
                    * acc(*optional*) - stage acceleration in degrees per second^2, default is 24

    :Returns:       * obj - :class:`CALProjectImageSet`

    .. classmethod:: startProjecting(obj,varargin) 

    :Parameters:    * varargin - optional arguments
                    * wait_to_start(*optional*) - wait for user to press space bar before beginning projection, 1 or 0, default is 1
                    * proj_duration(*optional*) - duration of projection in seconds. This input disables user interaction through keyboard and terminates the projection when time equals proj_duration has elapsed.

    :Returns:       * obj - :class:`CALProjectImageSet`

User interaction (Optional)
----------------

This table summarizes the key actions the user can take during the image sequence projection (and stage rotation if enabled with :classmethod: `motorInit`):

+------------------------+-----------------+
| **Key**                |**Action**       |
+------------------------+-----------------+
| space bar              | play or resume  |
+------------------------+-----------------+
| tab                    |    pause        |
+------------------------+-----------------+
| esc                    |   stop          |
+------------------------+-----------------+
