clc; close all; clear all;

% orismos diastasewn tou plegmatos
Nx = 5; %arithmos kombwn sth dieuthunsh x
Ny = 4; %arithmos kombwn sth dieuthunsh y

% orismos twn oriwn toy xwrou
x_min = 0;
x_max = 1;
y_min = 0;
y_max = 1;

[node_coords, element_nodes] = create_mesh(Nx, Ny, x_min, x_max, y_min, y_max);
node_lsm = compute_distance_from_circle(0.5, 0.5, 0.25, node_coords);

