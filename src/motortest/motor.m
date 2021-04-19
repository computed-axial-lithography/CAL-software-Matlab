classdef motor < handle 
    % Matlab class to control Thorlabs motorised rotation stages
    % It is a 'wrapper' to control Thorlabs devices via the Thorlabs .NET
    % DLLs.
    %
    % Instructions:
    % Download the Kinesis DLLs from the Thorlabs website from:
    % https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control
    % Edit MOTORPATHDEFAULT below to point to the location of the DLLs
    % Connect your PRM1Z8 and/or K10CR1 rotation stage(s) to the PC USB port(if
    % using PRMZ8 also switch it on)
    %
    % Example:
    % a=motor.listdevices   % List connected devices
    % m1=motor              % Create a motor object  
    % connect(m1,a{1})      % Connect the first devce in the list of devices
    % home(m1)              % Home the device
    % moveto(m1,45)         % Move the device to the 45 degree setting
    % moverel_deviceunit(m1, -100000) % Move 100000 'clicks' backwards
    % disconnect(m1)        % Disconnect device
    %
    % Author: Julan A.J. Fells
    % Dept. Engineering Science, University of Oxford, Oxford OX1 3PJ, UK
    % Email: julian.fells@emg.ox.ac.uk (please email issues and bugs)
    % Website: http://wwww.eng.ox.ac.uk/smp
    %
    % Known Issues:
    % 1. If motor object gets deleted or corrupted it is sometimes necessary to
    % restart Matlab
    %
    % Version History:
    % 1.0 14 March 2018 First Release
    
    
    properties (Constant, Hidden)
       % path to DLL files (edit as appropriate)
       MOTORPATHDEFAULT='C:\Program Files\Thorlabs\Kinesis'

       % DLL files to be loaded
       DEVICEMANAGERDLL='Thorlabs.MotionControl.DeviceManagerCLI.dll';
       DEVICEMANAGERCLASSNAME='Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI'
       GENERICMOTORDLL='Thorlabs.MotionControl.GenericMotorCLI.dll';
       GENERICMOTORCLASSNAME='Thorlabs.MotionControl.GenericMotorCLI.GenericMotorCLI';
       DCSERVODLL='Thorlabs.MotionControl.KCube.DCServoCLI.dll';  
       DCSERVOCLASSNAME='Thorlabs.MotionControl.KCube.DCServoCLI.KCubeDCServo';            
       INTEGSTEPDLL='Thorlabs.MotionControl.IntegratedStepperMotorsCLI.dll' 
       INTEGSTEPCLASSNAME='Thorlabs.MotionControl.IntegratedStepperMotorsCLI.IntegratedStepperMotor.CageRotator';

       % Default intitial parameters 
       DEFAULTVEL=10;           % Default velocity
       DEFAULTACC=10;           % Default acceleration
       TPOLLING=250;            % Default polling time
       TIMEOUTSETTINGS=7000;    % Default timeout time for settings change
       TIMEOUTMOVE=100000;      % Default time out time for motor move
    end
    properties 
       % These properties are within Matlab wrapper 
       isconnected=false;           % Flag set if device connected
       serialnumber;                % Device serial number
       controllername;              % Controller Name
       controllerdescription        % Controller Description
       stagename;                   % Stage Name
       position;                    % Position
       acceleration;                % Acceleration
       maxvelocity;                 % Maximum velocity limit
       minvelocity;                 % Minimum velocity limit
    end
    properties (Hidden)
       % These are properties within the .NET environment. 
       deviceNET;                   % Device object within .NET
       motorSettingsNET;            % motorSettings within .NET
       currentDeviceSettingsNET;    % currentDeviceSetings within .NET
       deviceInfoNET;               % deviceInfo within .NET
    end
    methods
        function h=motor()  % Instantiate motor object
            motor.loaddlls; % Load DLLs (if not already loaded)
        end
        function connect(h,serialNo)  % Connect device
            h.listdevices();    % Use this call to build a device list in case not invoked beforehand
            if ~h.isconnected
                switch(serialNo(1:2))
                    case '27'   % Serial number corresponds to a PRM1Z8
                        h.deviceNET=Thorlabs.MotionControl.KCube.DCServoCLI.KCubeDCServo.CreateKCubeDCServo(serialNo);   
                    case '55'   % Serial number corresponds to a K10CR1 
                        h.deviceNET=Thorlabs.MotionControl.IntegratedStepperMotorsCLI.CageRotator.CreateCageRotator(serialNo);
                    otherwise % Serial number is not a PRM1Z8 or a K10CR1
                        error('Stage not recognised');
                end     
                h.deviceNET.ClearDeviceExceptions();    % Clear device exceptions via .NET interface
                h.deviceNET.Connect(serialNo);          % Connect to device via .NET interface
                try
                    if ~h.deviceNET.IsSettingsInitialized() % Wait for IsSettingsInitialized via .NET interface
                        h.deviceNET.WaitForSettingsInitialized(h.TIMEOUTSETTINGS);
                    end
                    if ~h.deviceNET.IsSettingsInitialized() % Cannot initialise device
                        error(['Unable to initialise device ',char(serialNo)]);
                    end
                    h.deviceNET.StartPolling(h.TPOLLING);   % Start polling via .NET interface
                    h.motorSettingsNET=h.deviceNET.LoadMotorConfiguration(serialNo); % Get motorSettings via .NET interface
                    h.currentDeviceSettingsNET=h.deviceNET.MotorDeviceSettings;     % Get currentDeviceSettings via .NET interface
                    h.deviceInfoNET=h.deviceNET.GetDeviceInfo();                    % Get deviceInfo via .NET interface
