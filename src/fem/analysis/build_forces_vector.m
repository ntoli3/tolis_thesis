function [Fe] = build_forces_vector(fem_model)
% Builds the forces vectorize
% Inputs:
% fem_model: object of FemModel
% Output:
% Fe = dianysma exwterikwn fortiwn poy antistoixei sta free dofs toy
% systimatos

dim = fem_model.dimension;
num_nodes = size(fem_model.node_coords, 1);
num_dofs = dim * num_nodes;
F = zeros(num_dofs, 1);
loads = fem_model.loads;

for i = 1: size(loads, 1)
  node_id = loads(i, 1);
  axis = loads(i, 2);

  % For ux in 2D: global_dof = 2 * node_id - 1;
  % For uy in 2D: global_dof = 2 * node_id;
  % For ux in 3D: global_dof = 3 * node_id - 2;
  % For uy in 3D: global_dof = 3 * node_id - 1;
  % For uz in 3D: global_dof = 3 * node_id
  dof = dim * node_id  + axis-dim;

  F(dof, 1) = loads(i, 3);
end

Fe = F(fem_model.free_dofs);

end
