function [x, y] = spline_x_and_y( x, y, numPts )
%
% This MATLAB function takes nx1 vectors x and y and returns resampled 
% mx1 vectors x and y.
%
% Input:  - x: The x-coordinates of the snake centerline, ordered from head
%           to tail (nx1)
%         - y: The y-coordinates of the snake centerline, ordered from head
%           to tail (nx1)
%
% Output: - x: The resampled x-coordinates of the snake centerline, 
%           ordered from head to tail (mx1)
%         - y: The resampled y-coordinates of the snake centerline, 
%           ordered from head to tail (mx1)
%
% Author:       Shannon Danforth
% Written:      03/25/2019
% Last update:  ----

    t = (1:numel(x))';
    tNew = linspace( t(1), t(end), numPts );
    x = spline( t, x );
    x = ppval( x, tNew )';
    y = spline( t, y );
    y = ppval( y, tNew )';

end