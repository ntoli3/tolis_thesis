function [e, s] = xquad4_strains_stresses(natural_coords, nodal_u, ...
    nodal_coords, nodal_categories, nodal_phi, psi_func, material_pos, material_neg)
% Calculate the strains and stresses at a specific point inside a Quad4 element.
% Input:
% natural_coords = vector with the coordinates of the target point in 
%   the natural system of the element.
% nodal_u = 8x1 vector with displacements at the element's nodes.
% nodal_coords = 2x4 matrix with the coordinates of the element's nodes.
% nodal_categories = 4x1 vector containing 0 for standard nodes or 1 for
%   enriched nodes.
% nodal_phi = 4x1 vector containing the values of the level set φ(x) at
%   nodes of the element.
% psi_func = the enrichment function ψ(x).
% material_pos = material properties(E,v,t) for the positive level set region, phi > 0
% material_neg = material properties(E,v,t) for the negative level set region, phi < 0
% Output:
% e = 3x1 vector with the strains of the target point.
% s = 3x1 vector with the stresses of the target point.

% Strains
[N, dN_dx, dN_dxi, detJ] = quad4_shape_functions_derivatives(...
    natural_coords, nodal_coords);
[Bstd, Benr] = xquad4_deformation_matrix(N, dN_dx, ...
    nodal_categories, nodal_phi, psi_func);
B = [Bstd Benr];
e = B * nodal_u;

% Stresses
phi = N * nodal_phi;
if phi > 0
    E = material_pos.E;
    v = material_pos.v;
else
    E = material_neg.E;
    v = material_neg.v;
end
Em = (E/(1-v^2)) * [1 v 0;
                    v 1 0;
                    0 0 (1-v)/2]; % elasticity matrix
s = Em * e;

end