close all; clear; clc;

% Problem properties
Lx = 20.0;
Ly = 4.0;
t = 0.1;
Eneg = 2E6;
Epos = 200;
v = 0.3;
P = 500;

% Mesh
nnx = 21;
nny = 5;
model = FemModel();
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
interface_position = Lx / 2 - dx/2;
phi = @(x, y) x - interface_position;
model.describeLevelSet(phi);

% Run analysis
analysis = LinearStaticAnalysis(model);
analysis.initialize();
U = analysis.run();
analysis.plotResults(U, 0.5);

% Check results
u_max = max(abs(U));
I = 1/12 * t * Ly^3;
u_expected = P*Lx^3 / (3*E*I);