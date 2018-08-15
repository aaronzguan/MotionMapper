% Code to plot all the trajectories

clear 
close all
addpath(genpath('dataBeamRobot'));

stiffness = {'Low', 'Medium', 'High'};
refTagID = 2;
shellTagID = 4;

robotData = {};
counter = 0;
% Loop across all the stiffness
for k = 1:3    
%     Loop across all the trials
for i = 1:10
        reconData{i} = load([ pwd '\dataBeamRobot\' stiffness{k} '\' num2str(i) '.mat']);
        reconData{i}.Tags = {}; 
    
        % Get the mean positions orientation of refTags
        refTag = struct();
        refTag.XYZ = []
        for jj = 1:5
           refTag.XYZ(:,jj)  = [reconData{i}.dataX_Abs(refTagID,jj) ;...
                                reconData{i}.dataY_Abs(refTagID,jj) ;...
                                reconData{i}.dataZ_Abs(refTagID,jj)];

           refTag.RPY(:,jj)  = [reconData{i}.dataRoll_Abs(refTagID,jj) ;...
                                reconData{i}.dataPitch_Abs(refTagID,jj) ;...
                                reconData{i}.dataYaw_Abs(refTagID,jj)];
        end
        refTag.XYZ = nanmean(refTag.XYZ,2);
        refTag.RPY = nanmean(refTag.RPY,2);
        % Mean ignoring NaN values
        % nanmean(X,dim) takes the mean along dimension dim of X

        % Pose of calib origin as seen from reference tag
        R_Shift = EulerZYX_Fast(refTag.RPY)';
        p_Shift = -R_Shift*refTag.XYZ  + [-15 ; -105; 0];
    
        for t = 1:length(reconData{i}.dataX_Abs)
            for tag = 1:6   
                reconData{i}.Tag{tag}.XYZ(:,t) = p_Shift + R_Shift* [ reconData{i}.dataX_Abs(tag,t) ; ...
                                                                      reconData{i}.dataY_Abs(tag,t) ; ...
                                                                      reconData{i}.dataZ_Abs(tag,t)];
                reconData{i}.Tag{tag}.R(:,:,t) =  R_Shift*EulerZYX_Fast(  [reconData{i}.dataRoll_Abs(tag,t) , ...
                                                                           reconData{i}.dataPitch_Abs(tag,t) , ...
                                                                           reconData{i}.dataYaw_Abs(tag,t) ]);
                reconData{i}.Tag{tag}.RPY(:,t) = EULERZYXINV_Grass(reconData{i}.Tag{tag}.R(:,:,t));
            end


        end
       
      counter = counter + 1;
      robotData{counter} = reconData{i};
      
end
end



save('dataBeamRobot.mat');
