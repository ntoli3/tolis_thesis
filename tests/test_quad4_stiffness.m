close all; clear; clc;

% 1. Element geometry
node_coords_element = [-1 -1; 
                        1 -1; 
                        1  1; 
                       -1  1]; 

% 2. Materials
material_neg = struct('E', 210e9, 'v', 0.3, 'thickness', 0.01);
material_pos = struct('E', 100e9, 'v', 0.3, 'thickness', 0.01);

% 3. Enrichment function:
% psi_handle = @(phi,grad_phi) sign_enr(phi,grad_phi);
psi_handle = @(phi,grad_phi) ramp_enr(phi,grad_phi);

% 4. Level-set values
% All phi values have the same sign.
nodal_level_sets = [1.0;
                    1.2;
                    1.1;
                    0.9];

% 5. Enriched/standard nodes of this element
% Example: nodes 1 and 4 are enriched
standard_enriched_nodes = [1;
                           0;
                           0;
                           1];

% 6. Standard 2x2 Gauss integration for QUAD4
a = 1/sqrt(3);
gauss_points = [-a, -a, 1;
                 a, -a, 1;
                 a,  a, 1;
                -a,  a, 1];

% 7. Compute XFEM stiffness matrix for blending element
k_total = xquad4_stiffness(node_coords_element, ...
    standard_enriched_nodes, material_pos, material_neg,...
    nodal_level_sets, psi_handle, gauss_points);

% 8. Show result
disp('k_total = ');
disp(k_total);

% 9. Basic checks
num_enriched_nodes = sum(standard_enriched_nodes == 1);
expected_size = 8 + 2*num_enriched_nodes;

fprintf('Size of k_total: %d x %d\n', size(k_total,1), size(k_total,2));
fprintf('Expected size: %d x %d\n', expected_size, expected_size);
fprintf('Symmetry error: %.3e\n', norm(k_total - k_total', 'fro'));

assert(all(size(k_total) == [expected_size expected_size]), ...
    'k_total has wrong size');

assert(norm(k_total - k_total', 'fro') < 1e-6, ...
    'k_total must be symmetric');

disp('Blending xquad4_stiffness test passed successfully.');
