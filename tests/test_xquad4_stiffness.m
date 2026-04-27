close all; clear; clc;

% 1. Δεδομένα Εισόδου
nodes = [-1 -1; 1 -1; 1 1; -1 1]; % Ένα ορθογώνιο 2x2
Eneg = 210e9; % Young Modulus (π.χ. Χάλυβας σε Pa) for psi < 0
Epos = 100e9; % Young Modulus (π.χ. Χάλυβας σε Pa) for psi >= 0
v  = 0.3;   % Poisson ratio
t  = 0.01;  % Πάχος 1cm


% enrichment function:
psi_handle = @(phi) Heaviside(phi);

% Level set values at the 4 nodes
% Example: phi = x - 0.5  -> interface x = 0.5
nodal_level_sets = [-1.5;
                     0.5;
                     0.5;
                    -1.5];

% Compute stiffness matrix
k_total = xquad4_stiffness(nodes, Eneg, Epos, v, t,nodal_level_sets,psi_handle);

% Show result
disp('k_total = ');
disp(k_total);

% Basic checks
fprintf('Size of k_total: %d x %d\n', size(k_total,1), size(k_total,2));
fprintf('Symmetry error: %.3e\n', norm(k_total - k_total', 'fro'));
assert(all(size(k_total) == [16 16]), 'k_total must be 16x16');