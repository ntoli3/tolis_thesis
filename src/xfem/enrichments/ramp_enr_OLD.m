function [psi, grad_psi] = ramp_enr_old(phi, grad_phi)
% Callculates the ramp enrichment ψ(x)=|φ(x)| and its derivatives w.r.t. x,y.
% Input:
% phi = h timh ths level set φ(x,y) sto gauss point
% grad_phi = gradient ths level set φ(x,y) ws pros x,y
% Output:
% psi = h timh ths enrichment function ψ(x,y)
% grad_psi = oi merikes paragwgoi της ψ(x,y) pros x,y

% ramp enrichment ψ = |φ| 
psi = abs(phi);

if nargin == 2
    % ∇ψ = sign(φ) * ∇φ
    grad_psi = sign(phi) * grad_phi;
else
    grad_psi = NaN;
end


end