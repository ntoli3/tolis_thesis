function [] = plot_interface_gauss_points(xfem_model, fig, color, point_size)
% Plots Gauss points on intersection segments
% input:
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% element nodes = pinakas pou periexei toys kombous toy kathe element
% phi nodes all = pinakas(num_nodes,1) poy exei tis level sets olwn twn kombwn toy plegmatos
% intersection_segments = object of IntersectionSegments
% fig = figure handle
% color = text that describes the color. E.g. 'y' (yellow), 'r' (red), ...
% point_size = marker size for Gauss points

node_coords_all = xfem_model.node_coords;
element_nodes = xfem_model.element_nodes;
intersection_segments = xfem_model.intersection_segments;
intersected_elements = xfem_model.intersected_elements;
num_segment_gauss_points = xfem_model.num_interface_segment_points;

num_elements = size(element_nodes,1);
figure(fig)

for e = 1 : num_elements
    % Gauss points coords in natural system
    if abs(intersected_elements(e)) == 1 % only plot for cut/tangent elements
       continue
    end

    xew = integration_on_interface_segments(e, intersection_segments, num_segment_gauss_points); % natural system
    
    % Coordinates of this element's nodes
    node_ids = element_nodes(e,:);
    node_coords_element = node_coords_all(node_ids, :);

    % Gauss points coords in cartesian system
    num_gauss_points = size(xew, 1);
    xy = zeros(num_gauss_points, 2);
    for i = 1 : num_gauss_points
        xi = xew(i, 1:2);
        N = quad4_shape_functions(xi);
        xy(i, :) = N * node_coords_element;
    end
    
    % Plot gauss points
    hold on
    h = plot(xy(:,1), xy(:,2), 'o', 'Color', color, 'MarkerFaceColor', color, 'MarkerSize', point_size);
    %legend(h, 'Interface Gauss points')
end

end