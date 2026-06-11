function [N, dN_dx, dN_dxi, J, detJ] = quad4_shape_functions_derivatives(...
    natural_coords, nodal_coords)
% Calculates the shape functions and their derivatives of a point inside 
% a Quad4 element.
% Input:
% natural_coords: vector containing the natural coordinates (xi, eta) of
%   the point.
% nodal_coords: matrix 4x2 containing the cartesian coordinates of the 
%   element's nodes.
% Output:
% N = vector 1x4 containing the shape functions.
% dN_dx = matrix 2x4 containing the derivatives of the shape functions in 
%   the cartesian system. Row 1 corrsponds to derivatives w.r.t. x and row
%   2 to derivatives w.r.t. y.
% dN_dxi = matrix 2x4 containing the derivatives of the shape functions in 
%   the natural system. Row 1 corrsponds to derivatives w.r.t. xi and row
%   2 to derivatives w.r.t. eta.
% J = Jacobian matrix of the mapping between natural -> cartesian.
% detJ = determinant of the J.

xi = natural_coords(1);
eta = natural_coords(2);
N = 1/4 * [(1-xi)*(1-eta) (1+xi)*(1-eta) (1+xi)*(1+eta) (1-xi)*(1+eta)];
dN_dxi = 1/4 * [-(1-eta) (1-eta) (1+eta) -(1+eta); 
                -(1-xi) -(1+xi) (1+xi) (1-xi)];

J = dN_dxi * nodal_coords;
detJ = det(J);
% Elegxos gia to J<=0
if detJ <= 0
    error('Non-positive Jacobian determinant detected.');
end

dN_dx = J \ dN_dxi;

end