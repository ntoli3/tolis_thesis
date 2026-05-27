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

figure;
hold on;
axis equal;

% --- undeformed mesh ---
patch('Faces', xfem_model.element_nodes, ...
      'Vertices', xfem_model.node_coords, ...
      'FaceColor', 'none', ...
      'EdgeColor', [0.7 0.7 0.7], ...
      'LineStyle', '--');

% --- deformed mesh ---
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