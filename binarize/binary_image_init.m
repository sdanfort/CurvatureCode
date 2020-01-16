%binary_image_init

%Loop through a series of folders, then images in that folder, to make each
%image binary and then save as a .mat file.

clear; close all;

pixel_group = 2000;

%UPDATE this variable if you are running a different test!
testName = 'A-StorageTime';

% whatever general path the images will be in
inpath = sprintf( '/Users/roahm/Box Sync/FREEWearProject/%s', testName );

            
% get the list of image files in this folder 
img_files = dir( sprintf( '%s/HomographyFrames/*.tif',...
    inpath ) );

for i = 1:length( img_files )

    fileName = img_files(i).name;

    im = imread( sprintf( '%s/HomographyFrames/%s',...
        inpath, fileName ) );

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
    if ~exist( sprintf('%s/BinaryImage', inpath ), 'dir' )

        mkdir( sprintf('%s/BinaryImage', inpath ) );

    end

    save( sprintf( '%s/BinaryImage/%s.mat', inpath,...
        fileName(1:end-4) ), 'im' );

end