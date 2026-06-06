function [u] = xquad4_displacements(natural_coords, ...
    standard_enriched_nodes, nodal_u, nodal_phi, psi_handle)
% Calculate the displacements at a specific point inside an XFEM Quad4 element.
% Input:
% Output:
% u = 2x1 vector with the displacements of the target point

% Shape functions
xi = natural_coords(1);
eta = natural_coords(2);
N = 1/4 * [(1-xi)*(1-eta) (1+xi)*(1-eta) (1+xi)*(1+eta) (1-xi)*(1+eta)];

% Standard dofs
ux = 0;
uy = 0;
u_std = nodal_u(1:8);
for n = 1 : 4
    ux = ux + N(n) * u_std(2*n-1);
    uy = uy + N(n) * u_std(2*n);
end

% Enriched dofs
u_enr = nodal_u(9:end);
phi = N * nodal_phi;
psi = psi_handle(phi);
dof = 0;
for n = 1 : 4
    if standard_enriched_nodes(n) == 1
        psi_node = psi_handle(nodal_phi(n));
        Nenr = N(n) * (psi - psi_node);
        dof = dof + 1;
        ux = ux + Nenr * u_enr(dof);
        dof = dof + 1;
        uy = uy + Nenr * u_enr(dof);
    end
    
end

u = [ux; uy];

end