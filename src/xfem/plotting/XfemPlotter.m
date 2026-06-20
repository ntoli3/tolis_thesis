classdef XfemPlotter < handle
    % Plots engineering fields over an XFEM model
    
    properties
        xfem_model; % The original model used in XFEM
        plot_model; % The model of faces and vertices used for plotting
        smoothing_type; % 0 = no smoothing, 1 = averaging, 2 = weighted averaging, based on areas
        clip_stresses = 0; % The percetile over which strains/stresses will be clipped, e.g. 99. 0 = no clipping
        strain_location = 0; % where to calculate strains/stresses. 0 = at vertices, 1 = at Gauss points + extrapolation, 2 = at face centroids
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
            
            fprintf('Initializing plotter ...\n');
            obj.plot_model = PlotModel(obj.xfem_model);
            obj.plot_model.initialize();
        end

        function plotDisplacements(obj, U_global, scale)
            % Plot the structure with nodes being translated proportionally
            % to their displacements
            % Input:
            % U_global = global displacements
            % scale = proportionality coefficient. 1 = same as real
            %   displacements
            
            fprintf('Plotting displacements ...\n');

            % Plot initial geometry
            fig = figure;
            ax = obj.getAxes(fig);
            h = patch(ax, 'Faces', obj.xfem_model.element_nodes, ...
              'Vertices', obj.xfem_model.node_coords, ...
              'FaceColor', 'none', ...
              'EdgeColor', [0.7 0.7 0.7], ...
              'LineStyle', '--');
            h.DisplayName = 'Undeformed';

            vertex_coords_deformed = obj.calcDeformedStructure(U_global, scale);
            
            % Plot deformed geometry
            h = patch(ax, 'Faces', obj.plot_model.vertices_of_faces, ...
              'Vertices', vertex_coords_deformed, ...
              'FaceColor', 'none', ...
              'EdgeColor', 'b', ...
              'LineWidth', 1.5);
            h.DisplayName = 'Deformed';
            legend(ax,'show');

            % Save as button
            filename = 'displacements.fig';
            obj.addSaveButton(filename, fig);
        end
        
        function plotInitialGeometry(obj, gauss_point_size, enriched_node_size, normal_head_size)
            % Plot the gauss point at their coordinates in the undeformed structure
            % Input:
            % gauss_point_size = marker size. E.g. 1, 2, 3
                
            fprintf('Plotting initial geometry ...\n');

            fig = figure;
            ax = obj.getAxes(fig);
            
            % Intersection mesh
            patch(ax, 'Faces', obj.plot_model.vertices_of_faces, ...
              'Vertices', obj.plot_model.vertex_coords_cartesian, ...
              'FaceColor', 'none', ...
              'EdgeColor', 'k', ...
              'LineWidth', 1.0);
            
            % Gauss points for subtriangles
            plot_volume_gauss_points(obj.xfem_model, fig, 'r', gauss_point_size);
            
            % Intersection segments
            if obj.xfem_model.cohesive_interface == 0
                obj.xfem_model.intersection_segments = create_interface_segments_for_integration(...
                    obj.xfem_model.intersected_elements, obj.xfem_model.node_coords, ...
                    obj.xfem_model.element_nodes, obj.xfem_model.phi_nodes_all);
            end
            color_green = [0 0.6 0];
            plot_intersection_segments(obj.xfem_model, fig, color_green, normal_head_size);
            color_orange = [1 0.5 0];
            plot_interface_gauss_points(obj.xfem_model, fig, color_orange, gauss_point_size);

            % Enriched nodes
            node_coords = obj.xfem_model.node_coords;
            enr_nodes = obj.xfem_model.enriched_nodes;
            plot_enriched_nodes(node_coords, enr_nodes, fig, 'b', enriched_node_size);

            % Save as button
            filename = 'gauss_points.fig';
            obj.addSaveButton(filename, fig);
        end

        function plotStrainsStresses(obj, U_global, scale)
            % Plot the strains (εx, εy, γxy) and stresses (σx, σy, τxy).
            % Input:
            % U_global = global displacements
            % scale = proportionality coefficient. 1 = same as real displacements
            
            fprintf('Plotting strains and stresses ...\n');
            
            [strains, stresses, vonMises] = obj.calcStrainsStresses(U_global);

            % Smoothing
            if obj.smoothing_type ~= 0
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

        function [strains, stresses, vonMises] = calcStrainsStresses(obj, U_global)
            % Strain and stress fields
            vertices_of_faces = obj.plot_model.vertices_of_faces;
            num_vertices = size(obj.plot_model.vertex_coords_cartesian, 1);
            num_faces = size(vertices_of_faces, 1);
            strains = zeros(num_vertices, 3);
            stresses = zeros(num_vertices, 3);
            vonMises = zeros(num_vertices, 1);% Von Mises stress
            
            if obj.strain_location == 0
                % Calculate strains, stresses directly at vertices
                for v = 1 : num_vertices
	                xi = obj.plot_model.vertex_coords_natural(v,:);
	                elem = obj.plot_model.vertex_elements(v,:);
	                [e,s] = obj.xfem_model.calcStrainsStressesAt(elem, xi, U_global);
	                strains(v,:) = e';
	                stresses(v,:) = s';
	                vonMises(v) = sqrt(s(1)^2 + s(2)^2 - s(1)*s(2) + 3*s(3)^2);
                end
            else
                for f = 1 : num_faces
                    % Calculate strains, stresses at the vertices of this face
                    if obj.strain_location == 1
                        % Calculate strains, stresses at Gauss points and extrapolate to vertices
                        is_triangle = isnan(vertices_of_faces(f, 4));
                        if is_triangle
                            [vertex_ids, face_strains, face_stresses] = ...
                                obj.calcTri3StrainsStressesFromGaussPoints(f, U_global);
                        else
                            [vertex_ids, face_strains, face_stresses] = ...
                                calcQuad4StrainsStressesFromGaussPoints(obj, f, U_global);
                        end
                        
                    elseif obj.strain_location == 2
                        % Calculate strains, stresses at face centroids
                        [vertex_ids, face_strains, face_stresses] = ...
                            obj.calcStrainsStressesCentroid(f, U_global);
                    else
                        error('Invalid choice');
                    end
                    
                    for v = 1 : length(vertex_ids)
                        vertex_id = vertex_ids(v);
                        e = face_strains(v,:);
                        s = face_stresses(v,:);
                        strains(vertex_id, :) = e;
                        stresses(vertex_id, :) = s;
                        vonMises(vertex_id) = sqrt(s(1)^2 + s(2)^2 - s(1)*s(2) + 3*s(3)^2);
                    end
                end
            end
        end

        function [vertex_ids, strains, stresses] = calcQuad4StrainsStressesFromGaussPoints(...
                obj, face_id, U_global)
            % Output
            % vertex_ids = row vector
            % strains = row vector
            % stresses = row vector
            
            vertex_ids = obj.plot_model.vertices_of_faces(face_id, 1:4);

            % Define gauss point system
            sq3 = sqrt(3);
            inv_sq = 1 / sqrt(3);
            gp_natural = [-inv_sq -inv_sq; 
                           inv_sq -inv_sq; 
                           inv_sq inv_sq; 
                          -inv_sq inv_sq];
            num_gp = size(gp_natural, 1);
            nodes_rs = [-sq3 -sq3;
                         sq3 -sq3;
                         sq3  sq3
                        -sq3  sq3];

            % Calculate strains/stresses at gauss points
            elem_id = obj.plot_model.elements_of_faces(face_id);
            strains_gp = zeros(num_gp, 3);
            stresses_gp = zeros(num_gp, 3);
            for gp = 1 : num_gp
                xi = gp_natural(gp, :);
                [e, s] = obj.xfem_model.calcStrainsStressesAt(elem_id, xi, U_global);
                strains_gp(gp, :) = e';
                stresses_gp(gp, :) = s';
            end

            % Extrapolate them to vertices
            Nrs = zeros(4,4);
            for n = 1 : 4
                r = nodes_rs(n, 1);
                s = nodes_rs(n, 2);
                Nrs(n,1) = 1/4*(1-r)*(1-s);
                Nrs(n,2) = 1/4*(1+r)*(1-s);
                Nrs(n,3) = 1/4*(1+r)*(1+s);
                Nrs(n,4) = 1/4*(1-r)*(1+s);
            end
            strains = Nrs * strains_gp;
            stresses = Nrs * stresses_gp;
        end

        function [vertex_ids, strains, stresses] = calcTri3StrainsStressesFromGaussPoints(...
                obj, face_id, U_global)
            % Output
            % vertex_ids = row vector
            % strains = row vector
            % stresses = row vector
            
            % Vertices of triangle
            vertex_ids = obj.plot_model.vertices_of_faces(face_id, 1:3);
            vertices_natural = obj.plot_model.vertex_coords_natural(vertex_ids, :);
            xi_vertices = vertices_natural(:,1);
            eta_vertices = vertices_natural(:,2);
            
            % Gauss point coords in reference triangle system
            gp_reference = [1/6 1/6;
                            2/3 1/6;
                            1/6 2/3];
            num_gp = 3;

            % Calculate strains/stresses at gauss points
            elem_id = obj.plot_model.elements_of_faces(face_id);
            strains_gp = zeros(num_gp, 3);
            stresses_gp = zeros(num_gp, 3);
            for gp = 1 : num_gp
                r = gp_reference(gp, 1);
                s = gp_reference(gp, 2);
                xi = (1-r-s) * xi_vertices(1) + r * xi_vertices(2) + s * xi_vertices(3);
                eta = (1-r-s) * eta_vertices(1) + r * eta_vertices(2) + s * eta_vertices(3);
                [e, s] = obj.xfem_model.calcStrainsStressesAt(elem_id, [xi eta], U_global);
                strains_gp(gp, :) = e';
                stresses_gp(gp, :) = s';
            end

            % Extrapolate strains/stresses to vertices
            E = [5/3 -1/3 -1/3;
                -1/3  5/3 -1/3;
                -1/3 -1/3  5/3]; % Extrapolation matrix in the reference system
            strains = E * strains_gp;
            stresses = E * stresses_gp;
        end

        function [vertex_ids, strains, stresses] = calcStrainsStressesCentroid(obj, face_id, U_global)
            % Output
            % vertex_ids = row vector
            % strains = row vector
            % stresses = row vector
            
            % Centroid in natural coords
            vertex_ids = obj.plot_model.vertices_of_faces(face_id, :);
            if isnan(vertex_ids(4))
                vertex_ids = vertex_ids(1:3);
            end
            num_vertices = length(vertex_ids);
            vertex_coords = obj.plot_model.vertex_coords_natural(vertex_ids, :);
            centroid = sum(vertex_coords, 1) / num_vertices;
            
            % Calc strains, stresses
            elem_id = obj.plot_model.elements_of_faces(face_id);
            [e, s] = obj.xfem_model.calcStrainsStressesAt(elem_id, centroid, U_global);
            strains = zeros(4,3);
            stresses = zeros(4,3);
            for n = 1 : 4
                strains(n,:) = e';
                stresses(n,:) = s';
            end
            vertex_ids = obj.plot_model.vertices_of_faces(face_id, 1:num_vertices);

            % elem_id = obj.plot_model.elements_of_faces(face_id);
            % xi = [0 0];
            % [e, s] = obj.xfem_model.calcStrainsStressesAt(elem_id, xi, U_global);
            % strains = zeros(4,3);
            % stresses = zeros(4,3);
            % for n = 1 : 4
            %     strains(n,:) = e';
            %     stresses(n,:) = s';
            % end
            % vertex_ids = obj.plot_model.vertices_of_faces(face_id, 1:4);
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

        function plotFieldOnDeformedStructure(obj, field, field_name, vertex_coords_deformed)

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
                if obj.clip_stresses == 0
                    max_abs = max(abs(field));
                else
                    max_abs = prctile(abs(field), obj.clip_stresses);
                end
                clim(ax, [-max_abs max_abs]);
                cmap = obj.makeColorMap(); % blue -> white -> red
                colormap(ax, cmap);
            else
                if obj.clip_stresses == 0
                    max_abs = field_max;
                else 
                    max_abs = prctile(field, obj.clip_stresses);
                end
                clim(ax, [field_min max_abs]);
                colormap(ax, turbo);
            end
            cb = colorbar(ax);
            ticks = cb.Ticks;
            %cb.Ticks = unique(sort([ticks field_min field_max]));

            % Save as button
            filename = append(field_name, ".fig");
            obj.addSaveButton(filename, fig);
        end
        
        function addSaveButton(obj, filename, fig)
            uicontrol('Style','pushbutton', ...
                'String','Save Figure', ...
                'Position',[10 10 100 30], ...
                'Callback', @(src,event) save_my_figure(src, event, fig, filename));
        end

        function [smooth_field] = smoothField(obj, field)
            % Averages the values of a field at coincident vertices
            
            coincident_vertices = obj.plot_model.coincident_vertices;
            num_vertices = size(field, 1);
            smooth_field = zeros(num_vertices, size(field, 2));
            if obj.smoothing_type == 1
                for v1 = 1:num_vertices
                    group = coincident_vertices{v1};
                    sum = zeros(1, size(field, 2));
                    for i = 1 : length(group)
                        v2 = group(i);
                        sum = sum + field(v2,:);
                    end
                    smooth_field(v1,:) = sum / length(group);
                end
            else
                weights = obj.plot_model.vertex_smoothing_weights;
                for v1 = 1:num_vertices
                    group = coincident_vertices{v1};
                    sum = zeros(1, size(field, 2));
                    for i = 1 : length(group)
                        v2 = group(i);
                        w = weights(v2);
                        sum = sum + w * field(v2,:);
                    end
                    smooth_field(v1,:) = sum;
                end
            end

            
        end

    end
end