function [Bstd, Benr] = xquad4_deformation_matrix(N, dN_dx, ...
    nodal_categories, nodal_phi, psi_handle)
% Calculates the deformation matrix B that can be used to calculate strains:
% [ex; ey; exy] = B * u_nodal 
% Input:
% dN_dx = matrix 2x4 containing the derivatives of the shape functions in 
%   the cartesian system. Row 1 corrsponds to derivatives w.r.t. x and row
%   2 to derivatives w.r.t. y.
% Output:
% Bstd = the deformation matrix corresponding to standard dofs
% Benr = the deformation matrix corresponding to enriched dofs

% Standard dofs
Bstd = quad4_deformation_matrix(dN_dx);

% Level set and enrichment functions and derivatives at this point
phi = N * nodal_phi;
grad_phi = dN_dx * nodal_phi;
[psi, grad_psi] = psi_handle(phi, grad_phi);

% Enriched dofs
num_enriched_dofs = 2 * sum(nodal_categories == 1); 
Benr = zeros(3, num_enriched_dofs);
col = 0; % Last column that we filled
for n = 1 : 4
    if nodal_categories(n) == 1
        % Derivatives of Ni(x)*[ψ(x)-ψ(xi)] w.r.t. x and y
        psi_node = psi_handle(nodal_phi(n));
        deriv_x = N(n) * grad_psi(1) + dN_dx(1,n) * (psi - psi_node);
        deriv_y = N(n) * grad_psi(2) + dN_dx(2,n) * (psi - psi_node);
        
        % Write them into the correct place in B
        Benr(1, col+1) = deriv_x;
        Benr(2, col+2) = deriv_y;
        Benr(3, col+1) = deriv_y;
        Benr(3, col+2) = deriv_x;
        col = col + 2;
    end
end

end