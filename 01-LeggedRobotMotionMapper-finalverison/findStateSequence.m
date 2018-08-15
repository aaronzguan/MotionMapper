function [stateSequence] = findStateSequence(embeddingValues,behaviorRegion)
%findStateSequence finds the state sequence from the 
%
%   Input variables:
%   
%       embeddingValues-> embedding results
%       behaviorRegion   -> the clusted and labeled embedding space 
% 
%   Output variables:
%
%       stateSequence -> state sequence of the trajetories on the embedding
%       space
%
% (C) Aaron Z Guan, 2018
%     Terradynamics Lab, JHU

addpath(genpath('./database/'));
addpath(genpath('./utilities/'));
addpath(genpath('./t_sne/'));
if(nargin<1)
    load('embeddingValues_V_noTrain_1200.mat','embeddingValues');
    load('behaviorRegion_Cluster.mat','behaviorRegion_Cluster')
end

maxVal = max(max(abs(combineCells(embeddingValues))));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40;
numPoints = 501;
rangeVals = [-maxVal maxVal];


%% Find the state sequence for all trials
state = {};
for i = 1 : length(embeddingValues)
    
    i
    
    for j = 1 : length(embeddingValues{i})
        [~,density_eachTrial] = findPointDensity(embeddingValues{i}(j,:),sigma,numPoints,rangeVals);
        maxDensity = max(density_eachTrial(:));
        [x,y] = find(density_eachTrial==maxDensity);
        stateSequence{i}(j) = behaviorRegion(x,y);    
    end
end