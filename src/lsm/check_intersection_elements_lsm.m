function [intersected_elements] = check_intersection_elements_lsm( ...
    phi_nodes_all, element_nodes)
% elegxei an to element temnetai apo thn kampylh analoga ta phi toy kathe komboy
%input: 
% phi nodes all = pinakas poy exei ta phi olwn twn kombwn toy plegmatos
% element nodes = pinakas poy periexei toys kombous toy kathe element
% output:
% intersected_elements = pinakas poy periexei tis times 1 kai 0 analoga an
% to element temnetai h oxi apo thn kampylh 

% pinakas apotelesmatwn
num_elements = size(element_nodes,1);
intersected_elements = zeros(num_elements, 1);

for e = 1 : num_elements
% vriskw apostaseis twn kombwn tou element
distances = zeros(1,4);
    for j = 1 : 4 %einai oi komboi tou element
        n = element_nodes(e,j); % einai to noumero oty kombou
        phi = phi_nodes_all(n,1);
        
    distances(1,j) = phi;
    end 

% koitame an kobetai to element
    if min(distances) * max(distances) <= 0

        intersected_elements(e) = 1;
    else
        intersected_elements(e) = 0;
    end
end
end

