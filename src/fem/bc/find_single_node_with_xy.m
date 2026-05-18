function [node_id] = find_single_node_with_xy(target_x, target_y, fem_model)
% Epistrefei to ID enos mono node poy vrisketai se thesi x,y entos mikris
% anoxis. Gia 2D provlimata.
% Input: 
% target_x = timi x poy psaxnoyme
% target_y = timi y poy psaxnoyme
% fem_model: Des create_fem_model()
% Output:
% node_id = dianysma me to ID tou zitoymenou komvnou

dx = fem_model.mesh.element_length(1);
dy = fem_model.mesh.element_length(2);
tol_x = dx / 10;
tol_y = dy / 10;
list = {};

num_nodes = size(fem_model.node_coords, 1);
for i = 1:num_nodes
    x = fem_model.node_coords(i, 1);
    y = fem_model.node_coords(i, 2);
    if abs(x - target_x) < tol_x && abs(y - target_y) < tol_y
        list{end+1} = i;
    end
end

if size(list) == 0
    ME = MException('Kanenas komvos me auta ta x,y');
    throw(ME);
elseif size(list) > 1
    ME = MException('Perissoteroi apo 1 komvoi me auta ta x,y');
    throw(ME);
else
    node_id = list{1};
end

end
