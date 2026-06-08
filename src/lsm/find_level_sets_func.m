function [phi_all]=find_level_sets_func(node_coords,distance_func)
%selida 24/103
    phi_all=zeros(size(node_coords,1),1);
for i=1:size(node_coords,1)
    phi_all(i)=distance_func(node_coords(i,:));
end