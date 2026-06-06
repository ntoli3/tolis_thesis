classdef XfemPlotter < handle
    % Represents vertices and faces that correspond to nodes and elements
    % of the FEM element, but are intended for plotting diconstinuous
    % fields
    
    properties
        xfem_model; % The original model used in XFEM

        vertex_coords_cartesian; % num_vertices x 2
        vertex_coords_natural; % num_vertices x 2
        vertex_elements; % num_vertices x 1
        vertex_regions; % num_vertices x 1: 1 for positive, -1 for negative

        vertices_of_faces; % num_faces x 4. For triangles the 4th column has NaN
        
        % Column vector with one entry per face. For each face, the id of
        % its parent element is stored.
        elements_of_faces;

        % Cell array with one entry per element. For each element a row 
        % vector array is stored, which contains the ids of the child-faces
        % corresponding to this element. These face ids are indices of 
        % elements_of_faces and vertices_of_faces.
        faces_of_elements;

        coincident_vertices; % cell array with 1 row vector per group of vertices that coincide

    end

    methods
        function obj = XfemPlotter(xfem_model)
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
        end

        function plotInitialStructure(obj, fig)
            % Plot the structure with nodes being translated proportionally
            % to their displacements
            % Input:
            % fig = figure handle
            % scale = proportionality coefficient. 1 = same as real
            %   displacements

            ax = obj.getAxes(fig);
            h = patch(ax, 'Faces', obj.xfem_model.element_nodes, ...
              'Vertices', obj.xfem_model.node_coords, ...
              'FaceColor', 'none', ...
              'EdgeColor', [0.7 0.7 0.7], ...
              'LineStyle', '--');
            h.DisplayName = 'Undeformed';
            legend(ax,'show');
        end

        function plotDeformedStructure(obj, U_global, fig, scale)
            % Plot the structure with nodes being translated proportionally
            % to their displacements
            % Input:
            % U_global = global displacements
            % fig = figure handle
            % scale = proportionality coefficient. 1 = same as real
            %   displacements
            
            % Calculate coordinates of the vertices in the deformed
            % structure
            num_vertices = size(obj.vertex_coords_cartesian, 1);
            vertices_coords_deformed = zeros(num_vertices, 2);
            for v = 1 : num_vertices
                x = obj.vertex_coords_cartesian(v,:);
                xi = obj.vertex_coords_natural(v,:);
                elem = obj.vertex_elements(v,:);
                u = obj.xfem_model.calcDisplacementsAt(elem, xi, U_global);
                vertices_coords_deformed(v,:) = x + scale * u';
            end
            
            % Plot
            ax = obj.getAxes(fig);
            h = patch(ax, 'Faces', obj.vertices_of_faces, ...
              'Vertices', vertices_coords_deformed, ...
              'FaceColor', 'none', ...
              'EdgeColor', 'b', ...
              'LineWidth', 1.5);
            h.DisplayName = 'Deformed';
            legend(ax,'show');
        end
        
        function plotGaussPoints(obj, fig)
            % Plot the gauss point at their coordinates in the undeformed 
            % structure
            % Input:
            % fig = figure handle

            plot_subtriangle_gauss_points(obj.xfem_model.node_coords, ...
                obj.xfem_model.element_nodes, obj.xfem_model.phi_nodes_all, ...
                obj.xfem_model.intersection_mesh, fig);
        end

        function plotStressesDeformed(obj, scale)

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
                obj.vertex_elements(end+1,1) = element_id;
                obj.vertex_regions(end+1,1) = region;
            end
            
            % The last 4 vertices belong to this face
            last = size(obj.vertex_coords_cartesian, 1);
            obj.vertices_of_faces(end+1, :) = last-3 : last;
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
                    point = triangle_points(t, v);
                    obj.vertex_coords_cartesian(end+1,:) = point_coords_cartesian(point,:);
                    obj.vertex_coords_natural(end+1,:) = point_coords_natural(point,:);
                    obj.vertex_elements(end+1,1) = element_id;
                    obj.vertex_regions(end+1,1) = region;
                end
                
                % The last 3 vertices belong to this face + 1 padding
                last = size(obj.vertex_coords_cartesian, 1);
                obj.vertices_of_faces(end+1, :) = [last-2 : last, NaN];
            end
        end

        function ax = getAxes(~, fig)
            ax = findobj(fig, 'Type', 'axes');
            if isempty(ax)
                ax = axes(fig);
                hold(ax,'on');
                axis(ax,'equal');
                xlabel(ax,'x');
                ylabel(ax,'y');
            else
                ax = ax(1);
            end
    end

    end
end