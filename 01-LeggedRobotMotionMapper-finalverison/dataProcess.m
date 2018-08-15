function RobData = dataProcess(robotData,shellTagID,position,orientation,velocity)
%dataProcess processes the kinematic data of robot motion and combine the
%data of position, orientation and velocity based on user selection

if (nargin<1)
    load('dataBeamRobot.mat');
end
if isempty(position)
    position = true;
end
if isempty(orientation)
    orientation = true;
end
if isempty(velocity)
    velocity = true;
end

relRobData = {};
RobData_RPY = {};
RobData_XYZ = {};
RobData_V = {};

filePath = '';

% define any desired parameter changes here
parameters.numProcessors = 4;
parameters = setRunParameters(parameters);


%% Extract relevant data near the traversal stage
for i = 1:length(robotData)
   
    i
       
    [row, col] = find(isnan(robotData{i}.Tag{shellTagID}.XYZ(1,:)));
    Totalframe = length(robotData{i}.Tag{shellTagID}.XYZ);
    Endframe = Totalframe - length(col);
    
    relRobData{i}.XYZ(1,:)= medfilt1(robotData{i}.Tag{shellTagID}.XYZ(1,1:Endframe),3);
    relRobData{i}.XYZ(2,:)= medfilt1(robotData{i}.Tag{shellTagID}.XYZ(2,1:Endframe),3);
    relRobData{i}.XYZ(3,:)= medfilt1(robotData{i}.Tag{shellTagID}.XYZ(3,1:Endframe),3);
    relRobData{i}.RPY(1,:)= medfilt1(robotData{i}.Tag{shellTagID}.RPY(1,1:Endframe),3);
    relRobData{i}.RPY(2,:)= medfilt1(robotData{i}.Tag{shellTagID}.RPY(2,1:Endframe),3);
    relRobData{i}.RPY(3,:)= medfilt1(robotData{i}.Tag{shellTagID}.RPY(3,1:Endframe),3);
    
    % Roll, Pitch, and Yaw
    r = relRobData{i}.RPY(1,:);
    p = relRobData{i}.RPY(2,:);
    y = relRobData{i}.RPY(3,:);
    RobData_RPY{i} = [r(:), p(:), y(:)]; 
    
    % X, Y and Z Position
    x = relRobData{i}.XYZ(1,:);
    y = relRobData{i}.XYZ(2,:);
    z = relRobData{i}.XYZ(3,:);
    RobData_XYZ{i}=[x(:),y(:),z(:)];
    
    % Vx, Vy and Vz
    vx = zeros(length(x)-1,1);
    vy = zeros(length(y)-1,1);
    vz = zeros(length(z)-1,1);

    for j = 1: length(x)-1
        vx(j) = (x(j+1)-x(j))*0.001/0.01;
    end
    for j = 1: length(y)-1
        vy(j) = (y(j+1)-y(j))*0.001/0.01;
    end
    for j = 1: length(z)-1
        vz(j) = (z(j+1)-z(j))*0.001/0.01;
    end
    RobData_V{i} = [vx(:),vy(:),vz(:)];
end

for i = 1 : length(RobData_XYZ)
    RobData_XYZ{i}(end,:) = [];
end
for i = 1 : length(RobData_RPY)
    RobData_RPY{i}(end,:) = [];
end

RobData = {};

for i = 1 : length(robotData)
    if position && ~orientation && ~velocity
        RobData{i} = RobData_XYZ{i};
    elseif ~position && orientation && ~velocity
        RobData{i} = RobData_RPY{i};
    elseif ~position && ~orientation && velocity
        RobData{i} = RobData_V{i}
    elseif position && orientation && ~velocity
        RobData{i}(:,1:3) = RobData_XYZ{i};
        RobData{i}(:,4:6) = RobData_RPY{i};
    elseif position && ~orientation && velocity
        RobData{i}(:,1:3) = RobData_XYZ{i};
        RobData{i}(:,4:6) = RobData_V{i};
    elseif ~position && orientation && velocity
        RobData{i}(:,1:3) = RobData_RPY{i};
        RobData{i}(:,4:6) = RobData_V{i};
    elseif position && orientation && velocity
        RobData{i}(:,1:3) = RobData_XYZ{i};
        RobData{i}(:,4:6) = RobData_RPY{i};
        RobData{i}(:,7:9) = RobData_V{i};
    end
end

% save([filePath 'RobData_RPY.mat'],'RobData_RPY');
% save([filePath 'RobData_XYZ.mat'],'RobData_XYZ');
% save([filePath 'RobData_V.mat'],'RobData_V');
% save([filePath 'RobData.mat'],'RobData');



