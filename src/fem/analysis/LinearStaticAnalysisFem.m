classdef LinearStaticAnalysisFem < handle
    % Performs multiple linear (elastic) static FEM analyses
    %   Detailed explanation goes here

    properties
        fem_model % An object of FemModel
    end

    methods
        function obj = LinearStaticAnalysisFem(fem_model)
            % Constructor
     
            obj.fem_model = fem_model;
        end

        function initialize(obj)
            % These steps need to be done only once

            obj.fem_model.initialize();
        end
        
        function [U] = run(obj)
            % Performs a new FEM analysis       
            % Output:
            % U = vector with displacements at all dofs (free and
            % supported)
            
            Fe = build_forces_vector_fem(obj.fem_model);
            Kee = build_global_stiffness_matrix_fem(obj.fem_model);
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