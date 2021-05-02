
.. highlight:: matlab




Image projection control
########################

Once the image set is created, image projection with the DLP projector can begin. To do this, the toolbox assumes that `Pysch Toolbox 3 for Matlab`_ is installed. Pysch Toolbox allows precise control of images on a DLP projector that is connected as a second monitor. 

To begin, the projector should be connected as a second monitor and should be responsive to changes such as a system file explorer being dragged across the monitor or normal web video. The following code can be used to check if Matlab recognizes there are two monitors:
::
    monitors = get(groot,'MonitorPositions')

Once you verify the monitor number corresponding to the projector, you can begin the image projection by first initializing the :class:`CALProjectImageSet` with the :class:`ImageSetObj` created in the previous section and the rotation velocity of the rotation stage in degrees/s as:
::
    DLP = CALProjectImageSet(image_set_obj,24);

The DLP projector is assumed to be the second monitor by default. If your projector is not the second monitor, you may also specify the monitor number (4 as an example) as a third argument:
::
    DLP = CALProjectImageSet(image_set_obj,24,4);

When initializing, sometimes the projector can flash a bright image so make sure that the resin remains blocked from light at this point. 

Next, to begin projecting, use the class function :func:`startProjecting`:
::
    DLP.startProjecting();

After this, by default, the code will wait until the user presses the **space bar** to begin playing the image sequence. This is a good time to remove a light blocker in front of the resin. Then, as the image sequence plays the user can press the **tab key** to pause the image sequence (**space bar** resumes the sequence). To stop the image sequence at any time, the user can press the **escape key**.

For more information setting up the image sequence projection, see :ref:`imageproject` and :ref:`examples`.

.. _`Pysch Toolbox 3 for Matlab`: http://psychtoolbox.org/download


-----
