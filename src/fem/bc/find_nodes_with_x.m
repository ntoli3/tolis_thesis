function [node_ids] = find_nodes_with_x(target_x, fem_model)
% Epistrefei ta IDS twn nodes poy vriskontai se thesi me syntatagmeni x
% Input: 
% target_x = timi x poy psaxnoyme 
% fem_model: Des define_fem_model()
% Output: 
% node_ids = dianysma me ta IDS ton komvnon 

dx = fem_model.mesh.element_length(1);
tol = dx / 10;
list = {};

num_nodes = size(fem_model.node_coords, 1);
for i = 1: num_nodes
  x = fem_model.node_coords(i, 1);
  if abs(x - target_x) < tol
    list{end+1} = i;
  end
end

node_ids = cell2mat(list);
end
