function [enriched_nodes] = find_enriched_nodes(node_coords, element_nodes, intersected_elements)
% Finds which nodes must be enriched in XFEM
% Input:
% node_coords = matrix (num_nodes x 2) containing the coordinates of all...
%   mesh nodes. Each row corresponds to one node: column 1 -> x coordinate, column 2 -> y coordinate
% element_nodes = matrix (num_elements x 4), each row corresponds to one Quad4 element...
%   and contains the IDs of its 4 nodes.
% intersected_elements = vector (num_elements x 1) describing the...
%   position of each element relative to the level set interface
% Output:
% enriched_nodes = (num_nodes x 1). Has 1 if node i belongs to at least one intersected element...,
%  otherwise 0

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