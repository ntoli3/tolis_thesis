function [Fe] = build_forces_vector_xfem(xfem_model)
% Builds the forces vectorize
% Inputs:
% xfem_model: object of XfemModel
% Output:
% Fe = dianysma exwterikwn fortiwn poy antistoixei sta free dofs toy
% systimatos

loads = xfem_model.loads;
dof_order = xfem_model.dof_order;

F = zeros(xfem_model.num_dofs_all, 1);
for i = 1: size(loads, 1)
  node_id = loads(i, 1);
  dof_type = loads(i, 2);
  dof_id = dof_order(node_id, dof_type);  
  F(dof_id, 1) = loads(i, 3);
end

Fe = F(xfem_mode.free_dofs);

end
