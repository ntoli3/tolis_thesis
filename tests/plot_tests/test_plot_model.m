close all; clear; clc;

% Create the models
xfem_model = create_cantilever_2halves();
xfem_model.initialize();
plot_model = PlotModel(xfem_model);
plot_model.initialize();

% Faster access of data structures
node_coords = xfem_model.node_coords;
element_nodes = xfem_model.element_nodes;
vertex_coords_cartesian = plot_model.vertex_coords_cartesian;
vertex_coords_natural = plot_model.vertex_coords_natural;
faces_of_vertices = plot_model.faces_of_vertices;
vertices_of_faces = plot_model.vertices_of_faces;
vertex_elements = plot_model.vertex_elements;
faces_of_elements = plot_model.faces_of_elements;
elements_of_faces = plot_model.elements_of_faces;
vertex_regions = plot_model.vertex_regions;
coincident_vertices = plot_model.coincident_vertices;
num_vertices = length(faces_of_vertices);
num_faces = length(elements_of_faces);


% 1st test: Vertex -> Face -> Vertex consistency
for v = 1:num_vertices
    f = faces_of_vertices(v);
    faceVerts = vertices_of_faces(f,:);
    faceVerts = faceVerts(~isnan(faceVerts));
    assert(any(faceVerts == v), ...
        'Vertex %d not found in parent face %d', v, f);
end
fprintf('Vertex -> Face -> Vertex test passed.\n');

% 2nd test: Vertex -> Element -> Face consistency
for v = 1:num_vertices
    e = vertex_elements(v);
    f = faces_of_vertices(v);
    assert(any(faces_of_elements{e} == f), ...
        'Vertex %d has incompatible face/element', v);
end
fprintf('Vertex -> Element -> Face test passed.\n');

% 3rd test: Face -> Element -> Face consistency
for f = 1 : num_faces
    e = elements_of_faces(f);
    assert(any(faces_of_elements{e} == f), ...
        'Face %d has incompatible element', f);
end
fprintf('Face -> Element test passed.\n');

% 4th check: Vertex coordinates
for v = 1:num_vertices
    xi = vertex_coords_natural(v,:);
    x_expected = vertex_coords_cartesian(v,:);
    e = vertex_elements(v);
    nodes = node_coords(element_nodes(e,:),:);
    N = quad4_shape_functions(xi);
    x = N * nodes;
    dist = norm(x - x_expected);
    assert(dist < 1e-8, 'Vertex %d has incompatible natural - cartesian coordinates', v);
end
fprintf('Vertex coordinates test passed.\n');

% 5th check: Coincident vertices symmetry
for v1 = 1:num_vertices
    group1 = coincident_vertices{v1}; 
    for i = 1 : length(group1)
        v2 = group1(i);
        group2 = coincident_vertices{v2};
        assert(isequal(group1, group2),...
            'Vertices %d, %d should belong to the same coincidence group', v1, v2);
    end
end
fprintf('Coincident vertices symmetry test passed.\n');

% 6th check: Coincident vertices coordinates
for v1 = 1:num_vertices
    x1 = vertex_coords_cartesian(v1,:);
    region1 = vertex_regions(v1);
    group1 = coincident_vertices{v1}; 
    for i = 1 : length(group1)
        v2 = group1(i);
        x2 = vertex_coords_cartesian(v2,:);
        region2 = vertex_regions(v2);
        dist = norm(x2 - x1);
        assert((dist < 1e-8) && (region1 == region2) ,...
            'Vertices %d, %d do not coincide, but are marked as such', v1, v2);
    end
end
fprintf('Coincident vertices coordinates test passed.\n');