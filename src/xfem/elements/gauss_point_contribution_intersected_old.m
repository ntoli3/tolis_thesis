function [kss_i, kse_i, kee_i] = gauss_point_contribution_intersected_old(...
    N_shape, dN_dxi, dN_deta, nodes, nodal_level_sets, Em, psi_handle)
% Ypologizei th syneisfora enos shmeiou oloklhrwshs gauss stous pinakes
% dyskampsias enos peperasmenou stoixeiou
% Input:
% N_shape = shape functions at gauss point
% dN_dxi, dN_deta =  shape function derivatives at gauss point
% nodes = syntetagmenes twn 4 kombwn toy stoixeioy sto x,y
% nodal_level_sets = 4x1 vector with level set values [phi1; phi2; phi3; phi4]
% Em = pinakas elastikothtas (Em=D)
% psi_handle = function handle for psi(x)
% Output:
% kss_i = h syneisfora toy shmeioy gauss ston pinaka dyskampsias tou standard merous
% kse_i = h syneisfora toy shmeioy gauss ston pinaka dyskampsias tou standard kai enriched merous
% kee_i = h syneisfora toy shmeioy gauss ston pinaka dyskampsias tou enriched merous

% Jacobian
J = [dN_dxi; dN_deta] * nodes;
detJ = det(J);

% Elegxos gia to J<=0
if detJ <= 0
    error('Non-positive Jacobian determinant detected.');
end

% Paragwgoi twn N1, N2, ... ws pros x,y
invJ = inv(J);
dN = invJ * [dN_dxi; dN_deta];

% level set at gauss point
phi_gauss = N_shape * nodal_level_sets;

%grad(phi) = [dphi/dx; dphi/dy];
grad_phi = dN * nodal_level_sets;

% enrichment functon and cartesian derivatives
[psi_gauss, grad_psi] = psi_handle(phi_gauss,grad_phi);

% nodal psi values
psi_nodes = zeros(4,1);
for j = 1:4
    [psi_nodes(j), ~] = psi_handle(nodal_level_sets(j), grad_phi);
end
dpsi_dx = grad_psi(1);
dpsi_dy = grad_psi(2);

% Bs, Be matrix
Bs = zeros(3,8);
Be = zeros(3,8);
for j = 1:4
    % Standard B
    dNj_dx = dN(1,j);
    dNj_dy = dN(2,j);
    Nj = N_shape(j);

    Bs(1,2*j-1) = dNj_dx; 
    Bs(2,2*j)   = dNj_dy; 
    Bs(3,2*j-1) = dNj_dy;
    Bs(3,2*j)   = dNj_dx;

    % Enriched B
    diff_psi = psi_gauss - psi_nodes(j);
    dNenr_dx = dNj_dx * diff_psi + Nj * dpsi_dx;
    dNenr_dy = dNj_dy * diff_psi + Nj * dpsi_dy;

    Be(1,2*j-1) = dNenr_dx;
    Be(2,2*j)   = dNenr_dy; 
    Be(3,2*j-1) = dNenr_dy;
    Be(3,2*j)   = dNenr_dx;
end

kss_i = (Bs' * Em * Bs) * detJ;
kse_i = (Bs' * Em * Be) * detJ;
kee_i = (Be' * Em * Be) * detJ;

end

