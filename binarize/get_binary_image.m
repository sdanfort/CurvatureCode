%get_binary_image

%Loop through a series of folders, then images in that folder, to make each
%image binary and then save as a .mat file.

clear; close all;

pixel_group = 2000;

% whatever general path the images will be in
%UPDATE!!
inpath = '/Users/roahm/Box Sync/2019 ICRA snake robot videos';

% How many subfolders in this general path to loop through?
d = dir( inpath );
isub = [d(:).isdir]; %# returns logical vector
subFolderList = {d(isub).name}';
subFolderList(ismember(subFolderList,{'.','..'})) = [];

for j = 1:length(subFolderList)  
    
    testName = subFolderList{j};

    % How many folders to loop through?
    d = dir( sprintf( '%s/%s', inpath, testName ) );
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];

    for k = 1:length( nameFolds )
        
        imFolder = nameFolds{k};
        
        %change this if you are naming the rectified image folder something
        %else
        if contains( imFolder, 'rectified' )
            
            % get the list of image files in this folder 
            img_files = dir( sprintf( '%s/%s/%s/*.tif',...
                inpath, testName, imFolder ) );
    
            for i = 1:length( img_files )

                fileName = img_files(i).name;

                im = imread( sprintf( '%s/%s/%s/%s',...
                    inpath, testName, imFolder, fileName ) );

                %make grayscale    
                im = rgb2gray(im);
                im = imadjust( im );
                im = imgaussfilt(im);
        
                %make binary
                im = imbinarize( im, 'global' );

                %get rid of groups of pixels that are smaller
                %than threshold. Can tune if need be.
                im = bwareaopen( im, pixel_group, 4 );
        
                %make border black too
                CC = bwconncomp(im);
                numPixels = cellfun(@numel,CC.PixelIdxList);
                [biggest, idx] = max(numPixels);
                im(CC.PixelIdxList{idx}) = 0;
                
        
                % save as a .mat file (update filename):
                if ~exist( sprintf('%s/%s/binary', inpath, testName ), 'dir' )

                    mkdir( sprintf('%s/%s/binary', inpath, testName ) );

                end
                
                save( sprintf( '%s/%s/binary/%s.mat', inpath, testName,...
                    fileName(1:end-4) ), 'im' );
                
            end
            
        end
        
    end
    
end