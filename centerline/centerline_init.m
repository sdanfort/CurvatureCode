%centerline_init

%Loop through all binary images, get the centerline, and then _try_ to trace
%the centerline from anterior to posterior.

clear; close all;



%% parameters

% max distance to branch point threshold
thresh = 50;


%% file paths

%UPDATE this variable if you are running a different test!
testName = 'A-StorageTime';

% whatever general path the images will be in
inpath = sprintf( '/Users/roahm/Box Sync/FREEWearProject/%s', testName );


%find the list of binary mat files
img_files = dir( sprintf(...
    '%s/BinaryImage/*.mat', inpath ) );

for i = 1:length( img_files )

    fileName = img_files(i).name;

    %load binary .mat file
    im = load( sprintf( '%s/BinaryImage/%s',...
        inpath, fileName ) );
    im = im.im;
    im(im < 0) = 0;

    im = logical(im);

    %again: get rid of groups of pixels that are smaller
    %than threshold. Can tune if need be.
    pixel_group = 2000;
    im = bwareaopen( im, pixel_group, 4 );

    %and the reverse:
    rev_pixel_group = 2000;
    im = imcomplement(im);
    im = bwareaopen( im, rev_pixel_group, 4 );
    im = imcomplement(im);

    %now get the centerline
    [y, x, S] = get_centerline( im, thresh );

    %%%option to plot to check if we're on the right track
%                 figure;
%                 imshow(im); hold on;
%                 scatter(x, y, '.');
%                 close;  

    %next, trace the points in order:
    [xy] = order_centerline_points( x, y, S );

    %save the ordered points.
    if ~exist( sprintf('%s/CenterlineMat', inpath ), 'dir' )

        mkdir( sprintf('%s/CenterlineMat', inpath ) );

    end

    %transform so we have the correct cartesian (x,y) snake shape
    xy(:, 2) = size(im, 1) - xy(:, 2);

    save( sprintf('%s/CenterlineMat/%s.mat', inpath,...
        fileName(1:end-4) ), 'xy' );

end