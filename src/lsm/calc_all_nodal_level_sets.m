function [phi_nodes_all] = calc_all_nodal_level_sets(node_coords, element_nodes, phi_nodes_all)
% Calculate the level sets at all nodes of the mesh
% Input:
% node_coords = matrix (num_nodes x num_dimensions). Each row corresponds to one node and contains 
%   its coordinates in the global cartesian system.
% element_nodes = matrix (num_elements x num_nodes_per_element]). Each row corresponds to one 
%   finite element and contains the IDs of the nodes of that element.
% phi_nodes_all = vector (nx1) with the level set (phi) at each node.
% Output:
% phi_nodes_all = vector (nx1) with the level set (phi) at each node

% Find the characteristic element size for this mesh (for Quad4 only)
node1_id = element_nodes(1, 1);
node2_id = element_nodes(1, 2);
node3_id = element_nodes(1, 3);
node1 = node_coords(node1_id, :);
node2 = node_coords(node2_id, :);
node3 = node_coords(node3_id, :);
dx = norm(node2 - node1);
dy = norm(node3 - node2);
element_size = 0.5*(dx + dy);

% If the level set φ(x) of some node is extremely close to 0, then it is set to 0 exactly
tol = 1E-8;
threshold = tol * element_size;

% Calculate level sets at node coords
num_nodes = size(node_coords, 1);
%phi_nodes_all = zeros(num_nodes, 1);
for n = 1 : num_nodes
    % coords = node_coords(n, :);
    % phi = phi_handle(coords(1), coords(2));
    phi = phi_nodes_all(n);
    if abs(phi) < threshold
        phi = 0;
    end
    phi_nodes_all(n) = phi;
end

end