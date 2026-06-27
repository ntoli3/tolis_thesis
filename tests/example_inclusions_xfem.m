close all; clear; clc;

% Problem properties
Lx = 4.0;
Ly = 2.0;
t = 0.02;
P = 8;
E_pos = 30E6;
E_neg = 1E3 * E_pos;
v = 0.3;
kn = 1E6;
kt = 1E6;

% Mesh (πχ 5x3, 9x5, 21x11, 41x21, 61x31) % zugos arithmos 
nnx = 21;  
nny = 11;
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
    model.addLoad(node_id, 1, P / length(nodes_right));
end

% Inclusion geometries
seed = 11; % find a nice shape and then do not change it
num_circles = 10;
max_radius = Ly / 5;
min_radius = max_radius / 2;
rng(seed);
Xc = Lx * rand(num_circles,1); % Random centers
Yc = Ly * rand(num_circles,1);
Rc = min_radius + (max_radius - min_radius) * rand(num_circles,1); % Random radii
circles = [Xc Yc Rc]; % Store circles
lsm = LsmInterface();
for i = 1 : num_circles
    xc = circles(i,1);
    yc = circles(i,2);
    r = circles(i,3);
    phi_handle = @(x, y) sqrt((x - xc)^2 + (y - yc)^2) - r;
    lsm.addLevelSet(phi_handle);
end
%lsm.addLevelSet(@(x, y) sqrt((x - Lx/2)^2 + (y - Ly/2)^2) - Ly/4)
% lsm.addLevelSet(@(x, y) sqrt((x - Lx/3)^2 + (y - Ly/2)^2) - Ly/5)
% lsm.addLevelSet(@(x, y) sqrt((x - Lx/2)^2 + (y - Ly/2)^2) - Ly/5)

% Enrichment
psi_func = SignEnrichment(); % Π.χ. RampEnrichment, SignEnrichment, RidgeEnrichment
model.describeLevelSetAndEnrichment(lsm, psi_func);
model.setCohesiveInterface(kn, kt);

% Run analysis
analysis = LinearStaticAnalysisXfem(model);
analysis.initialize();
U = analysis.run();

% Plot results
plotter = XfemPlotter(model);
plotter.initialize();

gauss_point_size = 2.5;
enriched_node_size = 20;
normal_head_size = 1.5;
plotter.plotInitialGeometry(gauss_point_size, enriched_node_size, normal_head_size);

scale = 1E3;
plotter.plotDisplacements(U, scale);
plotter.plotStrainsStresses(U, 1, scale);