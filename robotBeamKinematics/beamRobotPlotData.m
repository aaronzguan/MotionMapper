

clear all
close all

load('dataBeamRobot.mat')

ff = figure(1);

% 1 = Verify individual trials, XYZRPY
% 2 = PLot 3D
mode = 2;


if(mode==1)
    for i = 1:length(robotData)    % total number of trials

        clf(ff) % clear current figure ff

    %{
    function [xyz] = rpy(R)
    RPY  returns the X-Y-Z fixed angles of rotation matrix R
    
        [ROLL PITCH YAW] = RPY(R)
    
    R is a rotation matrix. xyz is of the form [roll pitch yaw]
    %}
        
    subplot(3,2,1)
    set(gca,'fontsize',20); % gca: returns the current axes or chart for the current figure
    box on; hold on;
    plot(robotData{i}.Tag{shellTagID}.XYZ(1,:),'r');    % first row of XYZ
    plot(medfilt1(robotData{i}.Tag{shellTagID}.XYZ(1,:),3),'b');


    subplot(3,2,3)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(robotData{i}.Tag{shellTagID}.XYZ(2,:),'r');    % second row of XYZ
    plot(medfilt1(robotData{i}.Tag{shellTagID}.XYZ(2,:),3),'b');


    subplot(3,2,5)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(robotData{i}.Tag{shellTagID}.XYZ(3,:),'r');    % third row of XYZ
    plot(medfilt1(robotData{i}.Tag{shellTagID}.XYZ(3,:),3),'b');


    subplot(3,2,2)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(robotData{i}.Tag{shellTagID}.RPY(1,:)*180/pi,'r'); % firt row of RPY = R
    plot(medfilt1(robotData{i}.Tag{shellTagID}.RPY(1,:)*180/pi,3),'b');

    subplot(3,2,4)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(robotData{i}.Tag{shellTagID}.RPY(2,:)*180/pi,'r'); % second row of RPY = P
    plot(medfilt1(robotData{i}.Tag{shellTagID}.RPY(2,:)*180/pi,3),'b');


    subplot(3,2,6)
    set(gca,'fontsize',20);
    box on; hold on;
    plot(robotData{i}.Tag{shellTagID}.RPY(3,:)*180/pi,'r'); % third row of RPY = Y
    plot(medfilt1(robotData{i}.Tag{shellTagID}.RPY(3,:)*180/pi,3),'b');

    1
    end
end


if(mode==2)
   set(gca,'fontsize',20);
   box on; hold on;
   cmap = fire(40);
    %   fire:   Blue-Purple Hot colormap.
    %   fire(M):Returns an M-by-3 matrix containing a "fire" colormap.
%    cmap = cmap(15:45,:);
%    Loop across all the trials
   for i = 1:length(robotData)
       xtraj = medfilt1(robotData{i}.Tag{shellTagID}.XYZ(1,:));
       ytraj = medfilt1(robotData{i}.Tag{shellTagID}.XYZ(2,:));
       ztraj = medfilt1(robotData{i}.Tag{shellTagID}.XYZ(3,:));
       
       plot3(xtraj,ytraj,ztraj,'color',[cmap(i,:) 0.7], 'linewidth',1);
       1
       
       axis equal
   end
    
end
