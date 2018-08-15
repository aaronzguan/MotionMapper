function MarkovMatrix = findMarkov(transitionSequence,numStates,threshold)
%findMarkov finds the Markov chain matrix from the input stateSequence
%
%   Input variables:
%   
%       transitionSequence-> the transition sequence of states, Lx1 or 1xL
%       numStates   -> # of states 
%       threshold   -> omit value less than the threshold
% 
%   Output variables:
%
%       MarkovChainMatrix -> N*N Markov Chain Matrix
%
% (C) Aaron Z Guan, 2018
%     Terradynamics Lab, JHU

if(nargin<1)
    %% Find state sequence of each trial
    % state = {};
    % for i = 1 : length(embeddingValues)
    %     
    %     i
    %     
    %     for j = 1 : length(embeddingValues{i})
    %         [~,density_eachTrial] = findPointDensity(embeddingValues{i}(j,:),sigma,numPoints,rangeVals);
    %         maxDensity = max(density_eachTrial(:));
    %         [x,y] = find(density_eachTrial==maxDensity);
    %         state{i}(j) = tempR(x,y);    
    %     end
    % end
%     load('behaviorStates.mat','state');
    load('transitionSequence.mat','transitionSequence')
    numStates = 8;
    threshold = 0.15;
end

N = numStates;              % Number of states of the Markov Chain.

P_MC = zeros(N,N);
for i = 1:length(transitionSequence)
    L = length(transitionSequence{i});  %length of observational sequence.
    %Estimation of transition probability matrix.
    for t=1:L-1
        P_MC(transitionSequence{i}(t),transitionSequence{i}(t+1))= P_MC(transitionSequence{i}(t),transitionSequence{i}(t+1))+1;
    end
end
P_MC_cum = P_MC;
for j=2:N
    P_MC_cum(:,j) = P_MC_cum(:,j-1) + P_MC(:,j);     %cumulative version of P.
end
for j=1:N
    P_MC(:,j) = P_MC(:,j)./P_MC_cum(:,N);                 %Normalize transition matrix
end
P_MC_cum = P_MC;
for j=2:N
    P_MC_cum(:,j) = P_MC_cum(:,j-1) + P_MC(:,j);     %normalized cumulative version of P.
end


P_MC(isnan(P_MC)) = 0;
% Ingore self-transition
for i = 1:length(P_MC)
    P_MC(i,i) = 0; 
end

% Omit the value less than the threshold
P_MC(P_MC<=threshold) = 0;

for i = 1 : length(P_MC)
    for j = 1 : length(P_MC)
        if (nnz(P_MC(i,:)) > 0 && nnz(P_MC(:,i)) == 0 && i ~= 6)
            P_MC(i,:) = 0;
        end
    end
end
%cumulative version of P.
P_MC_cum = P_MC;
for j=2:N
    P_MC_cum(:,j) = P_MC_cum(:,j-1) + P_MC(:,j);
end
%Normalize transition matrix
for j=1:N
    P_MC(:,j) = P_MC(:,j)./P_MC_cum(:,N);                 
end
P_MC(isnan(P_MC)) = 0;

MarkovMatrix = P_MC;

if(nargin<1)
    imagesc(P_MC);
    title('Behavioral Transition Matrix')
    colormap(gray)
    h = colorbar;
    ylabel(h,'Probability','fontweight','bold')
    set(gca,'fontsize',20,'fontweight','bold');
    set(gcf, 'Position', [50 50 1200 1200])
    yticklabels({'Roll and pitch down','Stuck','Deviation','Pitch up and down quickly','Constantly pitch up','Static','Roll and pitch up','Forward'});
    xtickangle(45)
    xticklabels({'Roll and pitch down','Stuck','Deviation','Pitch up and down quickly','Constantly pitch up','Static','Roll and pitch up','Forward'});
end

