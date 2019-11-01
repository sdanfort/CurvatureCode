function [ R, K, R_pks, K_pks, R_idx, L, L_full] = find_curves( x, y,...
    window_percent, radiusThreshOn, radiusThresh )
%
% This MATLAB function calls subfunctions (written by Are Mjaavatten, 
% available at https://www.mathworks.com/matlabcentral/fileexchange/69452-curvature-of-a-2d-or-3d-curve/
% and edited slightly for the purpose of this project, included in this fcn) 
% to find the curvature, radius of curvature, and cumulative length 
% along each point of the snake centerline.
%
% Once found, the indices of local maximum curvature are determined. 
%
% Input:  - x: The x-coordinates of the snake centerline, ordered from head
%           to tail
%         - y: The y-coordinates of the snake centerline, ordered from head
%           to tail
%         - window_percent: The percent of snake length used to calculate
%           curvature (using the length on each side), entered as a decimal
%         - radiusThreshOn: Binary; 0 if no filtering of large radii is 
%           desired, 1 if filtering of large radii is desired
%         - radiusThresh: Value of max. radius, as percent of snake length
%
% Output: - R: Radius of curvature values at each point in centerline
%         - K: Curvature values at each point in centerline
%         - R_pks: radius values only at indices of local max. curvature
%         - K_pks: curvature values only at indices of local max. curvature
%         - R_idx: Indices of local max. curvature
%         - L: Vector; cumulative length of snake, in pixels, at each point
%         - L_full: Scalar; total length of snake, in pixels.
%
% Author:       Shannon Danforth
% Written:      03/30/2019
% Last update:  04/14/2019

X = [x, y];

%turn window from fraction into a number of points:
win = ceil( length(x) * window_percent );

%find length, radius, and curvature
[L, R, K ] = curvature( X, win );

%total length of snake:
L_full = L(end);

%normalize R by total snake length (%)
R = 100*R/L_full;

%find peak curvature index (smallest radius index!).
[ ~, R_idx ] = findpeaks( vecnorm( K' )' );

%filter out high radii (basically straight lines):
if radiusThreshOn
    
    R_idxTmp = R_idx;
    R_idx = [];
    
    for ii = 1:length( R_idxTmp )
        
        if R( R_idxTmp(ii) ) < radiusThresh
            
            R_idx = [R_idx; R_idxTmp(ii) ];
            
        end
        
    end
    
end

R_pks = R(R_idx);
K_pks = K(R_idx, :);


    function [ L, R, k ] = curvature( X, win )
        
        %this function is from the "curvature" package available at:
        %https://www.mathworks.com/matlabcentral/fileexchange/69452-curvature-of-a-2d-or-3d-curve/
        %Copyright (c) 2018, Are Mjaavatten
        
        %it has been updated for this problem by including an argument
        %"win" which is the number of points on each side used to calculate
        %the curvature.
        
        % Radius of curvature and curvature vector for 2D or 3D curve
        %  [L,R,Kappa] = curvature(X, win)
        %   X:   2 or 3 column array of x, y (and possibly z) coordiates
        %   win: number of points on each side of the point in question
        %       used to calculate the curvature
        %   L:   Cumulative arc length
        %   R:   Radius of curvature
        %   k:   Curvature vector
        
          N = size( X, 1 );
          dims = size( X, 2 );

          if dims == 2
              
            X = [ X, zeros(N,1) ];  % Do all calculations in 3D
            
          end
          
          %initialize arc length vector:
          L = zeros( N, 1 );
          
          %initialize radius of curvature vector:
          R = NaN(N,1);
          
          %initialize curvature array:
          k = NaN(N,3);
          
          %define length for the first 'win' points
          for i = 2:win
              L(i) = L( i - 1 ) + norm( X( i, : ) - X( i-1, : ) );
          end
          
          for i = win + 1:N - win
            [ R(i), ~, k( i, :) ] = circumcenter( X( i, : )', X( i-win, : )',...
                X( i+win, : )' );
            L(i) = L( i - 1 ) + norm( X( i, : ) - X( i-1, : ) );
          end
          
          %length for the last 'win' pts
          for i = N-win+1:N
              L(i) = L( i - 1 ) + norm( X( i, : ) - X( i-1, : ) );
          end
 
          if dims == 2
              
            k = k( :, 1:2 );
            
          end
      
    end
    
    function [ R, M, k ] = circumcenter( A, B, C )
        
        %this function is from the "curvature" package available at:
        %https://www.mathworks.com/matlabcentral/fileexchange/69452-curvature-of-a-2d-or-3d-curve/
        %Copyright (c) 2018, Are Mjaavatten
        
          D = cross( B-A, C-A );
        
          b = norm( A - C );
          c = norm( A - B );
          
          if nargout == 1
              
            a = norm( B - C );     % slightly faster if only R is required
            R = a * b * c / 2 / norm( D );
            
            return
          end
          
          E = cross( D, B - A );
          F = cross( D, C - A );  
          G = ( b^2 * E - c^2 * F ) / norm( D )^2 / 2;
          M = A + G;
          R = norm( G );  % Radius of curvature
          
          if R == 0
              
            k = G;
            
          else
              
            k = G'/R^2;   % Curvature vector
            
          end
          
    end 

end
