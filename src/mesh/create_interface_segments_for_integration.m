function [intersection_segments] = create_interface_segments_for_integration(...
    intersected_elements, node_coords_all, element_nodes, phi_nodes_all)
% Vriskei ta shmeia tomhs twn element me th level set kai dhmiourgei euthigramma tmimata gia na 
% kanoyme thn arithmitikh oloklhrwsh.
% Input:
% intersected_elements = pinakas poy periexei tin timi 0 an to element temnetai, 
%   1 an to element vrisketai sti perioxi phi>0, -1 an to element vrisketai sti perioxi phi<0
% node_coords_all = pinakas poy periexei tis syntetagmenes twn kombwn
% element_nodes = pinakas pou periexei toys kombous toy kathe element
% phi_nodes_all = pinakas poy exei tis level sets olwn twn kombwn toy plegmatos
% Output: 
% intersection_segments: Des IntersectionSegments

num_elements = size(element_nodes,1);
point_coords_list_natural = cell(num_elements,1);
point_coords_list_cartesian = cell(num_elements,1);

for e = 1 : num_elements
    if intersected_elements(e,1) ~= 0
       continue
    end

     % Komboi toy stoixeiou se fisikes syntetagmenes
    node_coords_natural = [-1 -1;
                            1 -1;
                            1  1;
                           -1  1];

    % Komboi toy stoixeioy se cartesian syntetagmenes
    node_ids = element_nodes(e,:);
    node_coords_cartesian = node_coords_all(node_ids,:);

    % Level sets stoys komboys
    phi_nodes_elem = phi_nodes_all(node_ids);

    % Simeia tomhs
    point_coords_elem_natural = lsm_element_intersection(node_coords_natural, phi_nodes_elem);
    num_points = size(point_coords_elem_natural,1);
    if num_points ~= 2
        error('Not implemented yet');
    end
    
    % Metasximatizw se cartesian
    point_coords_elem_cartesian = zeros(num_points,2);
    for p = 1 : 2
        xi = point_coords_elem_natural(p,:);
        N = quad4_shape_functions(xi);
        point_coords_elem_cartesian(p,:) = N * node_coords_cartesian;
    end

    % Allazw fora wste to normal ne deixnei pros ta phi>0
    xi1 = point_coords_elem_natural(1,:)';
    xi2 = point_coords_elem_natural(2,:)';
    xim = 0.5 * (xi1 + xi2); % midpoint in natural
    x1 = point_coords_elem_cartesian(1,:);
    x2 = point_coords_elem_cartesian(2,:);
    t = x2 - x1; % tangent vector in cartesian
    n = [t(2); -t(1)]; % candidate normal vector in cartesian
    [N, dN_dx, dN_dxi, detJ] = quad4_shape_functions_derivatives(xim, node_coords_cartesian);
    grad_phi = dN_dx * phi_nodes_elem; % ∇φ
    if grad_phi' * n < 0 % n points to the region phi<0
        % Allazw fora
        point_coords_elem_natural = [point_coords_elem_natural(2,:); 
                                     point_coords_elem_natural(1,:)];
        point_coords_elem_cartesian = [point_coords_elem_cartesian(2,:); 
                                       point_coords_elem_cartesian(1,:)];
    end

    % Apothikevw ta dedomena toy element mesa stis synolikes listes
    point_coords_list_natural{e} = point_coords_elem_natural;
    point_coords_list_cartesian{e} = point_coords_elem_cartesian;
end

intersection_segments = IntersectionSegments( ...
    point_coords_list_cartesian, point_coords_list_natural);
end