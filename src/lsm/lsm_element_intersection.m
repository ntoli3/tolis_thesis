function [intersection_point_coords] = lsm_element_intersection(node_coords_element, phi_nodes_element)
% ypologizei ta shmeia tomhs ths level set me ta elements
% input:
% node coords element = oi syntetagmenes twn kombwn toy element se fysiko systima
% phi nodes element = oi thmes ths level set stoys tesseris komboys toy element 
% output:
% intersection point coords = oi syntetagmenes twn shmeiwn poy temnei h level set to element

intersection_point_coords = []; % adeios pinakas kai oxi mhdenikos

for s = 1 : 4 % Exetazw mia mia tis tesseris akmes 
    node1 = s;
    if s < 4
        node2 = s+1;
    else 
        node2 = 1;
    end
    
    % Simeio tomis
    xi1 = node_coords_element(node1,:);
    xi2 = node_coords_element(node2,:);
    phi1 = phi_nodes_element(node1);
    phi2 = phi_nodes_element(node2);
    if phi1 * phi2 < 0
        lamda = (-phi1) / (phi2 - phi1);
        xi3 = xi1 + lamda * (xi2 - xi1); 
    elseif phi1 == 0
        xi3 = xi1;
    elseif phi2 == 0
        xi3 = xi1;
    else
        continue; % An den yparxei tomi, synexizw stin epomeni akmi
    end
   
    % Alliws elegxw an to exw apothikeysei apo prin
    is_new = 1;
    for p = 1 : size(intersection_point_coords, 1)
        old_point = intersection_point_coords(p,:);
        if isequal(xi3, old_point)
            is_new = 0;
            break;
        end
    end
    
    % An einai neo to apothikeuw
    if is_new
        intersection_point_coords = [intersection_point_coords; xi3];
    end

end
end