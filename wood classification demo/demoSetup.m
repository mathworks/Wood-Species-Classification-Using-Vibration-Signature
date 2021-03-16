%demoSetup function clears and set everything up for the wood classification
%demo in MATLAB

% Copyright 2021 The MathWorks, Inc.

filePath = mfilename("fullpath");
changeDir = fileparts(filePath);

% Change to current directory
cd(changeDir)

% Turn all warnings off
warning('off')
clc
% Close all currently open scripts in the editor
allscripts = matlab.desktop.editor.getAll;
close(allscripts)

% Open demo scripts
edit('materialClassificationGui.m')
edit('plotDataAvailable.m')
edit('classifyMaterial.m')
edit('startDaq.m')
makeActive(matlab.desktop.editor.findOpenDocument('startDaq.m'))

