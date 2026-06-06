function [u] = calc_displacements_xfem(natural_coords, element_id, u_elem, ...
    element_nodes, elements_category, enriched_nodes_all, phi_nodes_all, psi_handle)
% Calculate the displacements at a specific point inside an element.
% Input:
% Output:
% u = 2x1 vector with the displacements of the target point

if elements_category(element_id) == 0 % Standard element
    u = quad4_displacements(natural_coords, u_elem);
else
    %TODO: this should be a model private method. It is very useful
    % For the nodes of the element: a) level sets, b) are they standard/enriched
    nodal_level_sets = zeros(4, 1);
    standard_enriched_nodes = zeros(4,1);
    for n = 1:4
        node_id = element_nodes(element_id, n);
        nodal_level_sets(n, 1) = phi_nodes_all(node_id, 1);
        standard_enriched_nodes(n, 1) = enriched_nodes_all(node_id, 1);
    end
    %TODO: up to here

    u = xquad4_displacements(natural_coords, standard_enriched_nodes, ...
        u_elem, nodal_level_sets, psi_handle);
end

end