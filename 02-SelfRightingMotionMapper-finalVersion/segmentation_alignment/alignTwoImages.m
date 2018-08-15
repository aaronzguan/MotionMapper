function [angle,rotatedImage] = alignTwoImages(image1,image2,angleGuess,spacing)
%alignTwoImages rotationally and translationally aligns an image with a 
%background image
%
%   Input variables:
%
%       image1 -> background image
%       image2 -> image to be aligned
%       angleGuess -> initial guess to eliminate 180 degree degeneracy
%       spacing -> angular spacing in Radon transform
%
%   Output variables:
%
%       rotationAngle -> rotational alignment angle
%       X, Y -> translational alignment values (in pixels)
%       finalImage -> aligned version of image2
%       errors -> errors in alignment
%       finalOriginalImage -> aligned version of originalImage (optional)
%
%
% (C) Aaron Z GUAN
%     Terradynamics Lab, Johns Hopkins University
             

    if nargin < 3 || isempty(angleGuess) == 1
        angleGuess = 0;
    else
        angleGuess = mod(angleGuess,360);
    end
    
    angleGuess = angleGuess*pi/180;
    
    if nargin < 4 || isempty(spacing) == 1
        spacing = .5;
    end
    N = 180/spacing;
           
    thetas = linspace(0, 180-spacing, N);

    %Find fft of the Radon transform       
    F1 = abs(fft(radon(image1, thetas)));
    F2 = abs(fft(radon(image2, thetas)));


    %Find the index of the correlation peak
    correlation = sum(fft2(F1) .* fft2(F2));
    peaks = real(ifft(correlation));
    peakIndex = find(peaks==max(peaks));


    if length(peakIndex) > 1
        peakIndex = peakIndex(1);
    end


    %Find rotation angle via quadratic interpolation
    if (peakIndex~=1) && (peakIndex ~= N)
        p=polyfit(thetas((peakIndex-1):(peakIndex+1)),peaks((peakIndex-1):(peakIndex+1)),2);
        rotationAngle = -.5*p(2)/p(1);
    else
        if peakIndex == 1
            p = polyfit([thetas(end)-180,thetas(1),thetas(2)],peaks([N,1,2]),2);
            rotationAngle = -.5*p(2)/p(1);
            if rotationAngle < 0
                rotationAngle = 180 + rotationAngle;
            end
        else
            p = polyfit([thetas(end-1),thetas(end),180+thetas(1)],peaks([N-1,N,1]),2);
            rotationAngle = -.5*p(2)/p(1);
            if rotationAngle >= 180
                rotationAngle = rotationAngle - 180;
            end
        end
    end

    %Check to see if rotation angle is in the correct direction
    rA = rotationAngle*pi/180;
    test = dot([cos(rA),sin(rA)],[cos(angleGuess),sin(angleGuess)]);
    angle = rotationAngle;
    
    if test < 0
        rotationAngle = mod(rotationAngle-180,360);
        rotationAngle = mod(rotationAngle,360);
        toRotate = mod(-rotationAngle,360);
    else
        rotationAngle = mod(rotationAngle,360);
        toRotate = mod(-rotationAngle,180);
    end

    %Rotate Image & Crop to original Size
    rotatedImage = imrotate(image2,toRotate,'crop');
    