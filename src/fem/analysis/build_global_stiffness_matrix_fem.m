function [Kee] = build_global_stiffness_matrix_fem(fem_model) 

% Ypologizei kai xtizei ton synoliko pinaka dyskampsias K
% Input: 
% fem_model = object of FemModel
% Output: 
% Kee = synolikos pinakas dyskampsias gia eleutherous dofs

node_coords = fem_model.node_coords;
element_nodes = fem_model.element_nodes;

% Dofs
num_nodes = size(node_coords, 1);
num_elements = size(element_nodes, 1);
dofs_per_node = fem_model.dimension; % 2D: ux, uy, 3D: ux, uy, uz
num_dofs = num_nodes * dofs_per_node;
K = zeros(num_dofs, num_dofs);

% Element stiffness
for e = 1:num_elements
    k_elem = fem_model.buildElementStiffness(e);
    elements_dofs = element_to_global_dofs_fem(element_nodes, e, dofs_per_node);
    K(elements_dofs, elements_dofs) = K(elements_dofs, elements_dofs) + k_elem;
end

Kee = K(fem_model.free_dofs, fem_model.free_dofs);
end
