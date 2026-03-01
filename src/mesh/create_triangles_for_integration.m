function [point_coords_list_cartesian, point_coords_list_natural, triangle_points_list] =...
    create_triangles_for_integration(...
    node_coords_all, element_nodes, phi_nodes_all)
% vriskei ta shmeia tomhs twn element me th level set kai dhmiourgei trigwna...
% mesw ths delaunay gia na kanoyme thn arithmitikh oloklhrwsh, douleuei...
% prwta se fysikes syntetagmenes kai meta tis metatrepei se kartesiano
% input:
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% element nodes = pinakas pou periexei toys kombous toy kathe element
% phi nodes all = pinakas poy exei tis level sets olwn twn kombwn toy plegmatos
% output: 
% triangle points list = lista ana stoixeio me arithish twn shmeiwn twn trigwnwn tou 
% point coords list cartesian = lista ana stoixeio me syntetagmenes(cartesian) twn shmeiwn twn trigwnwn tou 
% point coords list natural = lista ana stoixeio me syntetagmenes(natural) twn shmeiwn twn trigwnwn tou

[intersected_elements] = check_intersection_elements_lsm (phi_nodes_all, element_nodes);
num_elements = size(element_nodes,1);

triangle_points_list = cell(num_elements,1);
point_coords_list_natural = cell(num_elements,1);
point_coords_list_cartesian = cell(num_elements,1);

for e = 1 : num_elements
     if intersected_elements(e,1) == 0
        continue
     end

     % fisikes syntetagmenes
     node_coords_natural = [-1 -1;
                             1 -1;
                             1  1;
                            -1  1];

     % komboi toy stoixeioy
     node_coords_cartesian = zeros(4,2); 
     for j = 1 : 4
         n = element_nodes(e,j);
         node_coords_cartesian(j,1) = node_coords_all(n,1);
         node_coords_cartesian(j,2) = node_coords_all(n,2);
     end

   % ta phi stoys komboys
    phi_nodes_elem = zeros(4,1);
    for j = 1 : 4
        n = element_nodes(e,j);
        phi_nodes_elem(j,1) = phi_nodes_all(n,1);
    end

    % shmeia tomhs & trigonopoihsh
    [intersection_point_coords] = lsm_element_intersection( node_coords_natural,...
        phi_nodes_elem);
    point_coords_elem_natural = [node_coords_natural ; intersection_point_coords ] ;
    triangle_points_elem = delaunay(point_coords_elem_natural);

    % metasximatizw se cartesian
    num_points = size(point_coords_elem_natural,1);
    point_coords_elem_cartesian = zeros(num_points,2);
    for p = 1 : num_points
        xi = point_coords_elem_natural(p,1);
        eta = point_coords_elem_natural(p,2);
        [N] = compute_shape_functions(xi, eta);
        point_coords_elem_cartesian(p,:) = N * node_coords_cartesian;
    end

    % apothikevw ta dedomena toy element mesa stis synolikes listes
    triangle_points_list{e} = triangle_points_elem;
    point_coords_list_natural{e} = point_coords_elem_natural;
    point_coords_list_cartesian{e} = point_coords_elem_cartesian;
end
end