function [intersection_point_coords] = lsm_element_intersection(node_coords_element, phi_nodes_element)
% ypologizei ta shmeia tomhs ths level set me ta elements
% input:
% node coords element = oi syntetagmenes twn kombwn toy element
% phi nodes element = oi thmes ths level set stoys tesseris komboys toy element 
% output:
% intersection point coords = oi syntetagmenes twn shmeiwn poy temnei h level set to element

intersection_point_coords = []; % adeios pinakas kai oxi mhdenikos

for s = 1 : 4 % pairnw mia mia tis tesseris akmes 
    node1 = s;
    if s < 4
        node2 = s+1;
    else 
        node2 = 1;
    end
    
    x1 = node_coords_element(node1,:);
    x2 = node_coords_element(node2,:);
    phi1 = phi_nodes_element(node1);
    phi2 = phi_nodes_element(node2);
    if phi1 * phi2 < 0
       lamda = (-phi1)/(phi2-phi1);
       xi = x1 + lamda*(x2-x1); 
       %intersection_points(1,:) = xi; 
       intersection_point_coords = [intersection_point_coords ; xi];
    end

end
end