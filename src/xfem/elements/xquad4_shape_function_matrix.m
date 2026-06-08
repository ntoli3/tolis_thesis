function [Nstd, Nenr] = xquad4_shape_function_matrix(N, nodal_categories, nodal_phi, psi_func)
% Calculates a matrix containing the shape functions that can be used to
% interpolate nodal displacements: [ux; uy] = N * u_nodal 
% Input:
% N = vector containing the shape functions at a point.
% nodal_categories = 4x1 vector containing 0 for standard nodes or 1 for
%   enriched nodes.
% nodal_phi = 4x1 vector containing the values of the level set φ(x) at
%   nodes of the element.
% psi_func = the enrichment function ψ(x).
% Output:
% Nstd = the shape function matrix corresponding to standard dofs
% Nenr = the shape function matrix corresponding to enriched dofs

% Standard dofs
Nstd = [N(1) 0 N(2) 0 N(3) 0 N(4) 0; 
        0 N(1) 0 N(2) 0 N(3) 0 N(4)];

% Level set and enrichment functions at this point
phi = N * nodal_phi;
psi = psi_func.evaluate(phi, N, nodal_phi);

% Enrichment function at nodes
nodal_psi = zeros(4,1);
nodal_N = eye(4); % shape functions evaluated at nodes
for n = 1 : 4
    nodal_psi(n) = psi_func.evaluate(nodal_phi(n), nodal_N(n,:), nodal_phi);
end

% Enriched dofs
num_enriched_dofs = 2 * sum(nodal_categories == 1); 
Nenr = zeros(2, num_enriched_dofs);
col = 0; % Last column that we filled
for n = 1 : 4
    if nodal_categories(n) == 1
        N_times_psi = N(n) * (psi - nodal_psi(n));
        Nenr(1, col+1) = N_times_psi;
        Nenr(2, col+2) = N_times_psi;
        col = col + 2;
    end
end

end