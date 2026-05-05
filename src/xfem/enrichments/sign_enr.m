function [val, derivatives_cartesian] = sign_enr(phi, grad_phi)
% ypologizei to proshmo ths level set kai epistrefei mhdenikes paragwgous
% xwrizei to xwro se duo perioxes
% input:
% phi = h timh ths level set sto gauss point
% grad_phi = gradient ths level set ws pros x,y
% output:
% val = h timh ths enrichment function 
% derivatives_cartesian = oi merikes paragwgoi pros x,y

% Sign enrichment: ψ = sign(φ), ∇ψ = 0
val = sign(phi);

% ∇ψ = 0 (εκτός του interface όπου δεν ορίζεται)
derivatives_cartesian = [0; 0];
% dsign/dx = 0
% dsing/dy = 0

end

