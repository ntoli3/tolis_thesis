function [global_dofs] = element_to_global_dofs(...
  element_nodes, element_id, dofs_per_node)

% Ypologizei ta katholika DOFS enos peperasmenoy stoixeioy me vasi ta IDS
% twn komvon twn stoixeiwn
% Input: 
% element_nodes = 
% element_id = arithmos ID toy stoixeiou gia to opoio theloyme ta DOFS
% dofs_per_node = arithmos vathmwn eleytherias ana komvo 
% Output: 
% global_dofs = katholikoi deiktes DOFS gia to stoixeio

  num_nodes = size(element_nodes, 2);
  global_dofs = zeros(1, dofs_per_node * num_nodes);
  dof = 0;
  for n = 1: num_nodes
    node_id = element_nodes(element_id, n);
    for dof_type = 1 : dofs_per_node
        % For ux in 2D: global_dof = 2 * node_id - 1;
        % For uy in 2D: global_dof = 2 * node_id;
        % For ux in 3D: global_dof = 3 * node_id - 2;
        % For uy in 3D: global_dof = 3 * node_id - 1;
        % For uz in 3D: global_dof = 3 * node_id
        dof = dof + 1;
        global_dofs(dof) = dofs_per_node * node_id  + dof_type - dofs_per_node;
    end
  end

end
