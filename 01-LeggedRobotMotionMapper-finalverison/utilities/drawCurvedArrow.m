function outPoints = drawCurvedArrow(x,y,line_curvature,plotLine,Linewidth)
%drawCurvedArrow draws the curved line from point x to point y
%
%   Input variables:
%   
%       x -> the start point
%       y -> the end point
%       line_curvature -> the curve of the line
%       plotLine -> ture is to plot, false is not plot
%       Linewidth -> the width of the line
% 
%   Output variables:
%
%       outPoints -> the points on the curve line
%
% (C) Aaron Z Guan, 2018
%     Terradynamics Lab

    if nargin < 4 || isempty(plotLine)
        plotLine = false;
    end

    if iscolumn(x)
        x = x';
    end
    
    if iscolumn(y)
        y = y';
    end

    diff = y-x;
    mid = .5*(y+x);
    d = norm(diff);
    normVec = [-diff(2) diff(1)];
    normVec = normVec ./ d;
    
    bezPoints = [x; mid + line_curvature*d.*normVec; y];
    
    outPoints = bezier_(bezPoints);
    
    if plotLine
        plot(outPoints(:,1),outPoints(:,2),'k-','LineWidth',Linewidth)
    end