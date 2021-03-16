function startDaq
%startDaq is the main function which calls other data acquisition, gui and
%classification functions

% Copyright 2021 The MathWorks, Inc.

close all;

% Create a DAQ session
s = daq("ni");
d = daqlist("ni");
id9234 = contains(d.Model,"9234");

% Extract the device ID
deviceId = d.DeviceID(id9234);
deviceId = deviceId(1);

% Add input channels
ch1 = addinput(s, deviceId, "ai0", "Accelerometer");
ch2 = addinput(s, deviceId, "ai1", "Accelerometer");
ch3 = addinput(s, deviceId, "ai2", "Accelerometer");
ch4 = addinput(s, deviceId, "ai3", "Accelerometer");

global sigBuffer1 sigBuffer2 fs Data;
if isfolder('liveImages')
delete('liveImages\*.jpg');
end

% Set acquisition rate, in scans/second
fs = 51200;
s.Rate = fs;
sigBuffer1 = zeros([fs,1]);
sigBuffer2 = zeros([fs,1]);
Data = {zeros(1, 1024)};

% ch1 - impact hammer sensitivity - 9.314 mV/lb or 2.094 mV/N
% ch2, ch3, ch4 - accelerometers 352c65 
ch1.Sensitivity = 0.002094; 
ch2.Sensitivity = 0.1001;  % model 74
ch3.Sensitivity = 0.1019;  % model 73
ch4.Sensitivity = 0.1031;  % model 75

% Set scan rate
s.ScansAvailableFcnCount = 25600;

% Display data acquisition Gui
hGui = materialClassificationGui(s);

% Configure a ScansAvailableFcn callback function
s.ScansAvailableFcn = @(src,event) plotDataAvailable(src, event, hGui);

% Configure a ErrorOccurredFcn callback function for acquisition error
% events which might occur during background acquisition
s.ErrorOccurredFcn = @(src,event) disp(getReport(event.Error));

% Start continuous background data acquisition
start(s, 'continuous')

% Wait until data acquisition object is stopped from the UI
while s.Running
    pause(0.001)
    drawnow
end

% Disconnect from hardware
delete(s)
end