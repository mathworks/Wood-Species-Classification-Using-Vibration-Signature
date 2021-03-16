function [classProb, A] = classifyMaterial(inputSignal)
%classifyMaterial loads the trained network, computes real time
%cwt transform, converts it to an image and predicts the classified output.

% Copyright 2021 The MathWorks, Inc.

persistent hh;
inputSignal = inputSignal';
persistent trainedNet;

% Check if trainedNet is empty
if isempty(trainedNet)
    trainedNet = load('trainedNet.mat');
    hh = 0;
end

if ~isfolder('liveImages')
    mkdir('liveImages')
end

% Compute the signalLength
signalLength = numel(inputSignal);

% Save the input image size in variable "imgSize"
imgSize = [227 227];
imageRoot = fullfile(pwd, 'liveImages');

% Compute the cwt transform
fb = cwtfilterbank('SignalLength', signalLength, 'SamplingFrequency', 51200, 'VoicesPerOctave', 48);
[wt, ~] = fb.wt(inputSignal);

% Convert the complex wavelet transform to an uint8 RGB image
wtAbs = abs(wt);
im = ind2rgb(im2uint8(rescale(wtAbs)), jet(256));
imFileName = "Image"+ "_" + hh + ".jpg";
imwrite(imresize(im, [224 224]), char(fullfile(imageRoot,imFileName)));
A = imread(char(fullfile(imageRoot,imFileName)));
imR = imresize(A, imgSize);
hh = hh + 1;

% Run the classify function of the network on the resized image
classProb = classify(trainedNet.woodNet, imR);
end
