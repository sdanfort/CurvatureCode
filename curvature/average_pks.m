function [R_idx, R_pks, K_pks, R_d] = average_pks( R_idxTmp, R_pksTmp, K_pksTmp, LR,...
            minPkDist, L, L_full )
%
% This MATLAB function takes the average of any peaks that are within a
% distance of minPkDist from each other, and averages their indices as
% well. It returns a new set of indices, peak radii, and peak curvature
% values.
%
% Input:  - R_idxTmp: The original set of indices of max, curvature, before
%           any averaging
%         - R_pksTmp: The original set of radii at indices of max. 
%           curvature, before any averaging
%         - K_pksTmp: The original set of curvatures at indices of max. 
%           curvature, before any averaging
%         - LR: the cell array containing information about whether the
%           curve is to the L or R of the snake's head
%         - minPkDist: The minimum allowable number of points between peaks
%         - L: snake length at each point along the centerline
%         - L_full: total snake length
%
% Output: - R_idx: new indices of local max. curvature, averaged now
%         - R_pks: new averaged radii at these indices
%         - K_pks: new averaged curvatures at these indices
%         - R_d: the distance from the snake's head to each (averaged) 
%           location of local peak curvature, reported as a percentage of
%           snake length
%
% Author:       Shannon Danforth
% Written:      04/12/2019
% Last update:  ----

diffR = diff( R_idxTmp );
while min( diffR ) < minPkDist
    
    %check if the min idx is on the same curve
    [~, idxDiff] = min( diffR );
    
    if LR{ R_idxTmp(idxDiff + 1) } == LR{ R_idxTmp(idxDiff) }
    
        [ R_idxTmp, R_pksTmp, K_pksTmp ] = average_pksTMP( R_idxTmp, R_pksTmp, K_pksTmp, LR,...
                minPkDist, L, L_full );
            
        diffR = diff( R_idxTmp );   
            
    else

        diffR( idxDiff ) = NaN;
        
    end
    
end

R_idx = R_idxTmp;
R_pks = R_pksTmp;
K_pks = K_pksTmp;
%location of peak from head of snake, as a percentage of snake length:
R_d = 100*L( R_idx )/L_full;
        
    function [ R_idx, R_pks, K_pks ] = average_pksTMP( R_idxTmp, R_pksTmp, K_pksTmp, LR,...
                minPkDist, L, L_full )
    R_idx = [];
    R_pks = [];
    K_pks = [];

    useNextPt = 1;

    for ii = 1:length(R_idxTmp) - 1

        %if the points are close together and pointing in the same direction
        if R_idxTmp(ii+1) - R_idxTmp(ii) < minPkDist &&...
                LR{ R_idxTmp(ii+1) } == LR{ R_idxTmp(ii) }

             R_idx = [R_idx; floor( mean( [R_idxTmp(ii+1), R_idxTmp(ii)] ) ) ];
             R_pks = [R_pks; mean( [ R_pksTmp(ii+1), R_pksTmp(ii) ] ) ];
             K_pks = [K_pks; mean( [ K_pksTmp(ii+1, :); K_pksTmp(ii, :) ] ) ];

             useNextPt = 0;

             if ii == length(R_idxTmp) - 1

                 useLastPt = 0;

             end

        else

            if useNextPt

                R_idx = [R_idx; R_idxTmp(ii) ];
                R_pks = [R_pks; R_pksTmp(ii) ];
                K_pks = [K_pks; K_pksTmp(ii, :) ];

            end

             if ii == length(R_idxTmp) - 1

                 useLastPt = 1;

             end

             useNextPt = 1;

        end

    end

    %end condition
    if useLastPt
        ii = length(R_idxTmp);
        R_idx = [R_idx; R_idxTmp(ii) ];
        R_pks = [R_pks; R_pksTmp(ii) ];
        K_pks = [K_pks; K_pksTmp(ii, :) ];
    end

    end

end