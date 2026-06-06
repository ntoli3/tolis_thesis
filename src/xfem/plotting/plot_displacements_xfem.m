function [] = plot_displacements_xfem(xfem_model, U_global, scale)

dof_order = xfem_model.dof_order;

% Calculate deformed geometry
deformed_coords = xfem_model.node_coords; % Coordinates of nodes + displacements
num_nodes = size(xfem_model.node_coords, 1);
for n=1:num_nodes
    dof_x = dof_order(n, 1);
    dof_y = dof_order(n, 2);
    ux = U_global(dof_x);
    uy = U_global(dof_y);
    deformed_coords(n, 1) = deformed_coords(n, 1) + ux * scale;
    deformed_coords(n, 2) = deformed_coords(n, 2) + uy * scale;
end

f = figure;
hold on;
axis equal;

% --- undeformed mesh ---
patch('Faces', xfem_model.element_nodes, ...
      'Vertices', xfem_model.node_coords, ...
      'FaceColor', 'none', ...
      'EdgeColor', [0.7 0.7 0.7], ...
      'LineStyle', '--');

% --- deformed mesh: standard and blending elements ---
num_elements_total = length(xfem_model.intersected_elements);
num_intersected_elements = sum(xfem_model.intersected_elements == 0);
num_std_blending_elements = num_elements_total - num_intersected_elements;

std_blending_element_nodes = zeros(num_std_blending_elements, 4);
e = 0;
for element_id = 1 : num_elements_total
    e = e + 1;
    std_blending_element_nodes(e, :) = xfem_model.element_nodes(element_id, :);
end

patch('Faces', xfem_model.element_nodes, ...
      'Vertices', deformed_coords, ...
      'FaceColor', 'none', ...
      'EdgeColor', 'b', ...
      'LineWidth', 1.5);

legend('Undeformed','Deformed');
title('Deformed XFEM Mesh');
xlabel('x');
ylabel('y');

end