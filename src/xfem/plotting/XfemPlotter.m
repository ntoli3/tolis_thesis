classdef XfemPlotter < handle
    % Plots engineering fields over an XFEM model
    
    properties
        xfem_model; % The original model used in XFEM
        plot_model; % The model of faces and vertices used for plotting
    end

    methods
        function obj = XfemPlotter(xfem_model)
            % Constructor
            % Input:
            % xfem_model = The original model used in XFEM
            
            obj.xfem_model = xfem_model;
        end

        function initialize(obj)
            % Initializes the data needed for plotting
            
            obj.plot_model = PlotModel(obj.xfem_model);
            obj.plot_model.initialize();
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
            
            % Calculate the displacmentes of the vertices
            num_vertices = size(obj.plot_model.vertex_coords_cartesian, 1);
            displacements = zeros(num_vertices, 2);
            for v = 1 : num_vertices
                xi = obj.plot_model.vertex_coords_natural(v,:);
                elem = obj.plot_model.vertex_elements(v,:);
                u = obj.xfem_model.calcDisplacementsAt(elem, xi, U_global);
                displacements(v,:) = u';
            end
            displacements = obj.averageField(displacements);

            % Calculate coordinates of the vertices in the deformed
            % structure
            vertices_coords_deformed = zeros(num_vertices, 2);
            for v = 1 : num_vertices
                x = obj.plot_model.vertex_coords_cartesian(v,:);
                u = displacements(v,:);
                vertices_coords_deformed(v,:) = x + scale * u;
            end
            
            % Plot
            ax = obj.getAxes(fig);
            h = patch(ax, 'Faces', obj.plot_model.vertices_of_faces, ...
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
        function [smooth_field] = averageField(obj, field)
            % Averages the values of a field at coincident vertices
            
            coincident_vertices = obj.plot_model.coincident_vertices;
            num_vertices = size(field, 1);
            smooth_field = zeros(num_vertices, size(field, 2));
            for v1 = 1:num_vertices
                group = coincident_vertices{v1};
                sum = zeros(1, size(field, 2));
                for i = 1 : length(group)
                    v2 = group(i);
                    sum = sum + field(v2,:);
                end
                smooth_field(v1,:) = sum / length(group);
            end
        end

        function [ax] = getAxes(~, fig)
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