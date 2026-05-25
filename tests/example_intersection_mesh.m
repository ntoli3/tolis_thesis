% orismos diastasewn tou plegmatos
Nx = 25; %arithmos kombwn sth dieuthunsh x
Ny = 20; %arithmos kombwn sth dieuthunsh y

% orismos twn oriwn toy xwrou
x_max = 5;
y_max = 4;

% kyklos
x_c = 2.5;
y_c = 2;
radius = 1; 

fig1 = figure();
plot_circle(x_c, y_c, radius, fig1);

[~, node_coords, element_nodes] = create_mesh_quad4(Nx, Ny, x_max, y_max);
phi_all = find_level_sets_circle(x_c, y_c, radius, node_coords);
plot_intersected_elements(node_coords, element_nodes, phi_all, fig1);

intersection_mesh = create_triangles_for_integration(...
    node_coords, element_nodes, phi_all);

fig2 = figure();
plot_circle(x_c, y_c, radius, fig2);
plot_intersection_triangles(node_coords, element_nodes, phi_all, ...
    intersection_mesh.point_coords_list_cartesian, ...
    intersection_mesh.triangle_points_list, fig2);