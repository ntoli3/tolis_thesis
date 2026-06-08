function [phi] = calc_level_set_point(xi, eta, element_id, element_nodes,...
    phi_nodes_all)
% ypologizei th level set se ena shmeio(ξ,η) poy anikei se peperasmeno stoixeio  
% input : 
% xi = parametrikh sintetagmeni toy fysikoy systhmatos sintetagmenwn
% eta = parametrikh sintetagmeni toy fysikoy systhmatos sintetagmenwn
% element id = arithmos tou element poy eimaste 
% element nodes = pinakas poy periexei toys kombous toy kathe element
% phi nodes all = pinakas (num_nodes,1) poy exei tis level sets olwn twn kombwn toy
%           plegamtos 
% output : 
% phi = h timh ths level set sto shmeio(ξ,η)

shape_functions = compute_shape_functions(xi, eta);

% φ(x) =  Σ(Νi*φi)
% Ni = Ni(ξ,η) 

% pws ypologizw athroisma genikws
% sum = 0;
% for i = 1 : 4
%     sum = sum + Ni * phi_i ; 
% end

phi = 0; 
for i = 1 : 4
    n = element_nodes(element_id,i);
    phi_i = phi_nodes_all(n,1);
    Ni = shape_functions(1,i);
    phi = phi + Ni * phi_i;
end
end