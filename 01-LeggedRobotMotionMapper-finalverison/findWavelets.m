function [amplitudes,f] = findWavelets(timesSeries,numDims,parameters)
%findWavelets finds the wavelet transforms resulting from 3D-kinematic time series
%
%   Input variables:
%   
%       TimesSeries->  N(time) x d(dimension) array/time series
%       numDims   -> # of transforms to find, now we have 3 dims- RPY
%       parameters -> struct containing non-default choices for parameters
% 
%   Output variables:
%
%       amplitudes -> wavelet amplitudes (N x (numModes*numPeriods) ) 
%       f -> frequencies used in wavelet transforms (Hz)
%


    if nargin < 3 % the number of argument/function input       
        parameters = [];
    end
    parameters = setRunParameters(parameters);
    
    setup_parpool(parameters.numProcessors)

    omega0 = parameters.omega0;         % omega0: 5;
    numPeriods = parameters.numPeriods; % number of wavelet frequencies to use: 30
    dt = 1 ./ parameters.samplingFreq;  % sampling frequency (Hz): 76.8;
    minT = 1 ./ parameters.maxF;
    maxT = 1 ./ parameters.minF;
    Ts = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
    f = fliplr(1./Ts);                  % The range of the frequency 
    
    
    L = length(timesSeries(1,:));       % number of modes
    if nargin < 2 || isempty(numDims)
        numDims = L;
    else
        if numDims > L
            numDims = L;
        end
    end
    
    N = length(timesSeries(:,1));       % Time
    amplitudes = zeros(N,numDims*numPeriods); %zeros(50, 3*30)
    for i=1:numDims
        amplitudes(:,(1:numPeriods)+(i-1)*numPeriods) = ...
            fastWavelet_morlet_convolution_parallel(...
            timesSeries(:,i),f,omega0,dt)'; 
    end
    
    if parameters.numProcessors > 1 && parameters.closeMatPool
        close_parpool
    end
    
    
    
    
    