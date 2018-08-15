function [amplitudes,f] = findWavelets(projections,numModes,parameters)
%findWavelets finds the wavelet transforms resulting from a time series
%
%   Input variables:
%
%       projections -> N x d array of projection values N: total time
%       numModes -> # of transforms to find
%       parameters -> struct containing non-default choices for parameters
%
%
%   Output variables:
%
%       amplitudes -> wavelet amplitudes (N x (pcaModes*numPeriods) )
%       f -> frequencies used in wavelet transforms (Hz)
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University


%findWavelets finds the wavelet transforms resulting from 3D-kinematic time series
%
%   Input variables:
%   
%       3-d kinematic data
%
    
    if nargin < 3 % the number of argument/function input
        parameters = [];
    end
    parameters = setRunParameters(parameters);
    
    
    L = length(projections(1,:)); % length: the row of projections
    % let the number of modes equal the length of projections
    if nargin < 2 || isempty(numModes)
        numModes = L;
    else
        if numModes > L
            numModes = L;
        end
    end
    
    
    setup_parpool(parameters.numProcessors)

    
    
    omega0 = parameters.omega0;
    numPeriods = parameters.numPeriods; %number of wavelet frequencies to use
    dt = 1 ./ parameters.samplingFreq;  %sampling frequency (Hz)
    minT = 1 ./ parameters.maxF;
    maxT = 1 ./ parameters.minF;
    Ts = minT.*2.^((0:numPeriods-1).*log(maxT/minT)/(log(2)*(numPeriods-1)));
    f = fliplr(1./Ts); % The range of the frequency 
    
    
    N = length(projections(:,1)); % the column of projections, total time
    amplitudes = zeros(N,numModes*numPeriods); %zeros(50, 1250)
    for i=1:numModes
        amplitudes(:,(1:numPeriods)+(i-1)*numPeriods) = ...
            fastWavelet_morlet_convolution_parallel(...
            projections(:,i),f,omega0,dt)';
    end
    
    
    if parameters.numProcessors > 1 && parameters.closeMatPool
        close_parpool
    end
    
    
    
    
    