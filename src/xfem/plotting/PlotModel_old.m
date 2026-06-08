classdef PlotModel_old < handle
    % Represents vertices and faces that correspond to nodes and elements
    % of the FEM element, but are intended for plotting diconstinuous
    % fields

    properties
        xfem_model; % The original model used in XFEM

        % Matrix with the coordinates of all unique vertices. Vertices that
        % lie on the interface are included twice, once for each side. The 
        % matrix has as many rows as there are vertices and 2 columns: x,y. 
        vertex_coords; 
        
        % Matrix that contains the vertices of all faces. 
        % Each row corresponds to one face and has 4 columns. Each
        % entry of that row is a row index into vertex_coords. For a
        % triangular face, NaN will be placed in the 4th column. 
        vertices_of_faces;
        
        % Cell array with one entry per vertex. For each vertex a row
        % vector is stored, which contains the ids of all faces that 
        % include this vertex. These face ids are row indices of 
        % vertices_of_faces and elements_of_faces.
        faces_of_vertices;

        % Cell array with one entry per element. For each element a row 
        % vector array is stored, which contains the ids of the child-faces
        % corresponding to this element. These face ids are indices of 
        % elements_of_faces and vertices_of_faces.
        faces_of_elements;
        
        % Column vector with one entry per face. For each face, the id of
        % its parent element is stored.
        elements_of_faces
    end

    methods
        function obj = PlotModel_old(xfem_model)
            % Constructor
            % Input:
            % xfem_model = The original model used in XFEM
            
            obj.xfem_model = xfem_model;
        end

        function initialize(obj)
            % Initializes the vertices and faces needed for plotting
            
            % Access data needed from XfemModel
            node_coords = obj.xfem_model.node_coords;
            element_nodes = obj.xfem_model.element_nodes;
            num_elements = size(element_nodes, 1);
            intersected_elements = obj.xfem_model.intersected_elements;
            
            % Initialize structures. All original nodes become vertices 
            % with the same id. The new ones will be numbered afterwards.
            obj.vertex_coords = node_coords;
            vertex_id = size(obj.vertex_coords, 1);
            obj.vertices_of_faces = zeros(0, 4);
            obj.faces_of_vertices = cell(vertex_id, 1);
            obj.faces_of_elements = cell(num_elements, 1);
            obj.elements_of_faces = zeros(0, 1);
            
            % Process each element
            for e = 1 : num_elements
                if intersected_elements(e) == 0 
                    % Intersected element -> use triangle faces
                else
                    % Standard or blending element -> use 1 quad face
                    obj.addStdElement(e);
                end
            end
        end

        function plotDeformedStructure(obj, scale)
            % Plot the structure with nodes being translated proportionally
            % to their displacements
            % Input:
            % scale = proportionality coefficient. 1 = same as real
            %   displacements

            figure;
            hold on;
            axis equal;

            patch('Faces', obj.vertices_of_faces, ...
              'Vertices', obj.vertex_coords, ...
              'FaceColor', 'none', ...
              'EdgeColor', [0.7 0.7 0.7], ...
              'LineStyle', '--');
        end

        function plotStressesDeformed(obj, scale)

        end
    end

    methods (Access = private)
        function addStdElement(obj, element_id)
            element_nodes = obj.xfem_model.element_nodes;
            
            face_id = length(obj.elements_of_faces) + 1;
            obj.faces_of_elements{element_id} = [face_id];
            obj.elements_of_faces(end+1, 1) = element_id;

            % Standard nodes have the same id as the corresponding vertices
            obj.vertices_of_faces(end+1, :) = element_nodes(element_id, :);
            
            % Also update faces_of_vertices
            for n = 1 : 4
                node_id = element_nodes(element_id, n);              
                obj.faces_of_vertices{node_id}(end+1) = face_id;
            end
        end

        function addIntersectedElement(obj, element_id)
            element_nodes = obj.xfem_model.element_nodes;

            obj.faces_of_elements{element_id} = [face_id];
            obj.elements_of_faces(end+1) = element_id;

            % Standard nodes have the same id as the corresponding vertices
            obj.vertices_of_faces(end+1, :) = element_nodes(element_id, :);
            
            % Also update faces_of_vertices
            for n = 1 : 4
                node_id = element_nodes(element_id, n);              
                obj.faces_of_vertices{node_id}(end+1) = face_id;
            end
        end
    end
end