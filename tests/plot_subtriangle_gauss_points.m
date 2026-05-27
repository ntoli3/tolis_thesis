function [] = plot_subtriangle_gauss_points(node_coords_all, element_nodes,...
    phi_nodes_all, intersection_mesh, fig)
% sxediazei ta trigwna pou prokyptoun apo thn tomh twn stoixeiwn me thn kampylh 
% input:
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% element nodes = pinakas pou periexei toys kombous toy kathe element
% phi nodes all = pinakas(num_nodes,1) poy exei tis level sets olwn twn kombwn toy plegmatos
% intersection_mesh = intersectionMesh object containing the subtriangle information of intersected elements
% fig = o arithmos toy figure poy tha ginei h sxediash
% output:


[intersected_elements] = find_intersected_elements_lsm(phi_nodes_all, element_nodes);

% pgon = polyshape([x1 x2 x3 x4], [y1 y2 y3 y4]);
num_elements = size(element_nodes,1);
figure(fig)
for e = 1 : num_elements
    % Briskw gauss points sto natural system
    if intersected_elements(e) == 0
       xew = integration_with_subtriangles(e, intersection_mesh, 3); % natural system
    else
       xew = gauss_integration_quad4(2, 2);
    end
    
    % Coordinates of this element's nodes
    node_coords_element = zeros(4, 2);
    node_ids = element_nodes(e,:);
    for n = 1:4
        id = node_ids(n);
        coords = node_coords_all(id, :);
        node_coords_element(n, :) = coords;
    end

    % Briskw gauss points sto cartesian system
    num_gauss_points = size(xew, 1);
    xy = zeros(num_gauss_points, 2);
    for i = 1 : num_gauss_points
        % x = sum( N(xi, eta) * x(node) )
        % y = sum( N(xi, eta) * y(node) )
        xi = xew(i, 1);
        eta = xew(i, 2);
        N_shape = 1/4 * [(1-xi)*(1-eta) (1+xi)*(1-eta) (1+xi)*(1+eta) (1-xi)*(1+eta)];
        xy(i, :) = N_shape * node_coords_element;
    end
    
    % Sxediazw ta gauss points
    hold on
    plot(xy(:,1), xy(:,2), 'x', 'Color', 'y', 'LineWidth', 2, ...
        'MarkerSize', 4);
end

end