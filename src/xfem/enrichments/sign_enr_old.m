function [psi, grad_psi] = sign_enr_old(phi, grad_phi)
% Ypologizei to proshmo ths level set kai epistrefei mhdenikes paragwgous
% xwrizei to xwro se duo perioxes
% input:
% phi = h timh ths level set φ(x,y) sto gauss point
% grad_phi = gradient ths level set φ(x,y) ws pros x,y
% output:
% psi = h timh ths enrichment function ψ(x,y)
% grad_psi = oi merikes paragwgoi της ψ(x,y) pros x,y

% Sign enrichment: ψ = sign(φ), ∇ψ = 0
psi = sign(phi);

if nargin == 2
    % ∇ψ = 0 (εκτός του interface όπου δεν ορίζεται)
    grad_psi = [0; 0];
else
    grad_psi = NaN;
end

end

