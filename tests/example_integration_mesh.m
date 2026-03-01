% orismos diastasewn tou plegmatos
Nx = 25; %arithmos kombwn sth dieuthunsh x
Ny = 20; %arithmos kombwn sth dieuthunsh y

% orismos twn oriwn toy xwrou
x_min = 0;
x_max = 5;
y_min = 0;
y_max = 4;

% kyklos
x_c = 2.5;
y_c = 2;
radius = 1; 

fig1 = figure();
plot_circle(x_c, y_c, radius, fig1);

[node_coords, element_nodes] = create_mesh(Nx, Ny, x_min, x_max, y_min, y_max);
phi_all = find_level_sets_circle(x_c, y_c, radius, node_coords);
plot_intersected_elements(node_coords, element_nodes, phi_all, fig1);

[point_coords_list_cartesian, point_coords_list_natural, triangle_points_list] =...
    create_triangles_for_integration(...
    node_coords, element_nodes, phi_all);

fig2 = figure();
plot_circle(x_c, y_c, radius, fig2);
plot_intersection_triangles(node_coords, element_nodes,...
    phi_all, point_coords_list_cartesian, triangle_points_list, fig2)