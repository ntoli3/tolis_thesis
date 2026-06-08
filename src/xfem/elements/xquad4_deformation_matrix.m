function [Bstd, Benr] = xquad4_deformation_matrix(N, dN_dx, ...
    nodal_categories, nodal_phi, psi_func)
% Calculates the deformation matrix B that can be used to calculate strains:
% [ex; ey; exy] = B * u_nodal 
% Input:
% N = vector 1x4 containing the shape functions.
% dN_dx = matrix 2x4 containing the derivatives of the shape functions in 
%   the cartesian system. Row 1 corrsponds to derivatives w.r.t. x and row
%   2 to derivatives w.r.t. y.
% nodal_categories = 4x1 vector containing 0 for standard nodes or 1 for
%   enriched nodes.
% nodal_phi = 4x1 vector containing the values of the level set φ(x) at
%   nodes of the element.
% psi_func = the enrichment function ψ(x).
% Output:
% Bstd = the deformation matrix corresponding to standard dofs
% Benr = the deformation matrix corresponding to enriched dofs

% Standard dofs
Bstd = quad4_deformation_matrix(dN_dx);

% Level set and enrichment functions and derivatives at this point
phi = N * nodal_phi;
psi = psi_func.evaluate(phi, N, nodal_phi);
grad_psi = psi_func.evaluateDerivatives(phi, N, dN_dx, nodal_phi);

% Enrichment function at nodes
nodal_psi = zeros(4,1);
nodal_N = eye(4); % shape functions evaluated at nodes
for n = 1 : 4
    nodal_psi(n) = psi_func.evaluate(nodal_phi(n), nodal_N(n,:), nodal_phi);
end

% Enriched dofs
num_enriched_dofs = 2 * sum(nodal_categories == 1); 
Benr = zeros(3, num_enriched_dofs);
col = 0; % Last column that we filled
for n = 1 : 4
    if nodal_categories(n) == 1
        % Derivatives of Ni(x)*[ψ(x)-ψ(xi)] w.r.t. x and y
        deriv_x = N(n) * grad_psi(1) + dN_dx(1,n) * (psi - nodal_psi(n));
        deriv_y = N(n) * grad_psi(2) + dN_dx(2,n) * (psi - nodal_psi(n));
        
        % Write them into the correct place in B
        Benr(1, col+1) = deriv_x;
        Benr(2, col+2) = deriv_y;
        Benr(3, col+1) = deriv_y;
        Benr(3, col+2) = deriv_x;
        col = col + 2;
    end
end

end