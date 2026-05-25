function [free_dofs, supported_dofs] = order_dofs_fem(fem_model)
% Taxinomei kai prosdiorizei toys eleytherous kai desmeymenous dofs toy FEM
% model
% Input:
% fem_model = see FemModel()
% Output:
% free_dofs = dianysma poy periexei ta IDS twn free dofs
% supported_dofs = dianysma poy periexei ta IDS twn supported dofs
% dofs

dim = fem_model.dimension;

num_nodes = size(fem_model.node_coords, 1);
num_global_dofs = dim * num_nodes;
global_dofs = 1 : num_global_dofs; % e.g.[1,2,3,4,5,6,7,8]
supported_dofs = []; % e.g. [1,2,4]
supports = fem_model.supports;

for i = 1: size(supports, 1)
    node_id = supports(i, 1);
    dof_type = supports(i, 2);
    
    % Find global dof.
    % For ux in 2D: global_dof = 2 * node_id - 1;
    % For uy in 2D: global_dof = 2 * node_id;
    % For ux in 3D: global_dof = 3 * node_id - 2;
    % For uy in 3D: global_dof = 3 * node_id - 1;
    % For uz in 3D: global_dof = 3 * node_id
    global_dof = dim * node_id  + dof_type-dim;
    
    supported_dofs = [supported_dofs; global_dof];
end

free_dofs = setdiff(global_dofs, supported_dofs); % e.g. [3,5,6,7,8]