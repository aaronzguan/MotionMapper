function runPreprocess(file_path,output_path,crop,register,parameters)
%runPreprocess runs the alignment and segmentation routines on a .avi file
%
%   Input variables:
%
%       file_path -> avi file to be analyzed
%       outputPath -> path to which files are saved
%       crop -> boolean variable to decide crop the frame or not
%       register -> boolean variable to decide register the frame or not
%       parameters -> struct containing non-default choices for parameters
%
% (C) Aaron Z Guan, 2018
%     Terradynamics Lab, Johns Hopkins University

    vidObj = VideoReader(file_path);
    nFrames = vidObj.NumberOfFrames;
    
    firstFrame = 1;
    lastFrame = [];
    if nFrames < 361000
        lastFrame = nFrames;
    else
        lastFrame = 361000;
    end
    
    dilateSize      = parameters.dilateSize;
    cannyParameter  = parameters.cannyParameter;
    imageThreshold  = parameters.imageThreshold;
    minArea         = parameters.minArea;
    asymThreshold   = parameters.asymThreshold;
    boundingWidth   = parameters.boundingWidth;
    basisImage      = parameters.basisImage;
    initialPhi      = parameters.initialPhi;
    spacing         = parameters.alignment_angle_spacing;
    diffAngle       = parameters.diffAngle;
    
    % If the image is 3 channel, only use R channel to process
    if length(size(basisImage)) == 3
        basisImage = basisImage(:,:,1);
    end
    
    % Crop the basis image
%     if crop
%         basisImage_seg = segmentImage_combo(basisImage,dilateSize,cannyParameter,imageThreshold,[],[],minArea,true);
%         basisImage_seg(basisImage_seg < asymThreshold) = 0;
%         basisImage_subImage = findBoundingBox(basisImage_seg,boundingWidth);
%     end
    
    % Segment, crop and register each frame
    for i = firstFrame : lastFrame
        fprintf(1,'\t\t Processing frame #%4i out of %4i\n',i,lastFrame);
        currentImage = read(vidObj,i);
        if length(size(currentImage)) == 3
            currentImage = currentImage(:,:,1);
        end
        imageOut = segmentImage_combo(currentImage,dilateSize,cannyParameter,imageThreshold,[],[],minArea,true);
        imageOut(imageOut < asymThreshold) = 0;
        if crop            
            subImage = findBoundingBox(imageOut,boundingWidth);
            if register
                [angles(i),image{i}] = alignTwoImages(basisImage_subImage,subImage,initialPhi,spacing);
            else
                image{i} = subImage;
            end
        else
            if register
                [angles(i),image{i}] = alignTwoImages(basisImage,imageOut,initialPhi,spacing);
            else
                image{i} = imageOut;
            end
        end
    end
    
    % Eliminate the asymmetric frame
    if register
        for i = 1 : (length(angles) - 1)
            diff = abs(angles(i+1) - angles(i));
            if diff > diffAngle
                initialPhi = mod(initialPhi+180,360);
                for j = 1 : i
                    fprintf(1,'\t\t Flip frame #%4i\n',j);
                     image{j} = imrotate(image{j},initialPhi,'crop');
                end
            end
        end
    end
    for i = 1 : length(image)
        image{i} = imrotate(image{i},180,'crop');
    end
    
    % Write images to the video
    video_path = VideoWriter(output_path);
    open(video_path);
    for img = 1:length(image)
        writeVideo(video_path,image{img});
    end
    fprintf(1,'\t Processed video is saved \n');
    close(video_path);
end