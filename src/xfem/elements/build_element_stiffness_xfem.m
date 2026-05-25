function [ke] = build_element_stiffness_xfem(element_id, node_coords, element_nodes, ...
    enriched_nodes_all, elements_category, intersected_elements, intersection_mesh, ...
    material_pos, material_neg, phi_nodes_all, psi_handle)
% Builds the stiffness matrix of an element
% Input:
% element_id = the ID of the target element
% Output:
% ke = the stiffness matrix of the target element

if obj.dimension ~= 2
    error('Not implemented yet')
end

% Find coordinates of the nodes of this element
nodes_of_element = zeros(4, 2);
node_ids = element_nodes(element_id,:);
for n = 1:4
    id = node_ids(n);
    coords = node_coords(id, :);
    nodes_of_element(n, :) = coords;
end

if elements_category(element_id) == 0 % Standard element
    % Choose material
    if intersected_elements(element_id) == 1 % Positive region
        material = material_pos;
    else % Negative region
        material = material_neg;
    end

    ke = quad4_stiffness(nodes_of_element, material.E, material.v, material.t);

else 
    % For the nodes of the element: a) level sets, b) are they standard/enriched
    nodal_level_sets = zeros(4, 1);
    standard_enriched_nodes = zeros(4,1);
    for n = 1:4
        id = node_ids(n);
        nodal_level_sets(n, 1) = phi_nodes_all(id, 1);
        standard_enriched_nodes(n, 1) = enriched_nodes_all(id, 1);
    end
    
    if elements_category(element_id) == 1 % Intersected element
        gauss_points = integration_with_subtriangles(element_id, intersection_mesh, 3);
    else % Blending element
        gauss_points = gauss_integration_quad4(2, 2);
    end

    ke = xquad4_stiffness(nodes, standard_enriched_nodes, material_pos, ...
        material_neg, nodal_level_sets, psi_handle, gauss_points);    
end

end