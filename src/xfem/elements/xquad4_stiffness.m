function [k_total] = xquad4_stiffness(node_coords_element, ...
    standard_enriched_nodes, material_pos, material_neg, ...
    nodal_level_sets, psi_handle, gauss_points)
% Calculate the stiffness matrix of a xfem Quad4 element
% Input:
% node_coords_element = 4x2 matrix. Each row corresponds to one node. Column 1 = x
%   coordinate of the node. Column 2 = y coordinate.
% standard_enriched_nodes = 4x1 vector. 0=standard. 1 = enriched.
% Eneg, Epos = Young's modulus for the negative and positive level set regions
% v_neg, v_pos = Poisson's ratio for the negative and positive level set regions
% t_neg, t_pos = Thickness of the element for the negative and positive regions
% psi_handle = function handle for psi(x)
% nodal_level_sets = 4x1 vector with level set values [phi1; phi2; phi3; phi4]
% Output:
% k_total = stiffness matrix of the element

% Em = mitrwo elastikotitas
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

% Arxikopoihsh
num_enriched_dofs = 2 * sum(standard_enriched_nodes == 1);
kss = zeros(8, 8);
kse = zeros(8, num_enriched_dofs);
kee = zeros(8, num_enriched_dofs);

for i = 1 : size(gauss_points,1)

    xi = gauss_points(i,1);
    eta = gauss_points(i,2);
    w = gauss_points(i,3);

    % Shape functions and derivatives at gauss point
    N_shape = 1/4 * [(1-xi)*(1-eta) (1+xi)*(1-eta) (1+xi)*(1+eta) (1-xi)*(1+eta)];
    dN_dxi = 1/4 * [-(1-eta) (1-eta) (1+eta) -(1+eta)];
    dN_deta = 1/4 * [-(1-xi) -(1+xi) (1+xi) (1-xi)];

    % Interpolated level set at Gauss point
    phi = N_shape * nodal_level_sets;

    % Material selection based on sign of phi
    if phi > 0
        Em = Em_pos;
        t = t_pos;
    elseif phi < 0
        Em = Em_neg;
        t = t_neg;
    else 
        error('not implemented')
    end

    [kss_i, kse_i, kee_i] = gauss_point_contribution(N_shape, dN_dxi, dN_deta, ...
        node_coords_element, nodal_level_sets, psi_handle, ...
        standard_enriched_nodes, num_enriched_dofs, Em);
    
    kss = kss + w * kss_i * t;
    kse = kse + w * kse_i * t;
    kee = kee + w * kee_i * t;
end  

k_total = [kss, kse;
           kse', kee];
end

