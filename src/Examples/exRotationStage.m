cd ..;
addpath('Examples')


clear all
close all

% set the rotation velocity in deg/s
rot_vel = 24;

% set the rotation stage serial number
MotorSerialNum = 12345678;

% set the position of the rotation stage to start projection
Start_Pos = 90;

% initialize the CALProjectImageSet class
DLP = CALProjectImageSet(image_set_obj,rot_vel);

% initialize the rotation stage
DLP = DLP.motorInit(MotorSerialNum,Start_Pos);

% begin projecting images
DLP.startProjecting();