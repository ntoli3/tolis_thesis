close all; clear; clc;

% Problem properties
Lx = 4.0;
Ly = 0.8;
t = 0.02;
E_pos = 200E6;
E_neg = 1E2 * E_pos;
v = 0.3;
P = 50;

% Mesh (πχ 16x4, 32x8, 48x12, 64x16 ...), % zugos arithmos  
nnx = 32; 
nny = 8;  
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
node_bottom_right = find_single_node_with_xy(Lx, 0, model);
model.addLoad(node_bottom_right, 2, -P);
node_top_right = find_single_node_with_xy(Lx, Ly, model);
model.addLoad(node_top_right, 2, P);

% Level set
lsm = LsmInterface();
% interface_position_x = Lx / 2;
% phi_handle = @(x, y) x - interface_position_x;
interface_position_y = Ly / 2;
phi_handle = @(x, y) y - interface_position_y;
lsm.addLevelSet(phi_handle);

% Enrichment
psi_func = SignEnrichment(); % Π.χ. RampEnrichment, SignEnrichment, RidgeEnrichment
model.describeLevelSetAndEnrichment(lsm, psi_func);

% Run analysis
analysis = LinearStaticAnalysisXfem(model);
analysis.initialize();
U = analysis.run();

% Plot results
plotter = XfemPlotter(model);
plotter.initialize();

gauss_point_size = 2;
enriched_node_size = 10;
normal_head_size = 1.5;
plotter.plotInitialGeometry(gauss_point_size, enriched_node_size, normal_head_size);

scale = 2E1;
plotter.plotDisplacements(U, scale);
plotter.plotStrainsStresses(U, 1, scale);