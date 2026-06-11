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
    % Find level sets of element nodes
    node_ids = element_nodes(e,:);
    distances = phi_nodes_all(node_ids);
    min_phi = min(distances);
    max_phi = max(distances);
    
    if min_phi > 0
        intersected_elements(e) = 1; % Does not interact and is in the positive region
    elseif max_phi < 0
        intersected_elements(e) = -1; % Does not interact and is in the negative region
    elseif min_phi * max_phi < 0
        intersected_elements(e) = 0; % Cut element
    else
        % The element touches the level set at one or more nodes
        num_touching_nodes = sum(distances == 0);
        if min_phi >= 0
            if num_touching_nodes == 1
                intersected_elements(e) = 1; % Effectively does not interact, positive region
            else
                intersected_elements(e) = +2; % Tangent, positive region
            end
        elseif max_phi <= 0
            if num_touching_nodes == 1
                intersected_elements(e) = -1; % Effectively does not interact, negative region
            else
                intersected_elements(e) = -2; % Tangent, negative region
            end
        else
            error('Unpredicted case');
        end
    end
end

end

