function [enriched_nodes] = find_enriched_nodes(node_coords, element_nodes, ...
    phi_nodes_all, intersected_elements)
% Finds which nodes must be enriched in XFEM
% Input:
% node_coords = matrix (num_nodes x 2) containing the coordinates of all...
%   mesh nodes. Each row corresponds to one node: column 1 -> x coordinate, column 2 -> y coordinate
% element_nodes = matrix (num_elements x 4), each row corresponds to one Quad4 element...
%   and contains the IDs of its 4 nodes.
% phi_nodes_all = vector (num_nodes x 1) with the level sets of all nodes.
% intersected_elements = vector (num_elements x 1) describing the...
%   position of each element relative to the level set interface
% Output:
% enriched_nodes = vector (num_nodes x 1). Has 1 if node i is enriched, otherwise 0

num_nodes = size(node_coords, 1);
num_elements = size(element_nodes, 1);
enriched_nodes = zeros(num_nodes, 1);

for e = 1:num_elements
    if abs(intersected_elements(e)) == 1
        continue; % Standard element. No enriched nodes
    end
    
    node_ids = element_nodes(e, :);
    if intersected_elements(e) == 0 % Cut element. All nodes enriched
        enriched_nodes(node_ids) = 1;
    else % Tangent element. Only nodes with phi=0 are enriched
        nodal_phi = phi_nodes_all(node_ids);
        nodal_phi = correct_near0_level_sets(nodal_phi);
        for n = 1:4
            if nodal_phi(n) == 0
                enriched_nodes(node_ids(n)) = 1; % Enrich this node
            end
        end
    end
end

end