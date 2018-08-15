close all
load('dataBeamRobot.mat');

metadata = xlsread('metadata.xlsx');

enableFilt = 1;
hidePlots = 0;

relRobData = {};

offsetBegin = 20;
offsetEnd = 250;

%% Extract relevant data near the traversal stage
for i = 1:size(metadata,1)
   
    i
   
    hitframe = metadata(i,3)

    if(i<=10)
        offsetEnd = 150;
    elseif(i<=20)
        offsetEnd = 220;
    else
        offsetEnd = 150;
    end
    
    if(enableFilt)
        relRobData{i}.XYZ(1,:)= medfilt1(robotData{i}.Tag{shellTagID}.XYZ(1,hitframe-offsetBegin:hitframe+offsetEnd),3);
        relRobData{i}.XYZ(2,:)= medfilt1(robotData{i}.Tag{shellTagID}.XYZ(2,hitframe-offsetBegin:hitframe+offsetEnd),3);
        relRobData{i}.XYZ(3,:)= medfilt1(robotData{i}.Tag{shellTagID}.XYZ(3,hitframe-offsetBegin:hitframe+offsetEnd),3);
        relRobData{i}.RPY(1,:)= medfilt1(robotData{i}.Tag{shellTagID}.RPY(1,hitframe-offsetBegin:hitframe+offsetEnd),3);
        relRobData{i}.RPY(2,:)= medfilt1(robotData{i}.Tag{shellTagID}.RPY(2,hitframe-offsetBegin:hitframe+offsetEnd),3);
        relRobData{i}.RPY(3,:)= medfilt1(robotData{i}.Tag{shellTagID}.RPY(3,hitframe-offsetBegin:hitframe+offsetEnd),3);
    else
        relRobData{i}.XYZ= robotData{i}.Tag{shellTagID}.XYZ(:,hitframe-offsetBegin:hitframe+offsetEnd);
        relRobData{i}.RPY= robotData{i}.Tag{shellTagID}.RPY(:,hitframe-offsetBegin:hitframe+offsetEnd);
    end
    
end


%Plot the extracted snippets in 3D
ff = figure(1);
set(gcf,'position',[2 672 838 924]);
set(gca,'fontsize',20);
box on; hold on;
cmap = fire(40);
for i = 1:length(robotData)
   xtraj = (relRobData{i}.XYZ(1,:));
   ytraj = (relRobData{i}.XYZ(2,:));
   ztraj = (relRobData{i}.XYZ(3,:));

   
   if(i<=10)
        cl = [0 1 0];
    elseif(i<=20)
        cl = [0 0 1];
    else
        cl = [1 0 0];
    end
   plot3(xtraj,ytraj,ztraj,'color',[cl 0.7], 'linewidth',2);
   1

   axis equal
end
view(-30,45)

% Plot the measured position/orientation for the snippet
gg = figure(2);
set(gcf,'position',[842 672 838 924]);
for i = 1:length(robotData)    
    
     
   if(i<=10)
        cl = [0 1 0];
    elseif(i<=20)
        cl = [0 0 1];
    else
        cl = [1 0 0];
    end
    
    subplot(3,2,1)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(relRobData{i}.XYZ(1,:),'color',[cl 0.7]);
    xlabel('timestep');
    ylabel('x (mm)');   

    

    subplot(3,2,3)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(relRobData{i}.XYZ(2,:),'color',[cl 0.7]);
    xlabel('timestep');
    ylabel('y (mm)');   

    subplot(3,2,5)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(relRobData{i}.XYZ(3,:),'color',[cl 0.7]);
    xlabel('timestep');
    ylabel('z (mm)');   

    subplot(3,2,2)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(relRobData{i}.RPY(1,:)*180/pi,'color',[cl 0.7]);
    xlabel('timestep');
    ylabel('roll (^{\circ})');   

    subplot(3,2,4)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(relRobData{i}.RPY(2,:)*180/pi,'color',[cl 0.7]);
    xlabel('timestep');
    ylabel('pitch(^{\circ})');   


    subplot(3,2,6)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(relRobData{i}.RPY(3,:)*180/pi,'color',[cl 0.7]);
    xlabel('timestep');
    ylabel('yaw(^{\circ})');   

    1
    end


if(hidePlots)
   set(ff,'visible','off'); 
   set(gg,'visible','off');
end





%%  Test SVD -- withouth snippet length

snippetLength = 1;

XLow  = nan(6*10*snippetLength, size(relRobData{1}.XYZ,2) - snippetLength + 1);
XMed  = nan(6*10*snippetLength, size(relRobData{11}.XYZ,2) - snippetLength + 1);
XHigh = nan(6*10*snippetLength, size(relRobData{21}.XYZ,2) - snippetLength + 1);


for tstep = 1:size(XLow,2)
   
    for trial = 1:10
       XLow(6*(trial-1)+1:6*trial,tstep) = [relRobData{trial}.XYZ(:,tstep) ; relRobData{trial}.RPY(:,tstep)*180/pi];
    end
    
end

for tstep = 1:size(XMed,2)
   
    for trial = 1:10
       XMed(6*(trial-1)+1:6*trial,tstep) = [relRobData{10 + trial}.XYZ(:,tstep) ; relRobData{10 + trial}.RPY(:,tstep)*180/pi];
    end
    
end


for tstep = 1:size(XHigh,2)
   
    for trial = 1:10
       XHigh(6*(trial-1)+1:6*trial,tstep) = [relRobData{20 + trial}.XYZ(:,tstep) ; relRobData{10 + trial}.RPY(:,tstep)*180/pi];
    end
    
end


%% This code snippet is from Kutz Textbook  - Pg 394
% F = [XLow;XMed;XHigh];
F = XMed;
F = XLow;
F = XHigh;

% [m,n] = size(F);        % compute data size
% mn = mean(F,2);         % compute mean for each row
% F = F-repmat(mn,1,n);   % subtract mean   
% Cx = (1/(n-1))*(X*X');  % covariance matrix
% [V,D] = eig(Cx);        % eigenvalues(V) and eigenvectors (D)
% lambda1 = diag(D);       % get eigenvalues
% 
% [dummy ,m_arrange] = sort(-1*lambda1);  %sort in decreasing order
% lambda1 = lambda1(m_arrange);
% V = V(:,m_arrange);% 
% Y1 = V'*X;  % Produce the principal component projection

% [u,s,v] = svd(F);       %perform svd
% lambda=diag(s).^2;                %produce diagonal variances
% Y=(u')*F;                         %produce the principal components projection
% 
% [ u s v] = svd(F);
% sig = diag(s);
% for i = 1:length(sig)
%     energy(i)  = sum(sig(1:i))/sum(sig);
% end
% 
% figure(3)
% set(gca,'fontsize',15)
% plot(energy,'ko', 'linewidth',2)