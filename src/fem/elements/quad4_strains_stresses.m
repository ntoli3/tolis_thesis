function [e, s] = quad4_strains_stresses(natural_coords, nodal_u, ...
    nodal_coords, E, v)
% Calculate the strains and stresses at a specific point inside a Quad4 element.
% Input:
% natural_coords = vector with the coordinates of the target point in 
%   the natural system of the element.
% nodal_u = 8x1 vector with displacements at the element's nodes.
% nodal_coords = 2x4 matrix with the coordinates of the element's nodes.
% E, v = elasticity modulus and Possion ratio of the material.
% Output:
% e = 3x1 vector with the strains of the target point.
% s = 3x1 vector with the stresses of the target point.

% Strains
[N, dN_dx, dN_dxi, J, detJ] = quad4_shape_functions_derivatives(...
    natural_coords, nodal_coords);
B = quad4_deformation_matrix(dN_dx);
e = B * nodal_u;

% Stresses
Em = (E/(1-v^2)) * [1 v 0;
                    v 1 0;
                    0 0 (1-v)/2];
s = Em * e;

end