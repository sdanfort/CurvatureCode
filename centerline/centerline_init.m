%centerline_init

%Loop through all binary images, get the centerline, and then _try_ to trace
%the centerline from anterior to posterior.

clear; close all;

% max distance to branch point threshold
thresh = 50;

% whatever general path the images will be in
inpath = '/Users/roahm/Box Sync/FREEWearProject';

% How many subfolders in this general path to loop through?
d = dir( inpath );
isub = [d(:).isdir]; %# returns logical vector
subFolderList = {d(isub).name}';
subFolderList(ismember(subFolderList,{'.','..'})) = [];

for j = 1:length(snakeNameList)   
    
    testName = subFolderList{j};

    % How many folders in this test to loop through?
    d = dir( sprintf( '%s/%s', inpath, testName ) );
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];

    for k = 1:length( nameFolds )
        
        imFolder = nameFolds{k};
        
        %only pick the folder that contains 'binary'
        if contains( imFolder, 'binary' )

            %find the list of binary mat files
            img_files = dir( sprintf(...
                '%s/%s/%s/*.mat', inpath, testName, imFolder ) );
    
            for i = 1:length( img_files )
    
                fileName = img_files(i).name;
        
                %load binary .mat file
                im = load( sprintf( '%s/%s/%s/%s',...
                    inpath, testName, imFolder, fileName ) );
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
                if ~exist( sprintf('%s/%s/centerline', inpath, imFolder ), 'dir' )

                    mkdir( sprintf('%s/%s/centerline', inpath, imFolder ) );

                end
        
                %transform so we have the correct cartesian (x,y) snake shape
                xy(:, 2) = size(im, 1) - xy(:, 2);
                
                if ~exist( sprintf('%s/%s/centerline', inpath, testName), 'dir' )

                    mkdir( sprintf('%s/%s/centerline', inpath, testName) );

                end
                save( sprintf('%s/%s/centerline/%s.mat', inpath, testName, fileName(1:end-4) ), 'xy' );
        
            end
            
        end
        
    end
    
end