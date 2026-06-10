close all; clear; clc;

% Problem properties
Lx = 4.0;
Ly = 0.8;
t = 0.02;
E_pos = 30E6;
E_neg = 1E3 * E_pos;
v = 0.3;
P = 8;

% Mesh (πχ 6x2, 11x3, 21x5 22x6, 44x12, 66x18) % zugos arithmos 
nnx = 22;  
nny = 6;
model = XfemModel();
[mesh, node_coords, element_nodes] = create_mesh_quad4(nnx, nny, Lx, Ly);
model.setMesh(mesh, node_coords, element_nodes);
model.setMaterials(E_pos, v, E_neg, v, t);

% Supports
[nodes_left] = find_nodes_with_x(0.0, model);
for n = 1:length(nodes_left)
    node_id = nodes_left(n);
    model.addSupport(node_id, 1);
    model.addSupport(node_id, 2);
end

% Loads
[nodes_right] = find_nodes_with_x(Lx, model);
for n = 1:length(nodes_right)
    node_id = nodes_right(n);
    model.addLoad(node_id, 2, - P / length(nodes_right));
end

% Level set

% dx = Lx / (nnx - 1);
% interface_position_x = Lx/2; %Lx/2, 2.4
% phi_handle = @(x, y) x - interface_position_x;
% %phi_handle = @(x, y) interface_position_x - x;

x0 = [Lx/2, 0];
theta = pi/4;
phi_handle = @(x, y) (x - x0(1)).*sin(theta) - (y - x0(2)).*cos(theta);

% Enrichment
model.cohesive_interface = 1;
psi_func = RidgeEnrichment(); % Π.χ. RampEnrichment, SignEnrichment, RidgeEnrichment
model.describeLevelSetAndEnrichment(phi_handle, psi_func);

% Run analysis
model.initialize();

% Check areas
num_elements = size(model.element_nodes,1);
for e = 1 : num_elements
    if model.elements_category(e) ~= 1
        continue
    end
    gauss_points = integration_with_subtriangles(...
        e, model.intersection_mesh, model.num_subtriangle_points);
    sum_weights = sum(gauss_points(:,3));
    quad4_area = 4;
    tol = 1E-8;
    if abs(sum_weights - quad4_area) > tol
        error("Incorrect integration");
    end
end
