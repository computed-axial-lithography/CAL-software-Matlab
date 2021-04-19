% TODO: class with attributes - Serial num, Accn, maxvel, sense of direction
% This code is only compatible with Thorlabs motor stages which 
% comes with an APT controller MGMOTOR.MGMotorCtrl

% classdef Motor
% attributes
% h

% init
h = actxcontrol('MGMOTOR.MGMotorCtrl.1');
h.HWSerialNum = 55941090;
h.StartCtrl();
h.SetVelParams(0,0,24,24); %(IChanID,fMinVel, fAccn, fMaxVel)

% home
fprintf('\nHoming rotation stage\n')
h.MoveHome(0,true); %(IChanID, bWait)

% move
fprintf('\nMoving stage\n')
h.MoveVelocity(0,1); %(IChanID, sense of direction=forward)


% % prevpos = 0;
% % for i=1:1000
% %     currpos = h.GetPosition_Position(0);
% %     currpos - prevpos
% %     prevpos = currpos;
% % %     pause(0.001)
% % end

% Stop
h.StopImmediate(0); % Stop stage w/o ramping

% end
h.StopCtrl();
% del h