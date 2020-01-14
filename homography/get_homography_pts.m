%get_homography_pts

% Load the first image frame of a robot, then manually
% specify crop points and the homography transform. 
% Save the points for this camera angle.

% Main idea: import two images.
% One is distorted 
% The other is undistorted: our desired projection
% (really, as long as the desired image is the same size and aspect ratio 
% it could be a white rectangle)

% Author: Shannon Danforth
% Last Updated: 10/28/2019

% IMPORTANT!!!
% if the camera position and zoom stays the same for each test, 
% you only have to run this once!!

clear; close all;

%% setup

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
        
        close;
        
        imFolder = nameFolds{k};
        
        %again, update this string if the folders are named differently.
        if contains( imFolder, 'postbursttiffs' )
    
            %% load image

            % get the list of image files in this folder 
            %(they were saved as .tif but could be different)
            img_files = dir( sprintf( '%s/%s/%s/*.tif',...
                inpath, testName, imFolder ) );

            % filename of first file in the folder.
            fileName = img_files(1).name;

            im1 = imread( sprintf( '%s/%s/%s/%s',...
                inpath, testName, imFolder, fileName ) ); 

            %will have to do some fun tiff processing
            %again.... may change if the images aren't .tif
            if size(im1, 3) > 1

                im1 = im1( :, :, 1:3 );
                im1 = rgb2gray( im1 );

            end
            
            %resize image to be 9x16.
            im1 = imresize(im1, size( im3 ) );

            %% crop image

            %first, check if we have existing crop points to load.
            if exist( sprintf('%s/cropRect/cropRectPts.mat', imFolder ), 'file' ) 

               % Load saved points
               temp = load( sprintf('%s/cropRect/cropRectPts.mat', imFolder ) );
               rect = temp.rect;

            %otherwise, you have to get the cropped points manually.
            else

                %have user click the poster board corners.
                figure; imshow( im1 );
                title( 'Select the four corners of the board. Order does NOT matter' );
                [x, y] = getpts;

                close;

                %form a rectangle that encompasses those points.
                %we want the lowest and highest x_value, lowest and highest y-value
                x_low = min(x);
                x_high = max(x);
                y_low = min(y);
                y_high = max(y);

                xmin = x_low;
                ymin = y_low;
                width = x_high - x_low;
                height = y_high - y_low;

                rect = [ xmin ymin width height ];

                %create folders to save for this test
                if ~exist( sprintf('%s', imFolder), 'dir' )

                    mkdir( sprintf('%s', imFolder) );

                end

                if ~exist( sprintf('%s/cropRect', imFolder), 'dir' )

                    mkdir( sprintf('%s/cropRect', imFolder) );

                end

                save( sprintf('%s/cropRect/cropRectPts.mat', imFolder ) );

            end

            %crop the image to this size
            im1 = imcrop( im1, rect );

            %resize to be same size as im2 again!
            im1 = imresize( im1, size( im2 ) );

            %% get transformation matrix

            % fixed_points = points from im2, our unndistorted image.
            % moving_points = points from im1, our distorted image.

            % getCorrespondences will ask you to select n matching points in the two
            % images. First, select a point in the top image, then select the
            % corresponding point in the lower image.

            % we need at least 4 points to fit the homography 
            % ( it is a matrix with 8 columns )
            n = 4;

            %again, check if there are existing points.
            if ~exist( sprintf('%s/homographyPts', imFolder ), 'dir' )

                mkdir( sprintf('%s/homographyPts', imFolder ) );

            end

            if exist( sprintf('%s/homographyPts/pts', imFolder ), 'file' ) 
               % Load saved points
               load( sprintf('%s/homographyPts/pts', imFolder ) );
            else
               %Get correspondences
               [ moving_points, fixed_points ] = getCorrespondences( im1, im2, n );
               save( sprintf('%s/homographyPts/pts', imFolder ),...
                   'moving_points', 'fixed_points' );
            end

            %get the geometric transformation
            tform = fitgeotrans( moving_points, fixed_points, 'projective' );

            %% find the un-distorted im1!

            im1_new = imwarp( im1, tform, 'OutputView', imref2d( size(im2) ) );

            %plot just to make sure it's okay (will close on the next loop)
            figure;
            imshow( im1_new )
    
        end
       
    end
    
end