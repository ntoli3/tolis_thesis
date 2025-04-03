function [phi_nodes]=initialize_lsm(node_coords,distance_func)
%selida 24/103
    phi_nodes=zeros(size(node_coords,1),1);
for i=1:size(node_coords,1)
    phi_nodes(i)=distance_func(node_coords(i,:));
end