function videos = findAllVideosInFolders(folderName,fileType)
%finds all videos within 'folderName' (recursively) whose names end in 'fileType' 

    if nargin==1
        fileType = '.tiff';
    end
    
    if folderName(end) ~= '/'
        folderName = strcat(folderName, '/');
    end
    
    files = dir([folderName '*' fileType]);
    L = length(files);
    videos = cell(L,1);
    for i = 1 : L
        videos{i} = [folderName files(i).name];
    end
    
    