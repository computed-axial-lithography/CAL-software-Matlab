.. _setup:

=====
Setup
=====
.. highlight:: matlab

Requirements
------------

1. Matlab 2019b or higher
2. `Pyschtoolbox`_ v3 or higher

.. _`Pyschtoolbox`: http://psychtoolbox.org/download

Installation
------------

The `CAL-software-Matlab`_ package can be installed by completing the following steps:

1. Download the ``CAL-software-Matlab.mltbx`` file from the latest `release`_. This is a Matlab toolbox file (.mltbx) with all the necessary files for the CAL-software package.
2. Open Matlab and run the following code in the Matlab command line. Be sure to change ``toolboxFile`` to the correct path to the downloaded .mltbx file.
   ::
    toolboxFile = 'C:\Downloads\CAL-software-Matlab.mltbx';
    matlab.addons.toolbox.installToolbox(toolboxFile)
3. To test the installation run the following code in the Matlab command line:
   ::
    CALtest()

   This function will test the basic functionality of the toolbox and check if a GPU is available for the use of the `Astra toolbox`_ which is included in this toolbox.
   
   You should see the following if installation was successful:
   ::
    CAL-software-Matlab Toolbox installed successfully!
    Getting GPU info...
    Testing basic CPU 2D functionality...
    Testing basic CUDA 2D functionality...
    Testing basic CUDA 3D functionality...

   If your computer has a NVIDIA GPU the CUDA 2D and 3D functionality should say "Ok".

Now the toolbox can be used like any other Matlab toolbox. You do not need to be in a particular working directory to access the functions of the toolbox.


Astra Toolbox
-------------
`Astra toolbox`_ is a toolbox for GPU-accelerated tomography which has very flexible projector geometries that can be used for non-standard CAL systems. If Astra installation fails, go to the Astra Github repository and download the `Mex and Tools`_ folders and place them in a folder inside the source folder in which CAL-software-Matlab is installed.

.. _`CAL-software-Matlab`: https://github.com/computed-axial-lithography/CAL-software-Matlab
.. _`release`: https://github.com/computed-axial-lithography/CAL-software-Matlab/releases
.. _`Astra toolbox`: https://github.com/astra-toolbox/astra-toolbox
.. _`Mex and Tools`: https://github.com/astra-toolbox/astra-toolbox/tree/master/matlab

Uninstallation
--------------

The toolbox can be uninstalled in the Add-on manager. Go to the Matlab Home tab, then Add-Ons in the Environments panel. Click the dropdown arrow and select Manage Add-Ons. Then click the Options and Uninstall for the CAL-software-Matlab toolbox. 

