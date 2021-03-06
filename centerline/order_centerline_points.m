function [xy_out] = order_centerline_points( x, y, S )

% goal is to trace the centerline points in order from the anterior to
% posterior of the snake robot.

% Need to start from some assumption like "the snake robot will always have
% the anterior side pointing towards the left/top/whatever"

%I believe (x,y) are given as cartesian points, not in pixel space, but
%should make sure.

%Find the point with the smallest x-value.
%note: there may be more than one point with the same x-value, but
%hopefully not too many because the snake robot doesn't self-occlude or
%curve around
%NOTE: this could fall apart if the wrong first point is selected!!! yikes

xy_out = zeros( length(x), 2 );

%FIND ENDPOINTS, then find which endpoint has the smallest
%x-value.
EP = bwmorph( S, 'endpoints' );
[ yE, xE ] = find( EP );

%UPDATE this code if the robot is in a different configuration!
%For example, if the head of the robot is located at the top of the poster
%board, you would be looking for the smallest y-coordinate, not x.
[ ~, minXEidx ] = min( xE );

xy = [x, y];

% xy_out( 1, : ) = xy( minXEidx, : );
xy_out( 1, : ) = [ xE(minXEidx), yE(minXEidx) ];

xy = setdiff( xy, [ xE(minXEidx), yE(minXEidx) ], 'rows' );

for i = 1:length(x)-1
    
    %compute the euclidean distance between current point and all other
    %points
    distMag = sqrt(( xy(:, 1) - xy_out(i, 1) ).^2 + ( xy(:, 2) - xy_out(i, 2) ).^2);
    [ ~, minIdx ] = min(distMag);
    
    %set min distance point to the i+1 index
    xy_out( i+1, : ) = xy( minIdx, : );
    
    %get rid of that point
    xy = setdiff( xy, xy( minIdx, : ), 'rows' );
    
end