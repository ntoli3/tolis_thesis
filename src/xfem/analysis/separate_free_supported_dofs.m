function [free_dofs, supported_dofs] = separate_free_supported_dofs(...
    num_dofs_all, dof_order, supports)
% Taxinomei kai prosdiorizei toys eleytherous kai desmeymenous dofs toy FEM model
% Input:
% num_dofs_all = total number of global DOFs in the model
% dof_order = matrix containing the global numbering of the DOFs for each node
% supports = matrix (num_supports x 2) containing the supported DOFs
% Output:
% free_dofs = dianysma poy periexei ta IDS twn free dofs
% supported_dofs = dianysma poy periexei ta IDS twn supported dofs
% dofs

supported_dofs = []; % e.g. [1,2,4]

for i = 1: size(supports, 1)
    node_id = supports(i, 1);
    dof_type = supports(i, 2);    
    global_dof = dof_order(node_id, dof_type);
    supported_dofs = [supported_dofs; global_dof];
end

global_dofs = 1 : num_dofs_all; % e.g. [1,2,3,4,5,6,7,8]
free_dofs = setdiff(global_dofs, supported_dofs); % e.g. [3,5,6,7,8]

end