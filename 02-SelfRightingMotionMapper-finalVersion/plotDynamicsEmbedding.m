function plotDynamicsEmbedding(embeddingValues,save_path)

if ~exist(save_path,'dir')
    mkdir(save_path);
end

addpath(genpath('./utilities/'));
addpath(genpath('./t_sne/'));
addpath(genpath('./database/'));

maxVal = max(max(abs(combineCells(embeddingValues))));
maxVal = round(maxVal * 1.1);

sigma = maxVal / 40;
numPoints = 501;
rangeVals = [-maxVal maxVal];

%% Plot watershed
[~,density] = findPointDensity(combineCells(embeddingValues),sigma,numPoints,rangeVals);
% img_afterWatershed = watershed(0-density);
% density(img_afterWatershed == 0) = NaN;
% imAlpha=ones(size(density));
% imAlpha(isnan(density))=0;
% imagesc(density,'AlphaData',imAlpha);
% axis equal tight off xy
% colormap(fire)
% h = colorbar;
% ylabel(h, 'PDF','FontSize', 15);
% maxDensity_Watershed = max(density(:));
% caxis([0 maxDensity_Watershed * .8]);
maxDensity = max(density(:));
imagesc(density)
axis equal tight off xy
caxis([0 maxDensity * .8])
colormap(fire)
colorbar
hold on
set(gcf, 'Position', [100 60 1000 1000])

%% Plot the marker
for i = 1 : length(embeddingValues)
    mkdir([save_path '\Video' num2str(i)]);
    delete( findobj(gca, 'type', 'line') );
    for j = 1 : length(embeddingValues{i})
        fprintf(1,['File No.' num2str(i) 'Time ' num2str(j) '\n']);
        mk = plot(0,0, 'color',[0 1 0 0],'marker', 'o','markerfacecolor','g','markeredgecolor','g','markersize',6,'linewidth',3);
        [~,density_eachTrial] = findPointDensity(embeddingValues{i}(j,:),sigma,numPoints,rangeVals);
        maxDensity = max(density_eachTrial(:));
        [x,y] = find(density_eachTrial==maxDensity);
        mk.XData = y;
        mk.YData = x;        
        filename = ['Video' num2str(i) '_T' num2str(j)];
        set(mk,'markeredgecolor','k', 'markerfacecolor','w');
        pause(0.01)
        saveas(gcf,fullfile([save_path '\Video' num2str(i)],filename),'jpg');
        set(mk,'markeredgecolor','g','markerfacecolor','g');
%       
    end
end

