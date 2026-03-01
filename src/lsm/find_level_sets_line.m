function [phi_nodes_all] = find_level_sets_line(x_l, node_coords_all)
% ypologizei tis level sets (gia eutheia) olwn twn kombwn toy plegmatos 
% input : 
% xl = to x ths eutheias
% node coords all = pinakas poy periexei tis syntetagmenes tvn kombwn toy plegamtos
% output : 
% phi nodes all = pinakas (num_nodes,1) poy exei tis level sets olwn twn n-kombwn toy plegamtos

num_nodes = size(node_coords_all,1);
phi_nodes_all = zeros(num_nodes,1);

for i = 1 : num_nodes
    x = node_coords_all(n,1); % einai to x toy kombou

    phi = x - x_l;
    phi_nodes_all(n,1) = phi;
end
end