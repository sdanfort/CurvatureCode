%snake_robot_homography

%Load a set of image frames, as well as previously saved crop and 
%homography points for a particular video of a snake robot.

% Author: Shannon Danforth
% Last Updated: 10/28/2019

clear; close all;

% load an image that's a 2x3 ratio.
% If we are keeping the same poster board setup, the poster board is 2x3.
im2 = imread( 'TwoByThree.png' );
im2 = rgb2gray(im2);

% (this is an image that is 9x16 so we can resize to that ratio.)
im3 = imread('undistort2 0049.tif');

% whatever general path the images will be in
%UPDATE this path!!!! IDK what the folder name will be
inpath = '/Users/roahm/Box Sync/FREEWearProject';

%I don't know what subfolders will be below the general folder. But let's
%assume we want to loop through all of them.
%you may have to update below.

% How many subfolders to loop through?
d = dir( inpath );
isub = [d(:).isdir]; %# returns logical vector
subFolderList = {d(isub).name}';
subFolderList(ismember(subFolderList,{'.','..'})) = [];

%loop through all of the subfolders.
for j = 1:length(subFolderList)
    
    testName = subFolderList{j};

    %Within the subfolder, there might be other subfolders. 
    %We want one that just says "postbursttiffs" (unless it's called something else)
    d = dir( sprintf( '%s/%s', inpath, testName ) );
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];

    for k = 1:length( nameFolds )
        
        imFolder = nameFolds{k};
        
        %again, update this string if the folders are named differently.
        if contains( imFolder, 'postbursttiffs' )

            
            % Load saved homography points
            hPts = load( sprintf('%s/homographyPts/pts.mat', imFolder ) );

            %get the geometric transformation
            tform = fitgeotrans( hPts.moving_points, hPts.fixed_points, 'projective' );

            % Load saved crop points
            cropPts = load( sprintf('%s/cropRect/cropRectPts.mat', imFolder ) );
            rect = cropPts.rect;
            
            % get the list of image files in this folder 
            %(they were saved as .tif but could be different)
            img_files = dir( sprintf( '%s/%s/%s/*.tif',...
                inpath, testName, imFolder ) );
            
            for i = 1:length(img_files)
                
                close;
                
                fileName = img_files(i).name;
                
                im1 = imread( sprintf( '%s/%s/%s/%s',...
                    inpath, testName, imFolder, fileName ) ); 

                %will have to do some fun tiff processing
                %again.... may change if the images aren't .tif
                if size(im1, 3) > 1

                im1 = im1( :, :, 1:3 );
                im1 = rgb2gray( im1 );

                end    
                
                im1 = imresize(im1, size(im3));
    
                %crop the image to this size
                im1 = imcrop( im1, rect );

                %change to whatever size im2 is
                im1 = imresize( im1, size(im2) );

                %transform!
                %im = imwarp( im, tform, 'OutputView', imref2d( [1080, 1920] ) );
                im1 = imwarp( im1, tform, 'FillValues', 255 );
                 
                %resize again.....
                im1 = imresize( im1, size(im2) );

                %save as tiff (again, name of fodler could be changed from 'rectified')
                if ~exist( sprintf('%s/%s/rectified', inpath, testName ), 'dir' )

                    mkdir( sprintf('%s/%s/rectified', inpath, testName ) );

                end
        
                figure;
                imshow(im1);

                saveas( gcf, sprintf( '%s/%s/rectified/%s',...
                    inpath, testName, fileName ) );

            end
            
        end
        
    end
    
end