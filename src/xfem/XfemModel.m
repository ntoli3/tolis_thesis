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
        psi_handle;

        % Level set
        phi_nodes_all = []; % Dianysma (nx1) me tin timi tis level set (phi) gia kathe komvo
        
        % Mesh / level set intersections
        intersected_elements = []; % Gia kathe element periexei tin timi 0 an to element temnetai, 1 an to element vrisketai sti perioxi phi>0, -1 an to element vrisketai sti perioxi phi<0
        elements_category = []; 
        enriched_nodes = []; % pinakas (num_nodes x 1) pou deixnei an o kombos einai enriched, 0 an standard kombos, 1 an enriched kombos 
        intersection_mesh; % Des IntersectionMesh
        
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

        function describeLevelSetAndEnrichment(obj, phi_handle, psi_handle)
            %
            
            obj.psi_handle = psi_handle;

            % Nodal level sets
            num_nodes = size(obj.node_coords, 1);
            obj.phi_nodes_all = zeros(num_nodes, 1);
            for n = 1 : num_nodes
                coords = obj.node_coords(n, :);
                obj.phi_nodes_all(n) = phi_handle(coords(1), coords(2));
            end
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

            obj.intersected_elements = check_intersection_elements_lsm(...
                obj.phi_nodes_all, obj.element_nodes);

            obj.intersection_mesh = create_triangles_for_integration(...
                obj.node_coords, obj.element_nodes, obj.phi_nodes_all);
            
            obj.enriched_nodes = find_enriched_nodes(...
                obj.node_coords, obj.element_nodes, obj.intersected_elements);
            
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

        function [ke] = buildElementStiffness(obj, element_id)
            % Builds the stiffness matrix of an element
            % Input:
            % element_id = the ID of the target element
            % Output:
            % ke = the stiffness matrix of the target element
            
            if obj.dimension ~= 2
                error('Not implemented yet')
            end
            
            build_element_stiffness_xfem(element_id, obj.node_coords, obj.element_nodes, ...
                obj.elements_category, obj.intersected_elements, ...
                obj.material_pos, obj.material_neg, obj.phi_nodes_all, obj.psi_handle);
        end

        function [u_elem] = extractElementDisplacements(obj, e, U_global)
            % Extracts the vector of displacements of a specific element
            % from the global vector of displacements. Both vectors refer
            % to all possible dofs (free and supported).
            % Input
            % e = The ID of the target element
            % U_global = global vector of displacements at all dofs
            % Output
            % u_elem = displacements at all dofs of the target element

            global_dofs_of_elements = element_to_global_dofs( ...
                obj.element_nodes, e, obj.dimension);
            u_elem = U_global(global_dofs_of_elements);
        end
    end
end