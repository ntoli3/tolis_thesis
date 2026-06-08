function [] = plot_displacements(fem_model, U_global, scale)

% Calculate deformed geometry
deformed_coords = fem_model.node_coords; % Coordinates of nodes + displacements
num_nodes = size(fem_model.node_coords, 1);
for n=1:num_nodes
    dof_x = 2 * n - 1;
    dof_y = 2 * n;
    ux = U_global(dof_x);
    uy = U_global(dof_y);
    deformed_coords(n, 1) = deformed_coords(n, 1) + ux * scale;
    deformed_coords(n, 2) = deformed_coords(n, 2) + uy * scale;
end

figure;
hold on;
axis equal;

% --- undeformed mesh ---
patch('Faces', fem_model.element_nodes, ...
      'Vertices', fem_model.node_coords, ...
      'FaceColor', 'none', ...
      'EdgeColor', [0.7 0.7 0.7], ...
      'LineStyle', '--');

% --- deformed mesh ---
patch('Faces', fem_model.element_nodes, ...
      'Vertices', deformed_coords, ...
      'FaceColor', 'none', ...
      'EdgeColor', 'b', ...
      'LineWidth', 1.5);

legend('Undeformed','Deformed');
title('Deformed FEM Mesh');
xlabel('x');
ylabel('y');

end