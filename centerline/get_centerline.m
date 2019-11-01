function [y, x, S] = get_snake_centerline( im, thresh )

%this is the maximum pixels a branch can be for it to be considered a
%branch. Can update if troublesome.
%first get an approximate centerline

S = bwskel( im );

% S = bwmorph( im, 'thin', Inf );
% 
% S = bwareaopen( S, 100 );
% 
% S = bwareafilt( S, 1, 'smallest' );
% 
% %now find all branchpoints--we don't want them.
BP = bwmorph( S, 'branchpoints' );
EP = bwmorph( S, 'endpoints' );

[ yE, xE ] = find( EP );
B_loc = find( BP );

Dmask = false( size( S ) );

for k = 1:numel( xE )
    
    D = bwdistgeodesic( S, xE( k ), yE( k ) );
    distanceToBranchPt = min( D( B_loc ) );
    
    if distanceToBranchPt < thresh
        
        Dmask( D < distanceToBranchPt ) = true;
        
    end
    
end

S = S - Dmask;
% 
[y, x] = find( S );

end