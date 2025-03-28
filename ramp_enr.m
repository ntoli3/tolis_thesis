function [psi,grad_psi]=ramp_enr(phi,grad_phi)
%selida 20/100
    psi=abs(phi); %εξ. 1.9
    grad_psi=sign(phi)*grad_phi; %να προσθεσω αυτη την εξισωση στο δικο μου κειμενο
end
