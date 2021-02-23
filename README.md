[ReadtheDocs](https://cal-software-matlab.readthedocs.io/en/latest/sec_intro.html)


============
Introduction
============
.. highlight:: matlab

You have reached the documentation of the `CAL-software-Matlab`_ toolbox! Computed axial lithography (CAL) is a 3D printing process inspired by the tomographic principles of computed tomography (CT) scanning. It consists creating light intensity images with iterative optimization and projecting these with a DLP-type projector into a rotating vial of photocurable resin to acheive a prescribed dose in the shape of a target object. 

.. image:: docs/images/title.png
   :width: 1000




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



.. _`CAL-software-Matlab`: https://github.com/computed-axial-lithography/CAL-software-Matlab
.. _`release`: https://github.com/computed-axial-lithography/CAL-software-Matlab/releases


Background
----------

Detailed descriptions of the algorithms that support CAL and the 3D printing process itself can be found in the following papers:

* `[Kelly2019]`_
* `[Kelly2017arxiv]`_

.. _`[Kelly2019]`: https://science.sciencemag.org/content/363/6431/1075
.. _`[Kelly2017arxiv]`: https://arxiv.org/pdf/1705.05893.pdf

CAL is an volumetric additive manufacturing process that uses spatial light modulation and principles of tomographic reconstruction to 
build 3D objects. CAL or physical tomographic reconstruction works by illuminating a cylindrical container of resin with modulated 
patterns of light that are refreshed in sync with the rotation of the container. The superposition of the light dose from each azimuthal 
projection creates a 3D dose distribution that photopolymerizes the resin into the desired object.

This code package is provided to support the generation of the light projections and the control of a DLP projector through Matlab.
