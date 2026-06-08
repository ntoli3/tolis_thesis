function [node_ids] = find_nodes_with_y(target_y, fem_model)
% Epistrefei ta IDS twn nodes poy vriskontai se thesi me syntatagmeni y
% Input: 
% target_y = timi y poy psaxnoyme
% fem_model: Des create_fem_model()
% Output:
% node_ids = dianysma me ta IDS ton komvnon

dy = fem_model.mesh.element_length(2);
tol = dy / 10;
list = {};

num_nodes = size(fem_model.node_coords, 1);
for i = 1:num_nodes
    y = fem_model.node_coords(i, 2);
    if abs(y - target_y) < tol
        list{end+1} = i;
    end
end

node_ids = cell2mat(list);
end
