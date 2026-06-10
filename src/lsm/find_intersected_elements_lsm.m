function [intersected_elements] = find_intersected_elements_lsm(phi_nodes_all, element_nodes)
% elegxei an to element temnetai apo thn kampylh analoga ta phi toy kathe komboy
%input: 
% phi_nodes_all = column vector me tis level set olwn twn kombwn toy plegmatos
% element_nodes = pinakas poy periexei toys kombous toy kathe element
% output:
% intersected_elements = column vector poy periexei gia kathe element: 0 an temnetai, 
%   +1/-1 an den allilepidra kai vrisketai sti perioxi phi>0/phi<0,
%   +2/-2 an efaptetai kai vrisketai sti perioxi phi>0/phi<0,

% pinakas apotelesmatwn
num_elements = size(element_nodes,1);
intersected_elements = zeros(num_elements, 1);

for e = 1 : num_elements

    % Vriskw level sets twn kombwn tou element
    node_ids = element_nodes(e,:);
    distances = phi_nodes_all(node_ids);
    distances = correct_near0_level_sets(distances);
    
    if min(distances) * max(distances) <= 0 % To element ellilepidra
        if min(distances) * max(distances) < 0
            intersected_elements(e) = 0; % To element temnetai
        elseif min(distances) >= 0
            intersected_elements(e) = +2; % Efaptetai kai brisketai sta phi>0
        else
            intersected_elements(e) = -2; % Efaptetai kai brisketai sta phi<0
        end
    elseif min(distances) > 0
        intersected_elements(e) = 1; % Den ellilepidra kai brisketai sta phi>0
    else
        intersected_elements(e) = -1; % Den ellilepidra kai brisketai sta phi<0
    end
end

end