%                     MotDir=Thorlabs.MotionControl.GenericMotorCLI.Settings.RotationDirections.Forwards; % MotDir is enumeration for 'forwards'
%                     h.currentDeviceSettingsNET.Rotation.RotationDirection=MotDir;   % Set motor direction to be 'forwards#
                catch % Cannot initialise device
                    error(['Unable to initialise device ',char(serialNo)]);
                end
            else % Device is already connected
                error('Device is already connected.')
            end
            updatestatus(h);   % Update status variables from device
        end
        function disconnect(h) % Disconnect device     
            h.isconnected=h.deviceNET.IsConnected(); % Update isconnected flag via .NET interface
            if h.isconnected
                try
                    h.deviceNET.StopPolling();  % Stop polling device via .NET interface
                    h.deviceNET.Disconnect();   % Disconnect device via .NET interface
                catch
                    error(['Unable to disconnect device',h.serialnumber]);
                end
                h.isconnected=false;  % Update internal flag to say device is no longer connected
            else % Cannot disconnect because device not connected
                error('Device not connected.')
            end    
        end
        function reset(h,serialNo)    % Reset device
            h.deviceNET.ClearDeviceExceptions();  % Clear exceptions vua .NET interface
            h.deviceNET.ResetConnection(serialNo) % Reset connection via .NET interface
        end
        function home(h)              % Home device (must be done before any device move
            workDone=h.deviceNET.InitializeWaitHandler();     % Initialise Waithandler for timeout
            h.deviceNET.Home(workDone);                       % Home devce via .NET interface
            h.deviceNET.Wait(h.TIMEOUTMOVE);                  % Wait for move to finish
            updatestatus(h);            % Update status variables from device
        end
        function moveto(h,position)     % Move to absolute position
            try
                workDone=h.deviceNET.InitializeWaitHandler(); % Initialise Waithandler for timeout
                h.deviceNET.MoveTo(position, workDone);       % Move devce to position via .NET interface
                h.deviceNET.Wait(h.TIMEOUTMOVE);              % Wait for move to finish
                updatestatus(h);        % Update status variables from device
            catch % Device faile to move
                error(['Unable to Move device ',h.serialnumber,' to ',num2str(position)]);
            end
        end
        function moverel_deviceunit(h, noclicks)  % Move relative by a number of device clicks (noclicks)
            if noclicks<0   % if noclicks is negative, move device in backwards direction
                motordirection=Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Backward;
                noclicks=abs(noclicks);
            else            % if noclicks is positive, move device in forwards direction
                motordirection=Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Forward;
            end             % Perform relative device move via .NET interface
            h.deviceNET.MoveRelative_DeviceUnit(motordirection,noclicks,h.TIMEOUTMOVE);
            updatestatus(h);            % Update status variables from device
        end      
        function movecont(h, varargin)  % Set motor to move continuously
            if (nargin>1) && (varargin{1})      % if parameter given (e.g. 1) move backwards
                motordirection=Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Backward;
            else                                % if no parametr given move forwards
                motordirection=Thorlabs.MotionControl.GenericMotorCLI.MotorDirection.Forward;
            end
            h.deviceNET.MoveContinuous(motordirection); % Set motor into continous move via .NET interface
            updatestatus(h);            % Update status variables from device
        end
        function stop(h) % Stop the motor moving (needed if set motor to continous)
            h.deviceNET.Stop(h.TIMEOUTMOVE); % Stop motor movement via.NET interface
            updatestatus(h);            % Update status variables from device
        end
        
        function [enc_position] = read_position(h) % Poll the device to get current position
            h.position=System.Decimal.ToDouble(h.deviceNET.Position);   % Read current device position
            enc_position = h.position;
        end
        
        function updatestatus(h) % Update recorded device parameters in matlab by reading them from the devuce
            h.isconnected=boolean(h.deviceNET.IsConnected());   % update isconncted flag
            h.serialnumber=char(h.deviceNET.DeviceID);          % update serial number
            h.controllername=char(h.deviceInfoNET.Name);        % update controleller name          
            h.controllerdescription=char(h.deviceInfoNET.Description);  % update controller description
            h.stagename=char(h.motorSettingsNET.DeviceSettingsName);    % update stagename
            velocityparams=h.deviceNET.GetVelocityParams();             % update velocity parameter
            h.acceleration=System.Decimal.ToDouble(velocityparams.Acceleration); % update acceleration parameter
            h.maxvelocity=System.Decimal.ToDouble(velocityparams.MaxVelocity);   % update max velocit parameter
            h.minvelocity=System.Decimal.ToDouble(velocityparams.MinVelocity);   % update Min velocity parameter
            h.position=System.Decimal.ToDouble(h.deviceNET.Position);   % Read current device position
        end
        function setvelocity(h, varargin)  % Set velocity and acceleration parameters
            velpars=h.deviceNET.GetVelocityParams(); % Get existing velocity and acceleration parameters
            switch(nargin)
                case 1  % If no parameters specified, set both velocity and acceleration to default values
                    velpars.MaxVelocity=h.DEFAULTVEL;
                    velpars.Acceleration=h.DEFAULTACC;
                case 2  % If just one parameter, set the velocity  
                    velpars.MaxVelocity=varargin{1};
                case 3  % If two parameters, set both velocitu and acceleration
                    velpars.MaxVelocity=varargin{1};  % Set velocity parameter via .NET interface
                    velpars.Acceleration=varargin{2}; % Set acceleration parameter via .NET interface
            end
            if System.Decimal.ToDouble(velpars.MaxVelocity)>25  % Allow velocity to be outside range, but issue warning
                warning('Velocity >25 deg/sec outside specification')
            end
            if System.Decimal.ToDouble(velpars.Acceleration)>25 % Allow acceleration to be outside range, but issue warning
                warning('Acceleration >25 deg/sec2 outside specification')
            end
            h.deviceNET.SetVelocityParams(velpars); % Set velocity and acceleration paraneters via .NET interface
            updatestatus(h);        % Update status variables from device
        end
            
    end
    methods (Static)
        function serialNumbers=listdevices()  % Read a list of serial number of connected devices
            motor.loaddlls; % Load DLLs
            Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.BuildDeviceList();  % Build device list
            serialNumbersNet = Thorlabs.MotionControl.DeviceManagerCLI.DeviceManagerCLI.GetDeviceList(); % Get device list
            serialNumbers=cell(ToArray(serialNumbersNet)); % Convert serial numbers to cell array
        end
        function loaddlls() % Load DLLs
            if ~exist(motor.DEVICEMANAGERCLASSNAME,'class')
                try   % Load in DLLs if not already loaded
%                     NET.addAssembly([motor.MOTORPATHDEFAULT,motor.DEVICEMANAGERDLL]);
%                     NET.addAssembly([motor.MOTORPATHDEFAULT,motor.GENERICMOTORDLL]);
%                     NET.addAssembly([motor.MOTORPATHDEFAULT,motor.DCSERVODLL]); 
%                     NET.addAssembly([motor.MOTORPATHDEFAULT,motor.INTEGSTEPDLL]); 

                    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
                    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
                    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');
                    NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.IntegratedStepperMotorsCLI.dll');
                catch % DLLs did not load
                    error('Unable to load .NET assemblies')
                end
            end    
        end 
    end
end