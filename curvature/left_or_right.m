function LR = left_or_right( x, y, K )
%
% This MATLAB function determines whether the curvature vector falls to the
% left or right of the snake's head.
%
% Input:  - x: The x-coordinates of the snake centerline, ordered from head
%           to tail (mx1)
%         - y: The y-coordinates of the snake centerline, ordered from head
%           to tail (mx1)
%         - K: curvature vector at each point (mx2)
%
% Output: - LR: a (mx1) cell array containing 'L', 'R', or 'S', depending
%           on whether the curve is to the left, right, or straight of the 
%           snake's head
%
% Author:       Shannon Danforth
% Written:      03/30/2019
% Last update:  ----

    %create a cell array for 'L', 'R', or 'S':
    LR = cell( length(x), 1 );
    
    %just define the first point as straight.
    LR{1} = 'S';

    %loop through all points, starting at the 2nd:
    for i = 2:length( x )
        
        %get the curvature x- and y-coords for this point
        ki = K( i, : )';
        
        %get coordinates of the vector from i+1 to i:
        xi = x( i - 1 ) - x( i );
        yi = y( i - 1 ) - y( i );
        
        %solve for the angle between x-axis and this new vector:
        thetaX = atan2( yi, xi );
        if thetaX < 0
            thetaX = thetaX + 2*pi;
        end
        
        thetaY = thetaX + pi/2;
        if thetaY > 2*pi     
            thetaY = thetaY - 2*pi;   
        end
        
        %angle between k and x-axis:
        phi = atan2( ki(2), ki(1) );
        if phi < 0
            phi = phi + 2*pi;
        elseif phi > 2*pi  
            phi = phi - 2*pi;  
        end
        
        %angle between k and yi-axis is 
        alpha = thetaY - phi;
        if alpha > 2*pi
            alpha = alpha - 2*pi;   
        end
        
        %decide if curve is left or right based on magnitude of alpha.
        if abs( alpha ) < pi/2
            
            LR{i} = 'L';
            
        elseif abs( alpha ) > pi/2
            
            LR{i} = 'R';
            
        else
            
            LR{i} = 'S';
            
        end
        
    end

end