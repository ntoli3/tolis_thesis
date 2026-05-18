function [enriched_nodes] = find_enriched_nodes(node_coords, element_nodes, intersected_elements)
%
% enriched_nodes = (num_nodes x 1). Has 1 if ..., or 0 if ...

num_nodes = size(node_coords, 1);
num_elements = size(element_nodes, 1);
enriched_nodes = zeros(num_nodes, 1);

for e = 1:num_elements
    is_intersected = (intersected_elements(e) == 0);
    
    if is_intersected
        for n = 1:4
            node_id = element_nodes(e, n);
            enriched_nodes(node_id) = 1;
        end
    end
end

end