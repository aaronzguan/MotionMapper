function imageOut = findBoundingBox(image,boundingWidth)
%findBoundingBox finds the bouding box of the animal in the frame
%   and crop the frame by a boundingWidth x boundingWidth square window
%
%   Input variables:
%       image -> image to be cropped
%       boundingWidth -> the width of the bounding box
%
%   Output variables:
%       imageOut -> image after being cropped
%
    binaryImage = true(size(image));
    measurements = regionprops(binaryImage,image,'WeightedCentroid');
    centerOfMass = measurements.WeightedCentroid;
    xmin = centerOfMass(1) - (boundingWidth/2);
    ymin = centerOfMass(2) - (boundingWidth/2);
    rect = [xmin ymin boundingWidth boundingWidth];
    imageOut = imcrop(image,rect);
    
end