function [] = plot_volume_gauss_points(xfem_model, fig, color, point_size)
% Plots Gauss points of elements
% Input:
% xfem_model = object of XfemModel
% fig = figure handle
% color = text that describes the color. E.g. 'y' (yellow), 'r' (red), ...
% point_size = marker size for Gauss points

node_coords_all = xfem_model.node_coords;
element_nodes = xfem_model.element_nodes;
intersection_mesh = xfem_model.intersection_mesh;
intersected_elements = xfem_model.intersected_elements;
num_quad_gauss_points = xfem_model.num_quad_points;
num_subtriangle_gauss_points = xfem_model.num_subtriangle_points;

num_elements = size(element_nodes,1);
figure(fig)

for e = 1 : num_elements
    % Gauss points coords in natural system
    if intersected_elements(e) == 0
       xew = integration_with_subtriangles(e, intersection_mesh, num_subtriangle_gauss_points); % natural system
    else
       xew = gauss_integration_quad4(num_quad_gauss_points(1), num_quad_gauss_points(2));
    end
    
    % Coordinates of this element's nodes
    node_ids = element_nodes(e,:);
    node_coords_element = node_coords_all(node_ids, :);

    % Gauss points coords in cartesian system
    num_gauss_points = size(xew, 1);
    xy = zeros(num_gauss_points, 2);
    for i = 1 : num_gauss_points
        % x = sum( N(xi, eta) * x(node) )
        % y = sum( N(xi, eta) * y(node) )
        xi = xew(i, 1:2);
        N = quad4_shape_functions(xi);
        xy(i, :) = N * node_coords_element;
    end
    
    % Plot gauss points
    hold on
    %h = plot(xy(:,1), xy(:,2), 'x', 'Color', color, 'LineWidth', 2, 'MarkerSize', point_size);
    %h.Annotation.LegendInformation.IconDisplayStyle = 'off';
    h = plot(xy(:,1), xy(:,2), 'o', 'Color', color, 'MarkerFaceColor', color, 'MarkerSize', point_size);
    %legend(h, 'Gauss points')
end

end