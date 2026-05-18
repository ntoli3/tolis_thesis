function [N] = compute_shape_functions(xi, eta)
% ypologizei tis synartiseis sxhmatos tetragwnikoy stoixeioy sto topiko systhma 
% input:
% xi: topikh syntetagmenh toy shmeioy mesa sto stoixeio 
% eta: topikh syntetagmenh toy shmeioy mesa sto stoixeio
% output:
% N: pinakas me tis times twn tessarwn synarthsewn sxhmatos sto shmeio(ξ,η) 

% synartiseis sxhmatos
N1 = 0.25 * (1 - xi) * (1 - eta);
N2 = 0.25 * (1 + xi) * (1 - eta);
N3 = 0.25 * (1 + xi) * (1 + eta);
N4 = 0.25 * (1 - xi) * (1 + eta);

% telikos pinakas
N = [N1, N2, N3, N4];


end