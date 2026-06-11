function [k] = xquad4_stiffness_cohesive(nodal_coords, nodal_categories, ...
    psi_func, Dcoh, thickness, gauss_points)
% Calculate the stiffness matrix of a cohesive segment inside an XFEM Quad4 element
% Input:
% node_coords_element = 4x2 matrix. Each row corresponds to one node. Column 1 = x
%   coordinate of the node. Column 2 = y coordinate.
% nodal_categories = 4x1 vector. 0=standard, 1=enriched.
% Dcoh = constitutive tensor of the material of a cohesive interface. 2x2 matrix.
% thickness = thickness of the element.
% psi_func = the enrichment function ψ(x).
% gauss_points = matrix (num_gauss_points x 5) with columns: xi, eta, t_xi, t_eta, w. 
%   (t_xi t_eta) is the tangent vector in the natural system and w is the reference weight. 
% Output:
% k = stiffness matrix of the element

% Initialize submatrices
num_enriched_dofs = 2 * sum(nodal_categories == 1);
kee = zeros(num_enriched_dofs, num_enriched_dofs);

% Process Gauss points
for i = 1 : size(gauss_points,1)
    xi = gauss_points(i, 1:2);
    tn = gauss_points(i, 3:4)'; % Tangent vector in natural system
    w = gauss_points(i, 5); % Weight in reference system
    
    % Shape functions and Jacobians
    [N, dN_dx, dN_dxi, J, detJ] = quad4_shape_functions_derivatives(xi, nodal_coords);
    Nm = zeros(2, num_enriched_dofs);
    col = 1;
    for n = 1 : 4
        if nodal_categories(n) == 1
            Nm(1, col) = N(n);
            Nm(2, col+1) = N(n);
            col = col + 2;
        end
    end
   % Nm = quad4_shape_function_matrix(N); % does not work for tangent elements

    % Constitutive matrix of the cohesive interface
    tc = J * tn; % Tangent vector in cartesian system
    tc = tc / norm(tc); % Unit tangent vector in cartesian system
    nc = [tc(2); -tc(1)]; % Unit normal vector in cartesian system
    R = [nc(1) nc(2); 
         tc(1) tc(2)]; % Rotation matrix for the interface segment at this Gauss point
    Dm = R' * Dcoh * R; % Rotated constitutive matrix

    % Stiffness contribution of this Gauss point
    psi_jump = psi_func.evaluateJump();
    Jtot = J * tn; % 2x1 vector for the mapping from reference system to cartesian
    coeffs = psi_jump^2 * w * norm(Jtot) * thickness;
    kee = kee + coeffs * (Nm' * Dm * Nm);
end  

% Place the submatrix into the stiffness for all element dofs
k = zeros(8 + num_enriched_dofs, 8 + num_enriched_dofs);
k(9:end, 9:end) = kee;

end

