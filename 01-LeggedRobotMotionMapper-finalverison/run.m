clear
close all

addpath(genpath('./wavelet/'));
addpath(genpath('./utilities/'));
addpath(genpath('./t_sne/'));
addpath(genpath('./database/'));

save_path = 'D:\MotionMapper\LeggedRobotMotionMapper\results';
if ~exist(save_path,'dir')
    mkdir(save_path);
end

% define any desired parameter changes here
parameters.numProcessors = 2; 
parameters = setRunParameters(parameters);
numDims = parameters.numDims; % the number of dimenstion of input data

% run the dataProcess first to get the dataset
load('dataBeamRobot.mat');
position = true;
orientation = true;
velocity = true;
RobData = dataProcess(robotData,shellTagID,position,orientation,velocity);
L = length(RobData);

%% Caculte wavelet for time series
amp=cell(L,1);
for i = 1 : L
    fprintf(1,'\t Calculating Wavelets for trial #%4i out of %4i\n',i,L);
    [amp{i},~] = findWavelets(RobData{i},numDims,parameters);
end
data = combineCells(amp);
vals = sum(data,2);
data(:) = bsxfun(@rdivide,data,vals); % Normalize

%% Find embedding onto 2D by t-SNE
fprintf(1,'Finding t-SNE Embedding for the data\n');
embedding = run_tSne(data,parameters);

%% Make embedding plot
embeddingAll = figure;
scatter(embedding(:,1),embedding(:,2),[],vals,'filled');
colormap(fire)
h = colorbar;
ylabel(h, 'amplitude','FontSize', 15,'fontweight','bold');

%% Make density plot
[embeddingValues] = groupCells(embedding,RobData);
[PDFAll,PDFStiffness,PDFTrial,PDFWatershed] = ...
    findEmbeddingDensity(embeddingValues);

%% Make trajectories on the embedding space
save_path = [save_path '\dynamics'];
plotDynamicsEmbedding(embeddingValues,save_path)

%% Plot transition flux
findTransitionFlux(embeddingValues)

%% Save images
saveas(PDFAll,fullfile(save_path,'PDF_all'),'jpg');
saveas(PDFStiffness,fullfile(save_path,'PDF_stiffness'),'jpg');
saveas(PDFTrial,fullfile(save_path,'PDF_individual'),'jpg');
saveas(PDFWatershed,fullfile(save_path,'PDF_Watershed'),'jpg');
saveas(embeddingAll,fullfile(save_path,'Embedding'),'jpg');

close_parpool
