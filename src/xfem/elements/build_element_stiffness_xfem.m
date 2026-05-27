function [ke] = build_element_stiffness_xfem(element_id, node_coords, element_nodes, ...
    enriched_nodes_all, elements_category, intersected_elements, intersection_mesh, ...
    material_pos, material_neg, phi_nodes_all, psi_handle)
% Builds the stiffness matrix of an element
% Input:
% element_id = the ID of the target element
% node_coords: matrix (num_nodes x 2) containing the global coordinates of all nodes
% element_nodes: connectivity matrix (num_elements x num_nodes_per_element)
% enriched_nodes_all: vector (num_nodes x 1) indicating if each node is enriched. 0 -> standard node. 1 -> enriched node
% elements_category: vector (num_elements x 1) that classifies each element.  0 -> standard element. 1 -> intersected element. 2 -> blending element
% intersected_elements: vector (num_elements x 1) describing the position of each element with respect to the interface.
% intersection_mesh:  data structure containing information about the intersection between the interface and the finite element mesh.
% material_pos: material properties for the positive level-set region, phi > 0.
% material_neg: material properties for the negative level-set region, phi < 0.
% phi_nodes_all: vector (num_nodes x 1) containing the level-set value phi at every node of the mesh.
% psi_handle: handle to the enrichment function psi. This function is used inside the XFEM stiffness computation.
% Output:
% ke = the stiffness matrix of the target element

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

    ke = quad4_stiffness(nodes_of_element, material.E, material.v, material.thickness);

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

    ke = xquad4_stiffness(nodes_of_element, standard_enriched_nodes, material_pos, ...
        material_neg, nodal_level_sets, psi_handle, gauss_points);    
end

end