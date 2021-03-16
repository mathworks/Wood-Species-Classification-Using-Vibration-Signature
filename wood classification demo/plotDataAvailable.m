function plotDataAvailable(src, ~, hGui)
%plotDataAvailable function reads in data from NI 9234, extracts pre-
%defined samples, calls classification function and plots the GUI

% Copyright 2021 The MathWorks, Inc.

global sigBuffer1 sigBuffer2 nxtBufferCnt finalTrigIndex trigData1 trigData2 triggerThreshold mEbony hMaple bWood;

% Declaring variables for analyzing modalfrf(optional)  
%global fs frf f 

% Read data from NI DAQ 9234
[x, eventTimestamps] = read(src, src.ScansAvailableFcnCount, "OutputFormat", "Matrix");

% Impact hammer(channel 1) data
x1 = x(:,1);

%% Find the max value in each column of the channels

% Accelerometers are connected to ch2, ch3 and ch4 of NI USB 9234
dataChannels = x(:,2:4);
actChannel = max(dataChannels,[],1);
[~,idx] = max(actChannel);
x2 = x(:,idx+1);
%%
if eventTimestamps(1)==0
    %frf = 0;
    %f = 0;
    nxtBufferCnt = 0;
    trigData1 = zeros(1024,1);
    trigData2 = zeros(1024,1);
    mEbony = imread('mexicanEbony.jpg');
    hMaple = imread('hardMaple.jpg');
    bWood = imread('bloodWood.jpg');
    triggerThreshold = 25;
end

% FIFO for channel 1
sigBuffer1(1:end-numel(x1)) = sigBuffer1(numel(x1)+1:end);
sigBuffer1(end-numel(x1)+1:end) = x1;

% FIFO for channel 2
sigBuffer2(1:end-numel(x2)) = sigBuffer2(numel(x2)+1:end);
sigBuffer2(end-numel(x2)+1:end) = x2;

if(nxtBufferCnt == 1)
    %disp('Inside next buffer cntr condition as the prev buffer was in the last 1000 data samples');
    finalTrigIndex = finalTrigIndex - numel(x1);
    
    % Extract 1024 samples
    trigData1 = sigBuffer1(finalTrigIndex - 100: finalTrigIndex + 923);
    trigData2 = sigBuffer2(finalTrigIndex - 100: finalTrigIndex + 923);
    
    % Set nxtBufferCnt as zero
    nxtBufferCnt = 0;
end

% Get the trigger configuration parameters from UI text input(trigconfig level is fixed to 5N and hidden)
trigConfig.Level = sscanf(hGui.TrigLevel.String, '%f');

% Check for trigger threshold
if( any(x1 > trigConfig.Level) )
    %disp("Inside trigger Condition!")
    if(any(x1 > triggerThreshold))
        errordlg('Impact cannot be greater than 25 Newton','Error Occured');
        return
    end
    
    % Find first index of channel 1 which is above the threshold
    trigIndex = find((x1 > trigConfig.Level),1,'first');
    
    % Final trigger index is the trigIndex in x1 plus length of sigBuffer - length of x1
    finalTrigIndex = trigIndex + numel(sigBuffer1) - numel(x1);
    
    if( finalTrigIndex + 923 > numel(sigBuffer1) )
        %disp("Trigger index is in last 1000 data samples");
        nxtBufferCnt = 1;
        
    else
        % Capture channel 1 and channel 2 samples before and after trigger
        % If 1024 samples required
        trigData1 = sigBuffer1(finalTrigIndex - 100: finalTrigIndex + 923);
        trigData2 = sigBuffer2(finalTrigIndex - 100: finalTrigIndex + 923);
        
        % Modal frf (optional)
        %winlen = size(trigData2,1);
        %[frf, f] = modalfrf(trigData1(:), trigData2(:), fs, hann(winlen), 'Sensor', 'acc');
    end
    % Call classifyMaterial function to predict wood type
   [classProb, A] = classifyMaterial(trigData2);
    
    % Plot classified wood image
    if (classProb == "Mexican Ebony")
        pos1 = [0.050 0.5 0.42 0.42];
        hGui.Axes1 = subplot('Position',pos1);
        imagesc(hGui.Axes1, mEbony);
        axis off;
        title("Predicted Class: Mexican Ebony");
    elseif (classProb == "Hard Maple")
        pos1 = [0.050 0.5 0.42 0.42];
        hGui.Axes1 = subplot('Position',pos1);
        imagesc(hGui.Axes1, hMaple);
        axis off;
        title("Predicted Class: Hard Maple");
    elseif (classProb == "Bloodwood")
        pos1 = [0.050 0.5 0.42 0.42];
        hGui.Axes1 = subplot('Position',pos1);
        imagesc(hGui.Axes1, bWood);
        axis off;
        title("Predicted Class: Bloodwood");
    end
    
    % Plot CWT image
    pos2 = [0.53 0.5 0.42 0.42];
    hGui.Axes2 = subplot('Position',pos2);
    imagesc(hGui.Axes2, A);
    axis off;
    title("Continuous Wavelet Transform Image");
end

% Plot impact hammer data
pos3 = [0.1 0.1 0.3 0.3];
hGui.Axes3 = subplot('Position',pos3);
plot(hGui.Axes3, trigData1)
title(hGui.Axes3,'Impact Hammer Data','HandleVisibility','off');
ylabel('Force (Newton)','HandleVisibility','off');
xlabel('Data samples','HandleVisibility','off');

% Plot accelerometer data
pos4 = [0.58 0.1 0.3 0.3];
hGui.Axes4 = subplot('Position',pos4);
plot(hGui.Axes4, trigData2)
title(hGui.Axes4,'Accelerometer Data','HandleVisibility','off');
ylabel('Acceleration (g)','HandleVisibility','off');
xlabel('Data samples','HandleVisibility','off');

end