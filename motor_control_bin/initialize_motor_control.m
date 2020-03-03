function initialize_motor_control(vel,acc)
    a = motor.listdevices;   % List connected devices
    m1 = motor;              % Create a motor object
    
    fprintf('\nConnecting to rotation stage\n');
    connect(m1,a{1})      % Connect the first devce in the list of devices
    fprintf('\nSuccessfully connected\n');
    
    setvelocity(m1,vel,acc)
    
    fprintf('\nHoming rotation stage\n')
    home(m1)              % Home the device
    
    movecont(m1)

%     moverel_deviceunit(m1, -100000) % Move 100000 'clicks' backwards
%     disconnect(m1)        % Disconnect device