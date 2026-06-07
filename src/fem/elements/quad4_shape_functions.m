function [N] = quad4_shape_functions(natural_coords)
% Calculates the shape functions of a point inside a Quad4 element.
% Input:
% natural_coords: vector containing the natural coordinates (xi, eta) of
%   the point.
% Output:
% N = vector 1x4 containing the shape functions.

xi = natural_coords(1);
eta = natural_coords(2);
N = 1/4 * [(1-xi)*(1-eta) (1+xi)*(1-eta) (1+xi)*(1+eta) (1-xi)*(1+eta)];

end