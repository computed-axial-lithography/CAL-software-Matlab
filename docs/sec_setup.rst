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

   You should see the following if the installation succeeded:
   ::
    CAL-software-Matlab Toolbox installed successfully!

Now the toolbox can be used like any other Matlab toolbox. You do not need to be in a particular working directory to access the functions of the toolbox.

.. _`CAL-software-Matlab`: https://github.com/computed-axial-lithography/CAL-software-Matlab
.. _`release`: https://github.com/computed-axial-lithography/CAL-software-Matlab/releases

Uninstallation
--------------

The toolbox can be uninstalled in the Add-on manager. Go to the Matlab Home tab, then Add-Ons in the Environments panel. Click the dropdown arrow and select Manage Add-Ons. Then click the Options and Uninstall for the CAL-software-Matlab toolbox. 

