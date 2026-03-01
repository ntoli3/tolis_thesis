function [phi_nodes_all] = find_level_sets_circle(x_c, y_c, radius, node_coords_all)
% ypologizei tis level sets (gia kyklo) olwn twn kombwn toy plegmatos 
% input : 
% xc = to x toy kentroy toy kykloy
% yc = to y toy kentroy toy kykloy
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% output : 
% phi nodes all = pinakas (num_nodes,1) poy exei tis level sets olwn twn kombwn toy plegamtos

num_nodes = size(node_coords_all,1);
phi_nodes_all = zeros(num_nodes,1);

for n = 1 : num_nodes
    x = node_coords_all(n,1); % einai to x toy kombou
    y = node_coords_all(n,2); % einai to y toy kombou

    phi = sqrt((x-x_c)^2 + (y-y_c)^2) - radius;
    phi_nodes_all(n,1) = phi;
end
end