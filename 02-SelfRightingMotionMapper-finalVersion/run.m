%%script that will run the code for a set of .avi files that are found in filePath

clc
clear
close all
%Place path to folder containing example .avi files here
filePath = 'D:\MotionMapper\selfRighting';

%add utilities folder to path 
addpath(genpath('./utilities/'));
addpath(genpath('./PCA/'));
addpath(genpath('./segmentation_alignment/'));
addpath(genpath('./t_sne/'));
addpath(genpath('./wavelet/'));

%find all avi files in 'filePath'
videoFiles = findAllVideosInFolders(filePath,'.avi');
L = length(videoFiles);
numZeros = ceil(log10(L+1e-10));

%define any desired parameter changes here
parameters.samplingFreq = 100;
parameters.trainingSetSize = 5000;
%initialize parameters
parameters = setRunParameters(parameters);

firstFrame = 1;
lastFrame = [];

%% Run preprocessing for all videos
% creating preporcessing directory
processedDirectory = [filePath '/preprocess/'];
if ~exist(processedDirectory,'dir')
    mkdir(processedDirectory);
end

fprintf(1,'Processing videos\n');
processedVideos = cell(L,1);
crop = true;
register = true;
for ii=1:L    
    fprintf(1,'\t Processing video #%4i out of %4i\n',ii,L);
    [~,fileName,~] = fileparts(videoFiles{ii});
    processedVideos{ii} = [processedDirectory 'Processed_' fileName '.avi'];
    runPreprocess(videoFiles{ii},processedVideos{ii},crop,register,parameters);
end

%% Find image subset statistics (a gui will pop-up here)
fprintf(1,'Finding Subset Statistics\n');
numToTest = parameters.pca_batchSize;
[pixels,thetas,means,stDevs,vidObjs] = findRadonPixels(processedDirectory,numToTest,parameters);


%% Find postural eigenmodes
fprintf(1,'Finding Postural Eigenmodes\n');
[vecs,vals,meanValues] = findPosturalEigenmodes(vidObjs,pixels,parameters);

vecs = vecs(:,1:parameters.numProjections);

% figure
% [r,c] = size(means);
% makeMultiComponentPlot_radon_fromVecs(vecs(:,1:25),25,thetas,pixels,[r c]);
% caxis([-3e-3 3e-3])
% colorbar
% colormap(gray)
% title('First 25 Postural Eigenmodes','fontsize',14,'fontweight','bold');
% drawnow;


%% Find projections for each data set
projectionsDirectory = [filePath '/projections/'];
if ~exist(projectionsDirectory,'dir')
    mkdir(projectionsDirectory);
end

fprintf(1,'Finding Projections\n');
for i=1:L
    
    fprintf(1,'\t Finding Projections for File #%4i out of %4i\n',i,L);

    projections = findProjections(processedVideos{i},vecs,meanValues,pixels,parameters); 
    
    fileNum = [repmat('0',1,numZeros-length(num2str(i))) num2str(i)];
    [~,fileName,~] = fileparts(videoFiles{i}); 
    save([projectionsDirectory 'projections_' fileName '.mat'],'projections','fileName');
    projectionFiles{i} = projections;
    clear projections
    clear fileNum
    clear fileName 
    
end

%% Use subsampled t-SNE to find training set 
fprintf(1,'Finding Training Set\n');
[trainingSetData,trainingSetAmps] = ...
    runEmbeddingSubSampling(projectionsDirectory,parameters);

%% Run t-SNE on time series
fprintf(1,'Finding t-SNE Embedding for the Training Set\n');
[trainingEmbedding,betas,P,errors] = run_tSne(trainingSetData,parameters);

%% Find Embeddings for each file
fprintf(1,'Finding t-SNE Embedding for each file\n');
embeddingValues = cell(L,1);
for i=1:L
    fprintf(1,'\t Finding Embbeddings for File #%4i out of %4i\n',i,L);
    projections = projectionFiles{i};
    projections = projections(:,1:parameters.pcaModes);
    [embeddingValues{i},~] = ...
        findEmbeddings(projections,trainingSetData,trainingEmbedding,parameters);
    clear projections
end

%% Plot trajectories on embedding space
save_path = [filePath '\dynamics'];
plotDynamicsEmbedding(embeddingValues,save_path);

%% Make density plots
[PDFAll,PDFIndividual,PDFWatershed] = findEmbeddingDensity(embeddingValues);

saveas(PDFAll,fullfile(save_path,'PDF_all'),'jpg');
saveas(PDFIndividual,fullfile(save_path,'PDF_individual'),'jpg');
saveas(PDFWatershed,fullfile(save_path,'PDF_Watershed'),'jpg');



close_parpool

