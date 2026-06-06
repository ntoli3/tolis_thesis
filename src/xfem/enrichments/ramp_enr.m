function [val, grad_psi] = ramp_enr(phi, grad_phi)
% epistrefei to |φ| kai tis paragwgous ws pros x,y
% input:
% phi = h timh ths level set φ(x,y) sto gauss point
% grad_phi = gradient ths level set φ(x,y) ws pros x,y
% output:
% psi = h timh ths enrichment function ψ(x,y)
% grad_psi = oi merikes paragwgoi της ψ(x,y) pros x,y

% ramp enrichment ψ = |φ| 
val = abs(phi);

if nargin == 2
    % ∇ψ = sign(φ) * ∇φ
    grad_psi = sign(phi) * grad_phi;
else
    grad_psi = NaN;
end


end