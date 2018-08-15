function [PDFAll,PDFStiffness,PDFTrial,PDFWatershed] = findEmbeddingDensity(embeddingValues)
%findEmbeddingDensity finds the embedding points' density by using a Gaussian kernel on the
%embedding space

if (nargin<1)
    load('embeddingValues_V_noTrain_1200.mat','embeddingValues');
    load('RobData_V');
    Length = length(RobData_V);
end

L = length(embeddingValues);


%% Find the density
maxVal = max(max(abs(combineCells(embeddingValues))));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40;
numPoints = 501;
rangeVals = [-maxVal maxVal];

[xx,density] = findPointDensity(combineCells(embeddingValues),sigma,numPoints,rangeVals);

%% figure 1: Make density plots
PDFAll = figure(1);

maxDensity = max(density(:));
imagesc(xx,xx,density)
axis equal tight off xy
caxis([0 maxDensity * .8])
colormap(fire);
h = colorbar;
ylabel(h, 'PDF','FontSize', 15,'fontweight','bold');


%% figure 2:Subplot for the low, medium, and high stiffness
embeddingValues_low = cell(10,1);
 for i = 1:10
    embeddingValues_low{i} = embeddingValues{i};
end

embeddingValues_medium = cell(10,1);
for i = 1:10
    embeddingValues_medium{i} = embeddingValues{i+10};
end

embeddingValues_high = cell(10,1);
for i = 1:10
    embeddingValues_high{i} = embeddingValues{i+20};
end

[xx_low,density_low] = findPointDensity(combineCells(embeddingValues_low),sigma,numPoints,rangeVals);
[xx_medium,density_medium] = findPointDensity(combineCells(embeddingValues_medium),sigma,numPoints,rangeVals);
[xx_high,density_high] = findPointDensity(combineCells(embeddingValues_high),sigma,numPoints,rangeVals);


PDFStiffness = figure(2);

colormap(fire);

subplot(1,3,1)
maxDensity_low = max(density_low(:));
imagesc(xx_low,xx_low,density_low)
axis equal tight off xy
title('Low Stiffness')
ax = gca;
ax.TitleFontSizeMultiplier = 2;

subplot(1,3,2)
maxDensity_medium = max(density_medium(:));
imagesc(xx_medium,xx_medium,density_medium)
axis equal tight off xy
title('Medium Stiffness')
ax = gca;
ax.TitleFontSizeMultiplier = 2;

subplot(1,3,3)
maxDensity_high = max(density_high(:));
imagesc(xx_high,xx_high,density_high)
axis equal tight off xy
title('High Stiffness')
ax = gca;
ax.TitleFontSizeMultiplier = 2;

c = [0, max([maxDensity_low maxDensity_medium maxDensity_high]) * .8];
h = colorbar('SouthOutside');
ylabel(h, 'PDF','FontSize', 15,'fontweight','bold');
set(h, 'Position', [.20 .15 .6150 .04]);
set(h, 'Limits', c);
set(gcf, 'Position', [100, 250, 1600, 650])
subplot(1,3,1);
caxis(c);
subplot(1,3,2);
caxis(c);
subplot(1,3,3);
caxis(c);

%% figure 3: Subplot for individual trial
densities = zeros(numPoints,numPoints,L);

for i=1:L
    [~,densities(:,:,i)] = findPointDensity(embeddingValues{i},sigma,numPoints,rangeVals);
end

PDFTrial = figure(3);

N = ceil(sqrt(L));
M = ceil(L/N);
maxDensity = max(densities(:));
for i=1:L
    subplot(M,N,i)
    imagesc(xx,xx,densities(:,:,i))
    axis equal tight off xy
    caxis([0 maxDensity * .8])
    colormap(fire);
    title(['Data Set #' num2str(i)],'fontsize',12,'fontweight','bold');
end

%% figure 4: Make density plot after WaterShed
PDFWatershed = figure(4);

img_afterWatershed = watershed(0-density);
density(img_afterWatershed == 0) = NaN;
imAlpha=ones(size(density));
imAlpha(isnan(density))=0;
imagesc(xx,xx,density,'AlphaData',imAlpha);
axis equal tight off xy
colormap(fire);
h = colorbar;
ylabel(h, 'PDF','FontSize', 15,'fontweight','bold');
maxDensity_Watershed = max(density(:));
caxis([0 maxDensity_Watershed * .8]);
