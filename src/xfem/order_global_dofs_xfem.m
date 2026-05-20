function [dof_order, num_dofs_all] = order_global_dofs_xfem(enriched_nodes)
% Assigns global DOF numbering for an XFEM model
% Input:
% enriched_nodes = vector (num_nodes x 1) indicating whether each node is enriched...
%   enriched_nodes(i) = 0 -> standard FEM node
%   enriched_nodes(i) = 1 -> XFEM enriched node
% Output:
% dof_order = matrix (num_nodes x 4) containing the global numbering...
%   of the degrees of freedom (DOFs) for each node
% num_dofs_all = total number of DOFs in the XFEM model.

num_nodes = length(enriched_nodes);
dof_order = zeros(num_nodes, 4);

counter = 0;
for n = 1:num_nodes
    if enriched_nodes(n) == 0 % Standard node has dofs: ux, uy
        counter = counter + 1;
        dof_order(n, 1) = counter;
        counter = counter + 1;
        dof_order(n, 2) = counter;
    else % Enriched node has dofs: ux, uy, enr_x, enr_y
        counter = counter + 1;
        dof_order(n, 1) = counter;
        counter = counter + 1;
        dof_order(n, 2) = counter;
        counter = counter + 1;
        dof_order(n, 3) = counter;
        counter = counter + 1;
        dof_order(n, 4) = counter;
    end
end

num_dofs_all = counter;

end