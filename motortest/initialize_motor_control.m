% function initialize_motor_control(vel,acc)
vel =24;
acc = 24;
a = motor.listdevices;   % List connected devices
m1 = motor;              % Create a motor object

fprintf('\nConnecting to rotation stage\n');
connect(m1,a{1})      % Connect the first devce in the list of devices
fprintf('\nSuccessfully connected\n');

setvelocity(m1,vel,acc)

fprintf('\nHoming rotation stage\n')
home(m1)              % Home the device

movecont(m1);

for i=1:10000
    currpos = read_position(m1)
    pause(0.01)
end
% for i=1:10
%     initpos = read_position(m1);
%     movecont(m1);
%     starttime = tic;
%     while read_position(m1) ~= initpos
%         currtime = toc(starttime);
%     end
%     startuptime = toc(starttime)
%     stop(m1);
%     pause(1);
% end

% prevpos=0;
% for i=1:10
%     starttime = tic;
%     pos = read_position(m1);
%     diff = pos - prevpos
%     prevpos = pos;
%     currtime = toc(starttime);
%     while currtime < 0.5
%         currtime = toc(starttime);
%     end
% end

stop(m1)
disconnect(m1)

%     moverel_deviceunit(m1, -100000) % Move 100000 'clicks' backwards
%     disconnect(m1)        % Disconnect device