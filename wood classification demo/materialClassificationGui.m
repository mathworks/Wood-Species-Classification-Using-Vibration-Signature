function hGui = materialClassificationGui(s)
%materialClassificationGui Creates a graphical user interface to display data capture.
%hGui = materialClassificationGui(s) and creates a graphical user interface, by
%programmatically creating a figure and adding required graphics
%components for visualization of data acquired from a data acquisition
%object (s).

% Copyright 2021 The MathWorks, Inc.

% Create a figure and configure a callback function (executes on window close)
hGui.Fig = figure('Name','Material Classification', ...
    'NumberTitle', 'off', 'Resize', 'off', ...
    'Toolbar', 'None', 'Menu', 'None',...
    'Position', [100 50 870 600]);
hGui.Fig.DeleteFcn = {@endDAQ, s};
uiBackgroundColor = hGui.Fig.Color;

% Initialize the subplots
pos1 = [0.050 0.5 0.42 0.42];
hGui.Axes1 = subplot('Position',pos1);
title("Predicted Class: N/A");

pos2 = [0.53 0.5 0.42 0.42];
hGui.Axes2 = subplot('Position',pos2);
title("N/A");

pos3 = [0.1 0.1 0.3 0.3];
hGui.Axes3 = subplot('Position',pos3);

pos4 = [0.58 0.1 0.3 0.3];
hGui.Axes4 = subplot('Position',pos4);

% Create a stop acquisition button and configure a callback function
hGui.DAQButton = uicontrol('style', 'pushbutton', 'string', 'Stop DAQ',...
    'units', 'pixels', 'position', [780 5 81 38]);
hGui.DAQButton.Callback = {@endDAQ, s};

hGui.txtTrigLevel = uicontrol('Style', 'text', 'String', 'Trigger Level (N)', ...
    'Position', [5 5 90 19], 'HorizontalAlignment', 'left', ...
    'BackgroundColor', uiBackgroundColor);
hGui.TrigLevel = uicontrol('style', 'edit', 'string', '5',...
    'units', 'pixels', 'position', [105 5 56 24]);
set(hGui.txtTrigLevel,'Visible','Off')
set(hGui.TrigLevel,'Visible','Off')

% Stop DAQ callback
    function endDAQ(~, ~, s)
        if isvalid(s)
            if s.Running
                stop(s);
            end
        end
        clear classifyMaterial;
    end

end
