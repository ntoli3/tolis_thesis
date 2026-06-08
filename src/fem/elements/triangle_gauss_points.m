function [rsw] = triangle_gauss_points(num_gauss_points)
% rsw = pinakas me mia grammh ana gp opou
%   stylh 1 = syntetagmenh r
%   stylh 2 = syntetagmenh s
%   stylh 3 = varos w

if num_gauss_points == 1
    rsw = [0.333333 0.333333 1];

else if num_gauss_points == 3
    rsw = [0.166667 0.166667 0.333333 ; 
           0.666667 0.166667 0.333333 ; 
           0.166667 0.666667 0.333333 ;]; 

else 
    throw(MException('Not implemented'));
end




end

