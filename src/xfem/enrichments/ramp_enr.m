function [val, derivatives_cartesian] = ramp_enr(phi, grad_phi)
% epistrefei to |φ| kai tis paragwgous ws pros x,y
% input:
% phi = h timh ths level set sto gauss point
% grad_phi = gradient ths level set ws pros x,y
% output:
% val = h timh ths enrichment function 
% derivatives_cartesian = oi merikes paragwgoi pros x,y

% ramp enrichment ψ = |φ| 
val = abs(phi);

% ∇ψ = sign(φ) * ∇φ
derivatives_cartesian = sign(phi) * grad_phi;

end