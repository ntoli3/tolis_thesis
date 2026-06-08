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
            
            vertex_coords_deformed = obj.calcDeformedStructure(U_global, scale);
            
            % Plot
            ax = obj.getAxes(fig);
            h = patch(ax, 'Faces', obj.plot_model.vertices_of_faces, ...
              'Vertices', vertex_coords_deformed, ...
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
                obj.xfem_model.intersection_mesh, fig, 'r');
        end

        function plotStrainsStresses(obj, U_global, smooth, scale)
            % Plot the strains (εx, εy, γxy) and stresses (σx, σy, τxy).
            % Input:
            % U_global = global displacements
            % smooth = 1 to average values at coincident vertices or 0 to
            %   plot the raw results from XFEM
            % scale = proportionality coefficient. 1 = same as real
            %   displacements
            
            % Strain and stress fields
            num_vertices = size(obj.plot_model.vertex_coords_cartesian, 1);
            strains = zeros(num_vertices, 3);
            stresses = zeros(num_vertices, 3);
            vonMises = zeros(num_vertices, 1);% Von Mises stress
            for v = 1 : num_vertices
                xi = obj.plot_model.vertex_coords_natural(v,:);
                elem = obj.plot_model.vertex_elements(v,:);
                [e,s] = obj.xfem_model.calcStrainsStressesAt(elem, xi, U_global);
                strains(v,:) = e';
                stresses(v,:) = s';
                vonMises(v) = sqrt(s(1)^2 + s(2)^2 - s(1)*s(2) + 3*s(3)^2);
            end
            
            % Smoothing
            if smooth == 1
                strains = obj.smoothField(strains);
                stresses = obj.smoothField(stresses);
                vonMises = obj.smoothField(vonMises);
            end

            % Deformed coordinates
            vertex_coords_deformed = obj.calcDeformedStructure(U_global, scale);

            % Plot the fields
            obj.plotFieldOnDeformedStructure(strains(:,1), '\epsilon_{xx}', vertex_coords_deformed);
            obj.plotFieldOnDeformedStructure(strains(:,2), '\epsilon_{yy}', vertex_coords_deformed);
            obj.plotFieldOnDeformedStructure(strains(:,3), '\gamma_{xy}', vertex_coords_deformed);
            obj.plotFieldOnDeformedStructure(stresses(:,1), '\sigma_{xx}', vertex_coords_deformed);
            obj.plotFieldOnDeformedStructure(stresses(:,2), '\sigma_{yy}', vertex_coords_deformed);
            obj.plotFieldOnDeformedStructure(stresses(:,3), '\tau_{xy}', vertex_coords_deformed);
            obj.plotFieldOnDeformedStructure(vonMises, '\sigma_V', vertex_coords_deformed);
        end
    end

    methods (Access = private)
        function [vertex_coords_deformed] = calcDeformedStructure(...
                obj, U_global, scale)
             % Calculate the displacements of the vertices
            num_vertices = size(obj.plot_model.vertex_coords_cartesian, 1);
            displacements = zeros(num_vertices, 2);
            for v = 1 : num_vertices
                xi = obj.plot_model.vertex_coords_natural(v,:);
                elem = obj.plot_model.vertex_elements(v,:);
                u = obj.xfem_model.calcDisplacementsAt(elem, xi, U_global);
                displacements(v,:) = u';
            end
            displacements = obj.smoothField(displacements);

            % Calculate coordinates of the vertices in the deformed
            % structure
            vertex_coords_deformed = zeros(num_vertices, 2);
            for v = 1 : num_vertices
                x = obj.plot_model.vertex_coords_cartesian(v,:);
                u = displacements(v,:);
                vertex_coords_deformed(v,:) = x + scale * u;
            end
        end

        function [ax] = getAxes(~, fig)
            ax = findobj(fig, 'Type', 'axes');
            if isempty(ax)
                ax = axes(fig);
                hold(ax,'on');
                axis(ax,'equal');
                xlabel(ax,'x', 'FontSize',16);
                ylabel(ax,'y', 'FontSize',16);
            else
                ax = ax(1);
            end
        end

        function cmap = makeColorMap(obj)
            % Blue for negative, white around 0, red for positive
            n = 128;
            blue  = [linspace(0,1,n)', linspace(0,1,n)', ones(n,1)];
            red   = [ones(n,1), linspace(1,0,n)', linspace(1,0,n)'];
            cmap = [blue; red];
        end

        function plotFieldOnDeformedStructure(obj, ...
                field, field_name, vertex_coords_deformed)
             % Plot the fields
            fig = figure;
            ax = obj.getAxes(fig);
            patch(ax, 'Faces', obj.plot_model.vertices_of_faces, ...
              'Vertices', vertex_coords_deformed, ...
              'FaceVertexCData', field, ...
              'FaceColor', 'interp', ...
              'EdgeColor', 'k', ...
              'LineWidth', 1.0);
            title(ax, field_name, 'FontSize', 20);

            % Colors
            field_min = min(field);
            field_max = max(field);
            if field_min < 0 && field_max > 0
                max_abs = max(abs(field));
                clim(ax, [-max_abs max_abs]);
                cmap = obj.makeColorMap(); % blue -> white -> red
                colormap(ax, cmap);
            else
                clim(ax, [field_min field_max]);
                colormap(ax, turbo);
            end
            cb = colorbar(ax);
            ticks = cb.Ticks;
            cb.Ticks = unique(sort([ticks field_min field_max]));
        end

        function [smooth_field] = smoothField(obj, field)
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

    end
end