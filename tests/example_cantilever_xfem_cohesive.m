close all; clear; clc;

% Problem properties
Lx = 4.0;
Ly = 0.8;
t = 0.02;
P = 8;
E_pos = 30E6;
E_neg = 1E3 * E_pos;
v = 0.3;
kn = 1E12;
kt = 1E6;

% Mesh (πχ 6x2, 11x3, 21x5 22x6, 44x12, 66x18) % zugos arithmos 
nnx = 6;  
nny = 2;
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

% Cohesive interface
lsm = LsmInterface();
interface_position_x = Lx / 2; %Lx/2, 2.4
phi_handle = @(x, y) x - interface_position_x;
lsm.addLevelSet(phi_handle);
psi_func = SignEnrichment(); % Π.χ. RampEnrichment, SignEnrichment, RidgeEnrichment
model.describeLevelSetAndEnrichment(lsm, psi_func);
model.setCohesiveInterface(kn, kt);

% Run analysis
analysis = LinearStaticAnalysisXfem(model);
analysis.initialize();
U = analysis.run();

% Plot results
plotter = XfemPlotter(model);
plotter.extrapolate_from_gauss_points = 0;
plotter.smoothing_type = 1; % 0 = no smoothing, 1 = averaging, 2 = weighted averaging
plotter.initialize();

gauss_point_size = 6;
enriched_node_size = 20;
normal_head_size = 1.5;
plotter.plotInitialGeometry(gauss_point_size, enriched_node_size, normal_head_size);

scale = 1E3;
plotter.plotDisplacements(U, scale);
plotter.plotStrainsStresses(U, scale);