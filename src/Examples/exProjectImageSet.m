cd ..;
addpath('Examples')

% set the rotation velocity in deg/s
rot_vel = 24;

% initialize the CALProjectImageSet class, this basic example assumes the projector is connected
% to the highest monitor number (e.g. if there are 2 monitors, it assumes projector is connected to 
% monitor #2)
DLP = CALProjectImageSet(image_set_obj,rot_vel);

% begin projecting images
DLP.startProjecting(); 




% % set the rotation velocity in deg/s
% rot_vel = 24;
% 
% % set the monitor ID
% monitor_id = 3
% 
% % set whether the screen projects a black screen when projection is paused
% blank_when_paused = 1;
% 
% % initialize the CALProjectImageSet class
% DLP = CALProjectImageSet(image_set_obj,rot_vel,monitor_id,blank_when_paused);
% 
% % begin projecting images
% DLP.startProjecting(); 


cd 'Examples';