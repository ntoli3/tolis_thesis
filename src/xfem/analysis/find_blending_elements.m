function [elements_category] = find_blending_elements(...
    intersected_elements, enriched_nodes, element_nodes)
% This function classifies mesh elements into:  0 = standard element. 
%   1 = intersected element. 2 = blending element
% Input:
% intersected_elements: vector indicating if an element is intersected by a interface 
% 0 = intersected. 1 or -1 not intersected
% enriched_nodes: vector indicating which nodes are enriched
% 1 = enriched node. 0 = standard node
% element_nodes: connectivity matrix. Each row contains the node IDs of one element 
% Output:
% elements_category: vector (num_elements x 1). 0 = standard element. 
%   1 = intersected element. 2 = blending element

num_elements = length(intersected_elements);
num_nodes_per_element = size(element_nodes, 2);

elements_category = zeros(num_elements, 1);

for e = 1:num_elements
    if intersected_elements(e) == 0 % 0 = intersected. 1, -1 = not intersected
        elements_category(e) = 1;
    else % It can be standard or blending element
        % Find how many enriched nodes this element has
        num_enriched_nodes = 0;
        for n = 1:num_nodes_per_element
            node_id = element_nodes(e, n);
            if enriched_nodes(node_id) == 1
                num_enriched_nodes = num_enriched_nodes + 1;
            end
        end
        
        % Decide
        if num_enriched_nodes == 0
            elements_category(e) = 0; % Standard element
        else
            elements_category(e) = 2; % Blending element
        end
    end    
end

end