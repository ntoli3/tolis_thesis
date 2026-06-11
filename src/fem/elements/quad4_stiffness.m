function [k] = quad4_stiffness(nodal_coords, E, v, t)
% Calculate the stiffness matrix of a Quad4 element
% Input:
% nodal_coords = 4x2 matrix. Each row corresponds to one node. Column 1 = x
%   coordinate of the node. Column 2 = y coordinate.
% E = Young modulus
% v = Poisson ratio
% t = element thickness
% Output:
% k = stiffness matrix of the element

% Elasticity matrix. Same for all Gauss points
Em = (E/(1-v^2)) * [1 v 0;
                    v 1 0;
                    0 0 (1-v)/2];

gauss_points = gauss_integration_quad4(2, 2);

k = zeros(8, 8);
for i = 1: size(gauss_points, 1)
    xi = gauss_points(i,1);
    eta = gauss_points(i,2);
    w = gauss_points(i, 3);
    
    % Shape functions and deformation matrix
    [N, dN_dx, dN_dxi, J, detJ] = quad4_shape_functions_derivatives(...
        [xi eta], nodal_coords);
    B = quad4_deformation_matrix(dN_dx); 
    
    % Stiffness contribution of this Gauss point
    k = k + w * (B' * Em * B) * detJ;
end

k = k * t;
end