function [u] = xquad4_displacements(natural_coords, nodal_u, ...
    nodal_categories, nodal_phi, psi_handle)
% Calculate the displacements at a specific point inside an XFEM Quad4 element.
% Input:
% N = vector containing the shape functions at a point.
% nodal_categories = 4x1 vector containing 0 for standard nodes or 1 for
%   enriched nodes.
% nodal_phi = 4x1 vector containing the values of the level set φ(x) at
%   nodes of the element.
% psi_handle = the enrichment function ψ(x).
% Output:
% u = 2x1 vector with the displacements of the target point

N = quad4_shape_functions(natural_coords);
[Nstd, Nenr] = xquad4_shape_function_matrix(...
    N, nodal_categories, nodal_phi, psi_handle);
Nm = [Nstd Nenr]; % combine them
u = Nm * nodal_u;

end