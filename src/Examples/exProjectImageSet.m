cd ..;
addpath('Examples')

% set the rotation velocity in deg/s
rot_vel = 24;

% initialize the CALProjectImageSet class
DLP = CALProjectImageSet(image_set_obj,24);

% begin projecting images
DLP.startProjecting(); 




% % set the rotation velocity in deg/s
% rot_vel = 24;
% 
% % set the monitor ID
% monitor_id = 3
% 
% % initialize the CALProjectImageSet class
% DLP = CALProjectImageSet(image_set_obj,24,monitor_id,0); % Note: 0 sets blank_when_paused to deactivated
% 
% % begin projecting images
% DLP.startProjecting(); 


cd 'Examples';