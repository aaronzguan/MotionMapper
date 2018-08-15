function [PDFAll,PDFIndividual,PDFWatershed] = findEmbeddingDensity(embeddingValues)
%findEmbeddingDensity finds the embedding points' density by using a Gaussian kernel on the
%embedding space

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

%% figure 2: Subplot for individual videos
densities = zeros(numPoints,numPoints,L);

for i=1:L
    [~,densities(:,:,i)] = findPointDensity(embeddingValues{i},sigma,numPoints,rangeVals);
end

PDFIndividual = figure(3);

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

%% figure 3: Make density plot after WaterShed
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
