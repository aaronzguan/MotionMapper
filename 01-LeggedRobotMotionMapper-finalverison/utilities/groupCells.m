function [embeddingValues] = groupCells(embedding,RobotData)
%% Group the datas of one trial together as one cell

L = length(RobotData);
embeddingValues = cell(L,1);
N = zeros(1,L);
for i=1:L
    if i ==1
        N(i) = length(RobotData{i});
        embeddingValues{i}= embedding(1:N(i),:);
    else
        N(i) = length(RobotData{i}) + N(i-1);
        embeddingValues{i} = embedding((N(i-1)+1):N(i),:);
    end
end