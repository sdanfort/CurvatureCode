function plot_ROC( x, y, R_idx, R_pks, K, fileName, L_full )
%
% This MATLAB function plots a visualization of snake curves for the user. 
%
% Input:  - x: The x-coordinates of the snake centerline, ordered from head
%           to tail
%         - y: The y-coordinates of the snake centerline, ordered from head
%           to tail
%         - R_idx: averaged indices of local max. curvature
%         - R_pks: averaged radii at these indices
%         - K: curvature vectors at each centerline point
%         - LR: the cell array containing information about whether the
%           curve is to the L or R of the snake's head
%         - inpath: the general path to get to the group of snake folders,
%           string
%         - snakeName: snake species, string
%         - imFolder: specific video folder, string
%         - fileName: name of specific image, string
%         - save_files: binary, 1 to save figure, 0 not to
%         _ close_figure: binary: 1 to close figure after plotting, 0 to
%           not (if you are plotting a lot of images eithout closing them, 
%           matlab will probably get angry)
%         - L_full: total length of snake
%
% Output: None. Will plot a figure.
%
% Author:       Shannon Danforth
% Written:      03/30/2019
% Last update:  04/14/2019


    transparency value for circles
    alp = 0.2;
    
    actual radii of circles:
    R_cc = R_pks./100*L_full;
    
    %turn K into a unit vector
    unitK = zeros( length(R_idx), 2 );
    for i = 1:length(R_idx)
        unitK(i, :) = K( R_idx(i), : )/norm( K( R_idx(i), : ) );
    end
    
    %get the center of all the circles!
    cc = [ x( R_idx ) + R_cc.*unitK( :, 1 ), y( R_idx ) + R_cc.*unitK( :, 2 ) ];

    pos = [cc - R_cc, 2*R_cc, 2*R_cc ];

    figure;
    set( gcf, 'defaultTextInterpreter', 'latex' );
    axis equal;
    
    %plot rectangles:
    for i = 1:length( R_idx )
    rectangle( 'Position', pos( i, :), 'Curvature', [1 1], 'FaceColor',...
        [0 0 1 alp], 'EdgeColor', [0 0 1 alp] ); hold on;
    end
    
    %plot snake centerline:
    scatter( x, y, 'k.' ); hold on;

    %plot curvature vectors:
    quiver( x, y, K(:,1), K(:,2), 'Color', [150,150,150]/255 ); hold on;
    
    %plot dots @ points of local max curvature
    scatter( x(R_idx), y(R_idx), 30, 'ko', 'filled' );
    hold on;

    %legend for everything except blue circles
    legend( 'Snake Centerline', 'Curvature',...
        'Location', 'best');
    title( fileName(1:end-4) );

end