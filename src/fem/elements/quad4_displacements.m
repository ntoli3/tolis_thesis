function [u] = quad4_displacements(natural_coords, nodal_u)
% Calculate the displacements at a specific point inside a Quad4 element.
% Input:
% natural_coords = vector with the coordinates of the point in the natural
%   system of the element
% nodal_u = displacements at the element's nodes
% Output:
% u = 2x1 vector with the displacements of the target point

xi = natural_coords(1);
eta = natural_coords(2);

N1 = 0.25 * (1 - xi) * (1 - eta);
N2 = 0.25 * (1 + xi) * (1 - eta);
N3 = 0.25 * (1 + xi) * (1 + eta);
N4 = 0.25 * (1 - xi) * (1 + eta);
N = [N1 0 N2 0 N3 0 N4 0; 
     0 N1 0 N2 0 N3 0 N4];

u = N * nodal_u;

end