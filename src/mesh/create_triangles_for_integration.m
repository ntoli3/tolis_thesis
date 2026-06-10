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

%[intersected_elements] = find_intersected_elements_lsm(phi_nodes_all, element_nodes);
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
     node_coords_cartesian = zeros(4,2); 
     for j = 1 : 4
         n = element_nodes(e,j);
         node_coords_cartesian(j,1) = node_coords_all(n,1);
         node_coords_cartesian(j,2) = node_coords_all(n,2);
     end

   % Level sets stoys komboys
    phi_nodes_elem = zeros(4,1);
    for j = 1 : 4
        n = element_nodes(e,j);
        phi_nodes_elem(j,1) = phi_nodes_all(n,1);
    end

    % Simeia tomhs & trigonopoihsh
    [intersection_point_coords] = lsm_element_intersection( node_coords_natural,...
        phi_nodes_elem);
    point_coords_elem_natural = [node_coords_natural ; intersection_point_coords ] ;
    point_coords_elem_natural = unique(point_coords_elem_natural, 'rows'); % Afairw dipla simeia 
    triangle_points_elem = delaunay(point_coords_elem_natural);

    % Metasximatizw se cartesian
    num_points = size(point_coords_elem_natural,1);
    point_coords_elem_cartesian = zeros(num_points,2);
    for p = 1 : num_points
        xi = point_coords_elem_natural(p,1);
        eta = point_coords_elem_natural(p,2);
        [N] = quad4_shape_functions([xi eta]);
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