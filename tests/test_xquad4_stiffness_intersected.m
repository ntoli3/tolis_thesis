close all; clear; clc;

% 1. Element geometry
nodes = [-1 -1; 1 -1; 1 1; -1 1]; % Ένα ορθογώνιο 2x2

% 2. Materials
material_neg = struct('E', 210e9, 'v', 0.3, 'thickness', 0.01);
material_pos = struct('E', 100e9, 'v', 0.3, 'thickness', 0.01);

% 3. Enrichment function:
% psi_handle = @(phi,grad_phi) sign_enr(phi,grad_phi);
psi_handle = @(phi,grad_phi) ramp_enr(phi,grad_phi);


% 4. Level set values at the 4 nodes
% Example: phi = x - 0.5  -> interface x = 0.5
nodal_level_sets = [-1.5;
                     0.5;
                     0.5;
                    -1.5];

% 5. Gauss points for intersected element
gauss_points = [-0.5,      -1/3,   1.5;   % left triangle
                -0.5,       1/3,   1.5;   % left triangle
                 2/3,      -1/3,   0.5;   % right triangle
                 2/3,       1/3,   0.5];  % right triangle

% 6. Compute XFEM stiffness matrix for intersected element
k_total = xquad4_stiffness_intersected(...
    nodes, material_pos, material_neg, nodal_level_sets, psi_handle, gauss_points);

% 7. Show result
disp('k_total = ');
disp(k_total);

% 8. Basic checks
fprintf('Size of k_total: %d x %d\n', size(k_total,1), size(k_total,2));
fprintf('Symmetry error: %.3e\n', norm(k_total - k_total', 'fro'));
assert(all(size(k_total) == [16 16]), 'k_total must be 16x16');