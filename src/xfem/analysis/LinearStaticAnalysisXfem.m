classdef LinearStaticAnalysisXfem < handle
    % Performs multiple linear (elastic) static FEM analyses
    %   Detailed explanation goes here

    properties
        xfem_model % An object of FemModel
    end

    methods
        function obj = LinearStaticAnalysisXfem(xfem_model)
            % Constructor
     
            obj.xfem_model = xfem_model;
        end

        function initialize(obj)
            % These steps need to be done only once

            obj.xfem_model.initialize();
        end
        
        function [U] = run(obj)
            % Performs a new XFEM analysis       
            % Output:
            % U = vector with displacements at all dofs (free and
            % supported)
            
            Fe = build_forces_vector_xfem(obj.xfem_model);
            Kee = build_global_stiffness_matrix_fem(obj.xfem_model);
            Ue = Kee \ Fe;
            
            free_dofs = obj.fem_model.free_dofs;
            num_free_dofs = length(free_dofs);
            num_supported_dofs = length(obj.fem_model.supported_dofs);
            U = zeros(num_free_dofs + num_supported_dofs, 1);
            U(free_dofs, :) = Ue;
        end

        function plotResults(obj, U, scale)
            plot_displacements(obj.fem_model, U, scale);
        end
    end
end