function [k] = xquad4_stiffness(nodal_coords, nodal_categories, ... 
    nodal_phi, psi_func, material_pos, material_neg, gauss_points)
% Calculate the stiffness matrix of a xfem Quad4 element
% Input:
% node_coords_element = 4x2 matrix. Each row corresponds to one node. Column 1 = x
%   coordinate of the node. Column 2 = y coordinate.
% nodal_categories = 4x1 vector. 0=standard, 1=enriched.
% material_pos = material properties(E,v,t) for the positive level set region, phi > 0
% material_neg = material properties(E,v,t) for the negative level set region, phi < 0
% nodal_level_sets = 4x1 vector with level set values [phi1; phi2; phi3; phi4]
% psi_func = the enrichment function ψ(x).
% gauss_points = matrix containing the integration points and weights. 
%   Each row has the form: [xi,eta,w] 
% Output:
% k = stiffness matrix of the element

% Elasticity matrices
E_neg = material_neg.E;
v_neg = material_neg.v;
t_neg = material_neg.thickness;
E_pos = material_pos.E;
v_pos = material_pos.v;
t_pos = material_pos.thickness;

Em_neg = (E_neg/(1-v_neg^2)) * [1  v_neg  0;
                                v_neg  1  0;
                                0  0  (1-v_neg)/2];
Em_pos = (E_pos/(1-v_pos^2)) * [1  v_pos  0;
                                v_pos  1  0;
                                0  0  (1-v_pos)/2];

% Initialize submatrices
num_enriched_dofs = 2 * sum(nodal_categories == 1);
kss = zeros(8, 8);
kse = zeros(8, num_enriched_dofs);
kee = zeros(num_enriched_dofs, num_enriched_dofs);

% Process Gauss points
for i = 1 : size(gauss_points,1)
    xi = gauss_points(i,1);
    eta = gauss_points(i,2);
    w = gauss_points(i,3);
    
    % Shape functions and deformation matrix
    [N, dN_dx, dN_dxi, detJ] = quad4_shape_functions_derivatives([xi eta], nodal_coords);
    [Bstd, Benr] = xquad4_deformation_matrix(N, dN_dx, nodal_categories, nodal_phi, psi_func);

    % Material selection based on sign of phi
    phi = N * nodal_phi;
    if phi > 0
        Em = Em_pos;
        t = t_pos;
    elseif phi < 0
        Em = Em_neg;
        t = t_neg;
    else 
        error('not implemented')
    end

    % Stiffness contribution of this Gauss point
    coeffs = w * detJ * t;
    kss = kss + coeffs * (Bstd' * Em * Bstd);
    kse = kse + coeffs * (Bstd' * Em * Benr);
    kee = kee + coeffs * (Benr' * Em * Benr);
end  

% Combine the submatrices
k = [kss, kse;
     kse', kee];

end

