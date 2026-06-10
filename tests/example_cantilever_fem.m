close all; clear; clc;

Lx = 4.0;
Ly = 0.8;
t = 0.02;
E = 30E6;
v = 0.3;
P = 8;

model = FemModel();
[mesh, node_coords, element_nodes] = create_mesh_quad4(22, 6, Lx, Ly);
model.setMesh(mesh, node_coords, element_nodes);
model.setMaterial(E, v, t);

[nodes_left] = find_nodes_with_x(0.0, model);
for n = 1:length(nodes_left)
    node_id = nodes_left(n);
    model.addSupport(node_id, 1);
    model.addSupport(node_id, 2);
end

[nodes_right] = find_nodes_with_x(Lx, model);
for n = 1:length(nodes_right)
    node_id = nodes_right(n);
    model.addLoad(node_id, 2, - P / length(nodes_right));
end

analysis = LinearStaticAnalysisFem(model);
analysis.initialize();
U = analysis.run();
analysis.plotResults(U, 1000);

% Check results
u_max = max(abs(U));
I = 1/12 * t * Ly^3;
u_expected = P*Lx^3 / (3*E*I);