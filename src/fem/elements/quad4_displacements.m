function [u] = quad4_displacements(natural_coords, nodal_u)
% Calculate the displacements at a specific point inside a Quad4 element.
% Input:
% natural_coords = vector with the coordinates of the point in the natural
%   system of the element
% nodal_u = displacements at the element's nodes
% Output:
% u = 2x1 vector with the displacements of the target point

N = quad4_shape_functions(natural_coords);
Nm = quad4_shape_function_matrix(N);
u = Nm * nodal_u;

end