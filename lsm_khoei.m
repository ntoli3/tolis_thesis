function[phi,grad_phi]=lsm_khoei(phi_nodes,N,gradN_global)
%selida 25/100
    phi=transpose(N)*(phi_nodes);
    grad_phi=transpose(gradN_global)*(phi_nodes);
    grad_phi=transpose(grad_phi);
end