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

% Find how many non-zero entries exist in element stiffness matrices
num_elements = size(element_nodes, 1);
sparse_array_length = 0;
for e = 1:num_elements
    num_dofs_element = xfem_model.countElementDofs(e);
    sparse_array_length = sparse_array_length + num_dofs_element^2;
end

% Allocate sparse arrays
values = zeros(sparse_array_length, 1);
rows = zeros(sparse_array_length, 1);
columns = zeros(sparse_array_length, 1);

% Build global stiffness
idx = 0;
for e = 1:num_elements
    k_elem = xfem_model.buildElementStiffness(e);
    num_rows_element = size(k_elem, 1);
    num_columns_element = size(k_elem, 1);

    element_to_global_dofs = element_to_global_dofs_xfem(...
        e, element_nodes, enriched_nodes, dof_order);

    % Add element matrix to global matrix
    for i = 1:num_rows_element
        for j = 1:num_columns_element
            idx = idx + 1;
            rows(idx) = element_to_global_dofs(i);
            columns(idx) = element_to_global_dofs(j);
            values(idx) = k_elem(i, j);
        end
    end
end

K = sparse(rows, columns, values, num_dofs_all, num_dofs_all);
Kee = K(free_dofs, free_dofs);

end
