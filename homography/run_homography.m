%run_homography

%Load a set of image frames, as well as previously saved crop and 
%homography points for a particular video of a snake robot.

% Author: Shannon Danforth
% Last Updated: 10/28/2019

clear; close all;

%% file stuff

%UPDATE this variable if you are running a different test!
testName = 'A-StorageTime';

% whatever general path the images will be in
inpath = sprintf( '/Users/roahm/Box Sync/FREEWearProject/%s', testName );

%% load sample images for cropping and crop/transformation points

% load an image that's a 2x3 ratio.
% If we are keeping the same poster board setup, the poster board is 2x3.
im2 = imread( 'TwoByThree.png' );
im2 = rgb2gray(im2);

% (this is an image that is 9x16 so we can resize to that ratio.)
im3 = imread('undistort2 0049.tif');

% Load saved homography points
hPts = load( sprintf('%s/homographyPts/pts.mat', imFolder ) );

%get the geometric transformation
tform = fitgeotrans( hPts.moving_points, hPts.fixed_points, 'projective' );

% Load saved crop points
cropPts = load( sprintf('%s/cropRect/cropRectPts.mat', imFolder ) );
rect = cropPts.rect;

%% loop through image files

% get the list of image files in this folder 
%And we're looking for .jpg files for this project!
img_files = dir( sprintf( '%s/PeakPressureFrames/*.jpg',...
    inpath ) );

for i = 1:length(img_files)

    close;

    fileName = img_files(i).name;

    im1 = imread( sprintf( '%s/PeakPressureFrames/%s',...
        inpath, fileName ) ); 

    %in case image is not grayscale
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

    %save as .jpg
    if ~exist( sprintf('%s/HomographyFrames', inpath ), 'dir' )

        mkdir( sprintf('%s/HomographyFrames', inpath ) );

    end

    figure;
    imshow(im1);

    saveas( gcf, sprintf( '%s/HomographyFrames/%s',...
        inpath, fileName ) );

end