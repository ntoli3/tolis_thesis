function [psi,grad_psi]=ramp_enr(phi,grad_phi)
%selida 20/103
psi=abs(phi);
grad_psi=sign(phi)*grad_phi;
end
