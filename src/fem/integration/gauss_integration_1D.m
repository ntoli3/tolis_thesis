function [sw] = gauss_integration_1D(num_gauss_points)
% rsw = pinakas me mia grammh ana gp opou
%   stylh 1 = syntetagmenh s se voithitiko sustima
%   stylh 3 = varos w

if num_gauss_points == 1
    sw = [0.0 2];
elseif num_gauss_points == 2
    sw = [-0.57735 1; 
            0.57735 1];
elseif num_gauss_points == 3
    sw = [-0.77459 0.55555;
            0.0 0.88888;
            0.77459 0.55555];
elseif num_gauss_points == 4
    sw = [-0.86113 0.34785;
          -0.33998 0.65214;
           0.33998 0.65214;
           0.86113 0.34785]; 
else 
    throw(MException('Not implemented'));
end




end

