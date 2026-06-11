classdef XfemModel < handle
    %FEMMODEL Represents a Finite Element Method model (container)
    % Useful for incrementally building the model and then passing it to
    % other functions.

    properties
        % Dimension
        dimension = 0; % 1 for 1D, 2 for 2D, 3 for 3D

        %% Geometry and mesh
        % node_coords = [num_nodes x num_dimensions]. Each row corresponds
        % to one node and contains its coordinates in the global cartesian
        % system.
        node_coords = [];      

        % element_nodes = matrix [num_elements x num_nodes_per_element].
        % Each row corresponds to one finite element and containts
        % the IDs of the nodes of that element
        element_nodes = [];   % [num_elements x num_nodes_per_element]
        
        % mesh = struct described elsewhere. E.g. see: define_mesh_2D()
        mesh = [];

         %% Material properties. E = Young's modulus, v = Poisson's ratio
        material_pos = struct('E', 0, 'v', 0, 'thickness', 1); % material gia level set > 0
        material_neg = struct('E', 0, 'v', 0, 'thickness', 1); % material gia level set < 0
        cohesive_interface = 0;
        Dcoh = []; % Constitutive tensor of the cohesive interface: 2x2 matrix
        
        %% Boundary conditions
        % loads: pinakas (nL x 3) opou nL = arithmos dofs pou exoun fortio. Kathe
        % grammi antistoixei se 1 fortio. H stili 1 deixnei se poion komvo einai to
        % fortio, h stili 2 deixnei se poion dof (1=x, 2=y), h 3h stili deixnei
        % to megethos tou fortiou. P.x. [...; 5 2 -6.78; ...] simainei oti ston
        % komvo 5 kata ton y askeitai fortio 6.78 pros ta arnhtika.
        loads = [];
       
        % supports: pinakas (nS x 2) opou nS = arithmos desmeumenwn dofs.
        % Kathe grammi antistoixei se 1 supported dof. H stili 1 deixnei se poion
        % komvo einai h desmeush, h stili 2 deixnei se poion dof (1=x, 2=y), 
        % P.x. [...; 5 2; ...] simainei oti exei desmeutei o komvos 5 kata ton y
        supports = [];
        
        % Enrichment function
        psi_func; % Object of a class that implements EnrichmentInterface

        % Level set
        phi_nodes_all = []; % Vector (nx1) with the level set (phi) at each node
        
        % Mesh / level set intersections
        intersected_elements = []; % Gia kathe element periexei tin timi 0 an to element temnetai, 1 an to element vrisketai sti perioxi phi>0, -1 an to element vrisketai sti perioxi phi<0
        elements_category = []; % Vector (num_elements x 1) that classifies each finite element according to its relation with the interface
        enriched_nodes = []; % pinakas (num_nodes x 1) pou periexei: 0 an standard kombos, 1 an enriched kombos 
        intersection_mesh; % Des IntersectionMesh
        intersection_segments;
        
        % Integration rules
        num_quad_points = [2 2];
        num_subtriangle_points = 3;
        num_interface_segment_points = 2;

        %% Freedom degrees
        num_dofs_all;
        dof_order = []
        free_dofs = []; % dianysma poy periexei ta IDS twn free dofs
        supported_dofs = []; %dianysma poy periexei ta IDS twn supported dofs
    end

    methods
        function obj = XfemModel() %Constructor
            %FEMMODEL Construct an instance of this class
            % if dimension ~= 2 && dimension ~=3
            %     ME = MException('dimension must be 2 or 3');
            %     throw(ME);
            % end
            obj.dimension = 2;
        end

        function describeLevelSetAndEnrichment(obj, phi_handle, psi_func)
            % Defines the level set function and the enrichment function.
            % Input:
            % phi_handle = function handle for the level set function φ(x).
            % psi_func = the enrichment function ψ(x). Object of a class that implements 
            %   EnrichmentInterface.
            % function ψ(x).
            
            obj.psi_func = psi_func;

            % Nodal level sets
            obj.phi_nodes_all = calc_all_nodal_level_sets(...
                obj.node_coords, obj.element_nodes, phi_handle);
            % num_nodes = size(obj.node_coords, 1);
            % obj.phi_nodes_all = zeros(num_nodes, 1);
            % for n = 1 : num_nodes
            %     coords = obj.node_coords(n, :);
            %     obj.phi_nodes_all(n) = phi_handle(coords(1), coords(2));
            % end
        end

        function setCohesiveInterface(obj, kn, kt)
            % Mark the interface as cohesive. Must be used with StepEnrichment.
            % Input:
            % kn = stiffness of the interface material for the opening mode
            % kt = stiffness of the interface material for the sliding mode
            
            obj.cohesive_interface = 1;
            obj.Dcoh = [kn 0; 0 kt]; 
        end

        function setMesh(obj, mesh, node_coords, element_nodes)
            % Saves this mesh as the one used by the FEM model
            % The dimension of the mesh must match the dimension of the FEM
            % model
            % Input:
            % mesh = see the property definition
            % node_coords = see the property definition
            % element_nodes = see the property definition
            
            if (mesh.dimension ~= obj.dimension) || ...
                    (size(node_coords, 2) ~= obj.dimension)
                error('The dimension of the mesh does not match the dimension of the model');
            end

            obj.mesh = mesh;
            obj.node_coords = node_coords;
            obj.element_nodes = element_nodes;
        end

        function setMaterials(obj, E_pos, v_pos, E_neg, v_neg, thickness)
            % Sets the material properties for all elements
            % Input
            % E_pos, E_neg = Young modulus of material in regions with
            %   positive / negative level set
            % v_pos, v_neg = poisson ratio of material in regions with
            %   positive / negative level set
            % thickness = common thickness of all elements

            obj.material_pos.E = E_pos;
            obj.material_pos.v = v_pos;
            obj.material_pos.thickness = thickness;
            
            obj.material_neg.E = E_neg;
            obj.material_neg.v = v_neg;
            obj.material_neg.thickness = thickness;
        end

        function addLoad(obj, node_id, dof, amount)
            % Apothikeuei ena neo simeiako epikomvio fortio sto FEM model
            % Input:
            % node_id = o arithmos tou komvou
            % dof = 1 (Fx) / 2 (Fy) / 3 (Fz)
            % amount = to megethos tou fortiou. Na bazw to swsto prosimo edw
            obj.loads(end+1, :) = [node_id, dof, amount];
        end

        function addSupport(obj, node_id, dof)
            % Apothikeuei mia nea stiriksi sto FEM model
            % Input:
            % node_id = o arithmos tou komvou
            % dof = 1 (ux) / 2 (uy) / 3 (uz)
            obj.supports(end+1, :) = [node_id, dof];
        end

        function initialize(obj)
            % Arxikopoiei to FEM model

            obj.intersected_elements = find_intersected_elements_lsm(...
                obj.phi_nodes_all, obj.element_nodes);

            obj.intersection_mesh = create_triangles_for_integration(...
                obj.intersected_elements, obj.node_coords, obj.element_nodes, obj.phi_nodes_all);

            if obj.cohesive_interface == 1
                obj.intersection_segments = create_interface_segments_for_integration( ...
                    obj.intersected_elements, obj.node_coords, obj.element_nodes, obj.phi_nodes_all);
            end
            
            obj.enriched_nodes = find_enriched_nodes(obj.node_coords, obj.element_nodes, ...
                 obj.phi_nodes_all, obj.intersected_elements, obj.psi_func);

            obj.elements_category = find_blending_elements(...
                obj.intersected_elements, obj.enriched_nodes, obj.element_nodes);

            [obj.dof_order, obj.num_dofs_all] = order_global_dofs_xfem(...
                obj.enriched_nodes);

            [obj.free_dofs, obj.supported_dofs] = separate_free_supported_dofs(...
                obj.num_dofs_all, obj.dof_order, obj.supports);
        end

        function [num_elements] = countElements(obj)
            % Counts the total number of elements along all axes.
            num_elements = 1;
            for d = 1 : obj.dimension
                num_elements = num_elements * obj.mesh.num_elements(d);
            end
        end

        function [num_dofs] = countElementDofs(obj, element_id)
            % Counts the dofs of a specific element
            
            num_dofs = 0;
            num_nodes_per_element = size(obj.element_nodes, 2);
            for n = 1 : num_nodes_per_element
                node_id = obj.element_nodes(element_id, n);
                if obj.enriched_nodes(node_id) == 0 % Standard node
                    num_dofs = num_dofs + 2;
                else
                    num_dofs = num_dofs + 4;
                end
            end
        end

        function [ke] = buildElementStiffness(obj, element_id)
            % Builds the stiffness matrix of an element
            % Input:
            % element_id = the ID of the target element
            % Output:
            % ke = the stiffness matrix of the target element
            
            ke = build_xfem_element_stiffness(obj, element_id);
        end

        function [phi] = interpolateLevelSets(obj, element_id, natural_coords)
            % Finds the level set at a specific point inside an element.
            % Input:
            % element_id = the ID of the target element
            % natural_coords = vector with the coordinates of the point in
            %   the natural system of the element
            % Output:
            % phi = the level set at the target point

            nodes = obj.element_nodes(element_id, :);
            nodal_phi = obj.phi_nodes_all(nodes);
            N = quad4_shape_functions(natural_coords);
            phi = N * nodal_phi;
        end

        function [u] = calcDisplacementsAt(obj, element_id, natural_coords, U_global)
            % Calculate the displacement at a specific point inside an element.
            % Input:
            % element_id = the ID of the target element
            % natural_coords = vector with the coordinates of the point in
            %   the natural system of the element
            % U_global = global vector of displacements at all dofs
            % Output:
            % u = 2x1 vector with the displacements of the target point
            
            u_elem = extractElementDisplacements(obj, element_id, U_global);
            if obj.elements_category(element_id) == 0 % Standard element
                u = quad4_displacements(natural_coords, u_elem);
            else % intersected/blending element
                nodal_phi = extractElementLevelSets(obj, element_id);
                nodal_categories = obj.extractElementNodalCategories(element_id);
                u = xquad4_displacements(natural_coords, u_elem, ...
                    nodal_categories, nodal_phi, obj.psi_func);
            end
        end

        function [e, s] = calcStrainsStressesAt(obj, element_id, natural_coords, U_global)
            % Calculate the displacement at a specific point inside an element.
            % Input:
            % element_id = the ID of the target element
            % natural_coords = vector with the coordinates of the point in
            %   the natural system of the element
            % U_global = global vector of displacements at all dofs
            % Output:
            % e = 3x1 vector with the strains of the target point
            % s = 3x1 vector with the stresses of the target point
            
            u_elem = extractElementDisplacements(obj, element_id, U_global);
            nodal_coords = obj.extractElementCoordinates(element_id);
            if obj.elements_category(element_id) == 0 % Standard element
                if obj.intersected_elements(element_id) == 1
                    material = obj.material_pos;
                else
                    material = obj.material_neg;
                end
                [e, s] = quad4_strains_stresses(natural_coords, u_elem, ...
                    nodal_coords, material.E, material.v);
                
            else % intersected/blending element
                nodal_phi = extractElementLevelSets(obj, element_id);
                nodal_categories = obj.extractElementNodalCategories(element_id);
                [e, s] = xquad4_strains_stresses(natural_coords, u_elem, ...
                    nodal_coords, nodal_categories, nodal_phi, obj.psi_func, ...
                    obj.material_pos, obj.material_neg);
            end
        end

        function [elem_coords] = extractElementCoordinates(obj, element_id)
            % Extracts the coordinates of nodes of a specific element.
            % Input
            % element_id = The ID of the target element.
            % Output
            % elem_coords = coords of nodes of the target element.
            
            nodes = obj.element_nodes(element_id,:);
            elem_coords = obj.node_coords(nodes,:);
        end

        function [u_elem] = extractElementDisplacements(obj, element_id, U_global)
            % Extracts the vector of displacements of a specific element
            % from the global vector of displacements. Both vectors refer
            % to all possible dofs (free and supported).
            % Input
            % element_id = The ID of the target element
            % U_global = global vector of displacements at all dofs
            % Output
            % u_elem = displacements at all dofs of the target element

            global_dofs_of_elements = element_to_global_dofs_xfem( ...
                element_id, obj.element_nodes, obj.enriched_nodes, ...
                obj.dof_order);
            u_elem = U_global(global_dofs_of_elements);
        end

        function [nodal_phi] = extractElementLevelSets(obj, element_id)
            % Extracts the level sets of nodes of a specific element.
            % Input
            % element_id = The ID of the target element.
            % Output
            % nodal_phi = level sets at nodes of the target element.
            
            nodes = obj.element_nodes(element_id, :);
            nodal_phi = obj.phi_nodes_all(nodes);
        end

        function [nodal_categories] = extractElementNodalCategories(obj, element_id)
            % Extracts the categories (0=std, 1=enr) of nodes of a 
            % specific element.
            % Input
            % element_id = The ID of the target element.
            % Output
            % nodal_categories = categories (0=std, 1=enr) of nodes of 
            %   the target element.
            
            nodes = obj.element_nodes(element_id, :);
            nodal_categories = obj.enriched_nodes(nodes);
        end
    end
end