classdef LsmInterface < handle
    % Represents a level set interface

    properties
        phi_handles = cell(0, 1);
    end

    methods
        function obj = LsmInterface()
            % Constructor
        end

        function addLevelSet(obj, phi_handle)
            % Adds a new level set geometry which interacts with the ones already stored
            % Input:
            % phi_handle = function handle for the level set function φ(x).
            
            obj.phi_handles{end+1, 1} = phi_handle;
        end

        function [phi_nodes_all] = calcFinalNodalLevelSets(obj, node_coords)
            % Calculates the final level sets from all curves
            % Input:
            % node_coords = coordinates of all nodes in cartesian system
            % Output:
            % phi_nodes_all = vector (nx1) with the level set (phi) at each node
            
            num_nodes = size(node_coords, 1);
            num_level_sets = length(obj.phi_handles);
            phi_nodes_all = zeros(num_nodes, 1);
            for n = 1 : num_nodes
                coords = node_coords(n,:);
                all_phi = zeros(num_level_sets, 1);
                for i = 1 : num_level_sets
                    phi_i = obj.phi_handles{i};
                    all_phi(i) = phi_i(coords(1), coords(2));
                end
                
                phi_nodes_all(n) = min(all_phi);
                
                %min_phi = min(all_phi);
                % max_phi = max(all_phi);
                % if min_phi >= 0
                %     phi_nodes_all(n) = min_phi;
                % else
                %     phi_nodes_all(n) = max_phi;
                % end
            end
        end
    end
end