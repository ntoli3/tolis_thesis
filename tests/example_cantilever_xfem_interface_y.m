close all; clear; clc;

% Problem properties
Lx = 20.0;
Ly = 4.0;
t = 0.1;
E_neg = 2E6;
E_pos = 200;
v = 0.3;
P = 500;

% Mesh (πχ 22x6, 44x12, 66x18)
nnx = 22; % zugos arithmos  
nny = 6; % zugos arithmos 
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
dx = Lx / (nnx - 1);
interface_position_x = Lx / 2;
phi_handle = @(x, y) x - interface_position_x;
psi_handle = @ramp_enr; % Π.χ. @ramp_enr, @sign_enr
model.describeLevelSetAndEnrichment(phi_handle, psi_handle);

% Run analysis
analysis = LinearStaticAnalysisXfem(model);
analysis.initialize();
U = analysis.run();
analysis.plotResults(U, 0.005);