function [Kee] = build_global_stiffness_matrix_xfem(xfem_model) 
% Ypologizei kai xtizei ton synoliko pinaka dyskampsias K
% Input: 
% xfem_model = object of XfemModel
% Output: 
% Kee = synolikos pinakas dyskampsias gia eleutherous dofs

element_nodes = xfem_model.element_nodes;
enriched_nodes = xfem_model.enriched_nodes;
dof_order = xfem_model.dof_order;
num_dofs_all = xfem_model.num_dofs_all;
free_dofs = xfem_model.free_dofs;

% Dofs
num_elements = size(element_nodes, 1);
K = zeros(num_dofs_all, num_dofs_all);

% Element stiffness
for e = 1:num_elements
    k_elem = xfem_model.buildElementStiffness(e);
    elements_dofs = element_to_global_dofs_xfem(...
        e, element_nodes, enriched_nodes, dof_order);
    K(elements_dofs, elements_dofs) = K(elements_dofs, elements_dofs) + k_elem;
end

Kee = K(free_dofs, free_dofs);
end
