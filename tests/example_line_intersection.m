 close all; clear; clc;

% orismos diastasewn tou plegmatos
Nx = 5; %arithmos kombwn sth dieuthunsh x
Ny = 4; %arithmos kombwn sth dieuthunsh y

% orismos twn oriwn toy xwrou
x_min = 0;
x_max = 1;
y_min = 0;
y_max = 1;

% eutheia
x_l = 0.6;

[node_coords, element_nodes] = create_mesh(Nx, Ny, x_min, x_max, y_min, y_max);
[elem_intersected] = check_line_intersection(x_l, node_coords, element_nodes);
