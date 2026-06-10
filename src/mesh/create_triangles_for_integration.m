function [intersection_mesh] = create_triangles_for_integration(...
    intersected_elements, node_coords_all, element_nodes, phi_nodes_all)
% vriskei ta shmeia tomhs twn element me th level set kai dhmiourgei trigwna...
% mesw ths delaunay gia na kanoyme thn arithmitikh oloklhrwsh, douleuei...
% prwta se fysikes syntetagmenes kai meta tis metatrepei se kartesiano
% Input:
% intersected_elements = pinakas poy periexei tin timi 0 an to element temnetai, 
%   1 an to element vrisketai sti perioxi phi>0, -1 an to element vrisketai sti perioxi phi<0
% node_coords_all = pinakas poy periexei tis syntetagmenes twn kombwn
% element_nodes = pinakas pou periexei toys kombous toy kathe element
% phi_nodes_all = pinakas poy exei tis level sets olwn twn kombwn toy plegmatos
% Output: 
% intersection_mesh: Des IntersectionMesh

num_elements = size(element_nodes,1);

triangle_points_list = cell(num_elements,1);
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
    intersection_point_coords = lsm_element_intersection(node_coords_natural, phi_nodes_elem);
    point_coords_elem_natural = [node_coords_natural ; intersection_point_coords ] ;
    point_coords_elem_natural = unique(point_coords_elem_natural, 'rows'); % Afairw dipla simeia
    
    % Dimiourgia trigwnwn
    if size(point_coords_elem_natural, 1) > 4 % sunithismeni periptwsi
        triangle_points_elem = delaunay(point_coords_elem_natural);
    else % spania periptwsi: i diepifaneia perna apo mia diagwnio
        point_coords_elem_natural = node_coords_natural;
        xi1 = intersection_point_coords(1, :);
        if isequal(xi1, [-1,-1]) || isequal(xi1, [1,1])
            triangle_points_elem = [1 3 4; 1 2 3];
        else
            triangle_points_elem = [1 2 4; 2 3 4];
        end
    end
    
    % Metasximatizw se cartesian
    num_points = size(point_coords_elem_natural,1);
    point_coords_elem_cartesian = zeros(num_points,2);
    for p = 1 : num_points
        xi = point_coords_elem_natural(p,:);
        N = quad4_shape_functions(xi);
        point_coords_elem_cartesian(p,:) = N * node_coords_cartesian;
    end

    % Apothikevw ta dedomena toy element mesa stis synolikes listes
    triangle_points_list{e} = triangle_points_elem;
    point_coords_list_natural{e} = point_coords_elem_natural;
    point_coords_list_cartesian{e} = point_coords_elem_cartesian;
end

intersection_mesh = IntersectionMesh( ...
    point_coords_list_cartesian, point_coords_list_natural, triangle_points_list);
end