%curvature_init

%This MATLAB script is a general example for running through a series of
%snake centerlines, which MUST be ordered from head to toe:
%   - finding areas of local max. curvature, 
%   - determining the radius of curvature at each of these points, 
%   - determining if each curve falls to the left or right of the 
%     snake's head, 
%   - plotting the results for user visualization,
%   - save the figure, 
%   - tabulate reuslts (saved as .txt and .xls), and
%   - save data as a .mat struct.

% NOTES: - You will need to update 'inpath' string for wherever your data
%           is located.
%        - Centerline data is found in some folder called 'centerline' for each             test.
%        - close_figure should always be set to 1 if you are running 
%           through a high volume of images, unless you set a breakpoint in
%           the plot_ROC function and plan to close after each iteration 
%           yourself. Matlab will freeze up if too many images are plotted
%           at once.

% Author:       Shannon Danforth
% Written:      03/30/2019
% Last update:  10/30/2019

clear; close all;

%define some constants
numPts = 500;           %number of points in spline
win = 0.02;             %window for determining curvature (fraction of snake length)
save_files = 1;         %save resulting figures and tables?
close_figure = 1;       %close figure after each iteration?

%smooth points?
smoothPoints_on = 1;
smoothPts = 30;

%minimum distance to average peaks together.
minPkDist = 30;         %points

%radius thresh?
radiusThreshOn = 1;
radiusThresh = 7;       %percentage of snake length

curveLength = linspace( 0, 100, numPts );

% whatever general path the images will be in
inpath = '/Users/roahm/Box Sync/FREEWearProject';

% How many subfolders in this general path to loop through?
d = dir( inpath );
isub = [d(:).isdir]; %# returns logical vector
subFolderList = {d(isub).name}';
subFolderList(ismember(subFolderList,{'.','..'})) = [];

for j = 1:length(subFolderList)   
    
    testName = subFolderList{j};

    % How many folders to loop through for this specific test?
    d = dir( sprintf( '%s/%s', inpath, testName ) );
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = [];

    for k = 1:length( nameFolds )
        
        imFolder = nameFolds{k};
        
        if contains( imFolder, 'centerline' )

            %find the list of centerline mat files
            img_files = dir( sprintf(...
                '%s/%s/%s/*.mat', inpath, testName, imFolder ) );
    
            for i = 1:length( img_files )
    
                fileName = img_files(i).name;
         
                %organize the points into [x, y] vector
                curve_pts = load( sprintf( '%s/%s/%s/%s',...
                    inpath, testName, imFolder, fileName) );
                curve_pts = curve_pts.xy;
        
                if j == 3
                    
                    endPt = .92*length(curve_pts);
                    x = curve_pts( 1:floor(endPt), 1 );
                    y = curve_pts( 1:floor(endPt), 2 );
                
                else
                
                    x = curve_pts( :, 1 );
                    y = curve_pts( :, 2 );
                    
                end

                %spline x and y.
                [x, y] = spline_x_and_y( x, y, numPts ); 
                
                if smoothPoints_on
                    x = smooth( x, smoothPts );
                    y = smooth( y, smoothPts );
                end
            
                %find the curve at each point along the body
                %and also areas fo local peak curvature.
                [ R, K, R_pks, K_pks, R_idx, L, L_full] = find_curves( x, y, win,...
                    radiusThreshOn, radiusThresh );

                %find whether the local peaks are L or R of the "snake"'s head
                LR = left_or_right( x, y, K );
        
                %now average peaks 
                [R_idx, R_pks, K_pks, R_d] = average_pks( R_idx, R_pks, K_pks, LR,...
                    minPkDist, L, L_full );
         
                %plot things to get a feel if the radii are accurate
                plot_ROC( x, y, R_idx, R_pks, K, imFolder,...
                    fileName, L_full );
        
                    if save_files

                        %IMPORTANT!!
                        %get the magnitude of curvature as a function of the body's length
                        %(because the points could be distributed differently along the robot's centerline)
                        percent_length = L./L_full.*100;

                        Kmag = 1./R;           %so the curvature is in 1/(% snake length)

                        %spline and resample.
                        Kmag = spline( percent_length(11:490), Kmag(11:490) ); 
                        Kmag = ppval( Kmag, curveLength(11:490) )';
                        Kmag = [NaN(10, 1); Kmag; NaN(10, 1)];

                        curvature_mag = Kmag;

                        T = table( percent_length, curvature_mag );  

                        %save as struct
                        data.snakeName = testName;
                        data.imFolder = imFolder;
                        data.fileName = fileName(1:end-4);
                        data.x = x;
                        data.y = y;
                        data.snakeLength = L_full;
                        data.L = L;
                        data.R = R;
                        data.K = K;
                        data.curvature_mag = curvature_mag;
                        data.percent_length = percent_length;
                        data.R_idx = R_idx;
                        data.R_pks = R_pks;
                        data.K_pks = K_pks;
                        data.L_or_R = LR;
                        data.R_distance = R_d;
                        data.table = T;

                        if ~exist( sprintf('%s/%s/curvatureStructs', inpath,...
                                testName ), 'dir' )

                            mkdir( sprintf('%s/%s/curvatureStructs', inpath,...
                                testName ) );

                        end
                        if ~exist( sprintf('%s/%s/curvatureFigures', inpath,...
                                testName ), 'dir' )

                            mkdir( sprintf('%s/%s/curvatureFigures', inpath,...
                                testName ) );

                        end
                        if ~exist( sprintf('%s/%s/curvatureTables', inpath,...
                                testName ), 'dir' )

                            mkdir( sprintf('%s/%s/curvatureTables', inpath,...
                                testName ) );

                        end

                    %save struct
                    save( sprintf('%s/%s/curvatureStructs/%s', inpath,...
                            testName, fileName(1:end-4) ), 'data' );

                    %save figure    
                    saveas( gcf, sprintf('%s/%s/curvatureFigures/%s.png', inpath,...
                            testName, fileName(1:end-4) ) );

                    %save table    
                    writetable( T, sprintf('%s/%s/curvatureTables/%s.csv', inpath,...
                            testName, fileName(1:end-4) ) );

                end
        
                close;
        
            end
            
        end
        
    end
 
end
