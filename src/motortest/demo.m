%Example for programming the Thorlabs KDC101 with Kinesis in MATLAB, with PRM1-Z8 stage.

%Load assemblies
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.DeviceManagerCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.GenericMotorCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.DCServoCLI.dll');
NET.addAssembly('C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.IntegratedStepperMotorsCLI.dll');

%Initialize Device List
import Thorlabs.MotionControl.DeviceManagerCLI.*
import Thorlabs.MotionControl.GenericMotorCLI.*
import Thorlabs.MotionControl.KCube.DCServoCLI.*
import Thorlabs.MotionControl.IntegratedStepperMotors.*

%Initialize Device List
DeviceManagerCLI.BuildDeviceList();
DeviceManagerCLI.GetDeviceListSize();

%Should change the serial number below to the one being used.
serial_num='55941090';
timeout_val=60000;

%Set up device and configuration
device = Thorlabs.MotionControl.IntegratedStepperMotorsCLI.CageRotator.CreateCageRotator(serial_num);
device.Connect(serial_num);
device.WaitForSettingsInitialized(5000);

% configure the stage
motorSettings = device.LoadMotorConfiguration(serial_num);
motorSettings.DeviceSettingsName = 'PRM1-Z8';
% update the RealToDeviceUnit converter
motorSettings.UpdateCurrentConfiguration();

% push the settings down to the device
MotorDeviceSettings = device.MotorDeviceSettings;
device.SetSettings(MotorDeviceSettings, true, false);

device.StartPolling(250);

pause(1); %wait to make sure device is enabled

% %Home
% device.Home(timeout_val);
% fprintf('Motor homed.\n');

%Move to unit 100
device.MoveTo(100, timeout_val);

%Check Position
pos = System.Decimal.ToDouble(device.Position);
fprintf('The motor position is %d.\n',pos);

device.StopPolling()
device.Disconnect()