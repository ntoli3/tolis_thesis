classdef PlotModel < handle
    % Represents vertices and faces that correspond to nodes and elements
    % of the FEM element, but are intended for plotting diconstinuous
    % fields
    
    properties
        xfem_model; % The original model used in XFEM
        offset_ratio = 1E-8; % Points will be slighlty offset to avoid lying on the LSM interface

        vertex_coords_cartesian; % num_vertices x 2
        vertex_coords_natural; % num_vertices x 2
        vertex_elements; % num_vertices x 1
        vertex_regions; % num_vertices x 1: 1 for positive, -1 for negative

        vertices_of_faces; % num_faces x 4. For triangles the 4th column has NaN
        faces_of_vertices; % num_vertices x 1

        % Column vector with one entry per face. For each face, the id of
        % its parent element is stored.
        elements_of_faces;

        % Cell array with one entry per element. For each element a row 
        % vector array is stored, which contains the ids of the child-faces
        % corresponding to this element. These face ids are indices of 
        % elements_of_faces and vertices_of_faces.
        faces_of_elements;

        element_neighbors; % cell array with 1 row vector per element, containing the ids of all neighboring elements 

        coincident_vertices; % cell array with 1 row vector per group of vertices that coincide
        vertex_smoothing_weights; % num_vertices x 1

    end

    methods
        function obj = PlotModel(xfem_model)
            % Constructor
            % Input:
            % xfem_model = The original model used in XFEM
            
            obj.xfem_model = xfem_model;
        end

        function initialize(obj)
            % Initializes the vertices and faces needed for plotting
            
            % Access data needed from XfemModel
            %node_coords = obj.xfem_model.node_coords;
            element_nodes = obj.xfem_model.element_nodes;
            num_elements = size(element_nodes, 1);
            intersected_elements = obj.xfem_model.intersected_elements;
            
            % Initialize structures. All original nodes become vertices 
            % with the same id. The new ones will be numbered afterwards.
            obj.vertex_coords_cartesian = zeros(0, 2);
            obj.vertex_coords_natural = zeros(0, 2);
            obj.vertex_elements = zeros(0, 1);
            obj.vertex_regions = zeros(0, 1);
            obj.elements_of_faces = zeros(0, 1);
            obj.vertices_of_faces = zeros(0, 4);
            obj.faces_of_vertices = zeros(0, 1);
            obj.faces_of_elements = cell(num_elements, 1);
            %obj.coincident_vertices = cell(0, 1); %TODO later for averaging
            
            % Process each element
            for e = 1 : num_elements
                if intersected_elements(e) == 0 
                    obj.addIntersectedElement(e);
                else
                    obj.addStdElement(e);
                end
            end
            
            obj.findElementNeighbors();
            obj.findCoincidentVertices();
            obj.findSmoothingWeights();
        end
    end

    methods (Access = private)
        function addStdElement(obj, element_id)
            % Intersected element -> use 1 Quad4 face
            element_nodes = obj.xfem_model.element_nodes;
            node_coords = obj.xfem_model.node_coords;
            quad4_natural_coords = [-1 -1; 1 -1; 1 1; -1 1];
            
            face_id = length(obj.elements_of_faces) + 1;
            obj.faces_of_elements{element_id} = [face_id];
            obj.elements_of_faces(end+1,1) = element_id;
            
            % Decide the region based on the centroid
            centroid = [0 0];
            phiCentroid = obj.xfem_model.interpolateLevelSets(element_id, centroid);
            region = sign(phiCentroid);

            % Create a new vertex for each node
            for n = 1 : 4
                node_id = element_nodes(element_id, n);              
                obj.vertex_coords_cartesian(end+1,:) = node_coords(node_id,:);
                obj.vertex_coords_natural(end+1,:) = quad4_natural_coords(n,:);
                obj.vertex_regions(end+1,1) = region;
                obj.vertex_elements(end+1,1) = element_id;
                obj.faces_of_vertices(end+1,1) = face_id;
            end
            
            % The last 4 vertices belong to this face
            last_vertex = size(obj.vertex_coords_cartesian, 1);
            obj.vertices_of_faces(end+1, :) = last_vertex-3 : last_vertex;
        end

        function addIntersectedElement(obj, element_id)
            % Intersected element -> use multiple triangle faces
            intersection_mesh = obj.xfem_model.intersection_mesh;
            triangle_points = intersection_mesh.triangle_points_list{element_id};
            point_coords_cartesian = intersection_mesh.point_coords_list_cartesian{element_id};
            point_coords_natural = intersection_mesh.point_coords_list_natural{element_id};
            num_triangles = size(triangle_points, 1);
            
            % The next 4 faces belong to this element
            face_id = length(obj.elements_of_faces);
            obj.faces_of_elements{element_id} = face_id+1 : face_id+num_triangles;
            
            % For each triangle
            for t = 1 : num_triangles
                face_id = face_id + 1;
                obj.elements_of_faces(end+1,1) = element_id;
                
                % Decide the region based on the centroid
                centroid = [0 0];
                for v = 1 : 3
                    point = triangle_points(t, v);
                    xi_eta = point_coords_natural(point,:);
                    centroid = centroid + xi_eta;
                end
                centroid = centroid / 3;
                phiCentroid = obj.xfem_model.interpolateLevelSets(element_id, centroid);
                region = sign(phiCentroid);

                % Create a new vertex for each node
                for v = 1 : 3
                    % Slightly offset the point to avoid falling exactly on the interface
                    point = triangle_points(t, v);
                    p = point_coords_natural(point,:);
                    p = p + obj.offset_ratio * (centroid-p); 
                    
                    obj.vertex_coords_natural(end+1,:) = p;
                    obj.vertex_coords_cartesian(end+1,:) = point_coords_cartesian(point,:);
                    obj.vertex_regions(end+1,1) = region;
                    obj.vertex_elements(end+1,1) = element_id;
                    obj.faces_of_vertices(end+1,1) = face_id;
                end
                
                % The last 3 vertices belong to this face + 1 padding
                last_vertex = size(obj.vertex_coords_cartesian, 1);
                obj.vertices_of_faces(end+1, :) = [last_vertex-2 : last_vertex, NaN];
            end
        end

        function findCoincidentVertices(obj)
            num_vertices = length(obj.vertex_regions);
            obj.coincident_vertices = cell(num_vertices, 1);
            for vertex_id = 1 : num_vertices
                if ~isempty(obj.coincident_vertices{vertex_id})
                    continue; % Already belongs to a group
                end
                
                % Find nearby vertices
                containing_elem = obj.vertex_elements(vertex_id);
                neighbor_elements = obj.element_neighbors{containing_elem};
                neighbor_vertices = [];
                for e = 1 : length(neighbor_elements)
                    element_id = neighbor_elements(e);
                    faces = obj.faces_of_elements{element_id};
                    for f = 1 : length(faces)
                        face_id = faces(f);
                        vertices = obj.vertices_of_faces(face_id,:);
                        if isnan(vertices(4))
                            vertices = vertices(1:3);
                        end
                        neighbor_vertices = [neighbor_vertices vertices];
                    end
                end
                
                % Scan nearby vertices and find which ones coincide with 
                % the target vertex and are in the same region
                region1 = obj.vertex_regions(vertex_id);
                p1 = obj.vertex_coords_cartesian(vertex_id, :);
                avg_diagonal = obj.calcAvgElementDiagonal(neighbor_elements);
                tol = 1E-8 * avg_diagonal;
                group = [vertex_id];
                for v = 1 : length(neighbor_vertices)
                    other_vertex_id = neighbor_vertices(v);
                    region2 = obj.vertex_regions(other_vertex_id);
                    p2 = obj.vertex_coords_cartesian(other_vertex_id, :);
                    dist_p1p2 = norm(p2 - p1);
                    if (dist_p1p2 < tol) && (region1 == region2) 
                        % This vertex coincides with the target one
                        group(1,end+1) = other_vertex_id;
                    end
                end
                
                % Store this group of coincident vertices
                group = unique(group);
                for v = 1 : length(group)
                    obj.coincident_vertices{group(v)} = group;
                end
            end
        end
        
        function findElementNeighbors(obj)
            element_nodes = obj.xfem_model.element_nodes;
            num_elements = size(element_nodes, 1);
            obj.element_neighbors = cell(num_elements, 1);
            for e1_id = 1 : num_elements
                neighbors = [];
                e1_nodes = element_nodes(e1_id, :);
                % Find elements with least 1 common node
                for e2_id = 1 : num_elements
                    e2_nodes = element_nodes(e2_id, :);
                    common = intersect(e1_nodes, e2_nodes);
                    if ~isempty(common)
                        neighbors(1, end+1) = e2_id;
                    end
                end
                obj.element_neighbors{e1_id} = unique(neighbors);
            end
        end

        function findSmoothingWeights(obj)
            face_areas = obj.calcFaceAreas();

            num_vertices = length(obj.vertex_regions);
            obj.vertex_smoothing_weights = zeros(num_vertices, 1);
            for v = 1 : num_vertices
                face_id = obj.faces_of_vertices(v);
                Av = face_areas(face_id);
                other_vertices = obj.coincident_vertices{v};
                sumA = 0;
                for i = 1 : length(other_vertices)
                    other_vertex_id = other_vertices(i);
                    other_face_id = obj.faces_of_vertices(other_vertex_id);
                    Ai = face_areas(other_face_id);
                    sumA = sumA + Ai;
                end
                obj.vertex_smoothing_weights(v) = Av / sumA;
            end
        end

        function diagonal = calcAvgElementDiagonal(obj, element_ids)
            num_elements = size(element_ids, 1);
            sum = 0;
            for e = 1 : num_elements
                element_id = element_ids(e);
                nodes = zeros(4, 2);
                for n = 1 : 4
                    node_id = obj.xfem_model.element_nodes(element_id, n);
                    nodes(n, :) = obj.xfem_model.node_coords(node_id, :);
                end
                diagonal1 = norm(nodes(3,:) - nodes(1,:));
                diagonal2 = norm(nodes(4,:) - nodes(2,:));
                sum = 0.5 * (diagonal1 + diagonal2);
            end
            diagonal = sum / num_elements;
        end

        function [face_areas] = calcFaceAreas(obj)
            % Face areas in cartesian system
            num_faces = length(obj.elements_of_faces);
            face_areas = zeros(num_faces, 1);
            for f = 1 : num_faces
                vertices = obj.vertices_of_faces(f,:);
                if isnan(vertices(4)) % triangle
                    vertices = vertices(1:3);
                    x = obj.vertex_coords_cartesian(vertices, 1);
                    y = obj.vertex_coords_cartesian(vertices, 2);
                    A = 0.5*abs(x(1)*(y(2)-y(3)) + x(2)*(y(3)-y(1)) + x(3)*(y(1)-y(2)));
                else % quad4
                    x = obj.vertex_coords_cartesian(vertices, 1);
                    y = obj.vertex_coords_cartesian(vertices, 2);
                    A = abs((x(2) - x(1)) * (y(4)-y(1)));
                end
                face_areas(f) = A;
            end
        end

    end
end