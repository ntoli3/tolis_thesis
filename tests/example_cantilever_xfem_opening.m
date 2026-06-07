close all; clear; clc;

% Problem properties
Lx = 20.0;
Ly = 4.0;
t = 0.1;
E_neg = 2E3;
E_pos = 2E2;
v = 0.3;
P = 50;

% Mesh (πχ 22x6, 44x12, 66x18)
nnx = 16; % zugos arithmos  
nny = 4; % zugos arithmos 
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
% interface_position_x = Lx / 2;
% phi_handle = @(x, y) x - interface_position_x;
interface_position_y = Ly / 2;
phi_handle = @(x, y) y - interface_position_y;
psi_handle = @sign_enr; % Π.χ. @ramp_enr, @sign_enr
model.describeLevelSetAndEnrichment(phi_handle, psi_handle);

% Run analysis
analysis = LinearStaticAnalysisXfem(model);
analysis.initialize();
U = analysis.run();

% Plot results
plotter = XfemPlotter(model);
plotter.initialize();
fig = figure;
plotter.plotInitialStructure(fig);
%plotter.plotGaussPoints(fig)
plotter.plotDeformedStructure(U, fig, 5E-4);
plotter.plotStrainsStresses(U, 1, 5E-4);