function [k] = quad4_stiffness(nodes, E, v, t)
% Calculate the stiffness matrix of a Quad4 element
% Input:
% nodes = 4x2 matrix. Each row corresponds to one node. Column 1 = x
%   coordinate of the node. Column 2 = y coordinate.
% E = Young modulus
% v = Poisson ratio
% t = element thickness
% Output:
% k = stiffness matrix of the element


% Em = mitrwo elastikotitas (Ebdomada 5)
k = zeros(8, 8);
gauss_points = gauss_integration_quad4(2, 2);
for i = 1: size(gauss_points, 1)
    % xi = gauss_points(i, 1);
    % eta = gauss_points(i, 2);
    % w = gauss_points(i, 3)
    % Paragwgoi twn N1, N2, ...
    % J = ...
    % B1 = ...
    % B2 = ...
    % B = ...
    % k = k + w* B^T * Em * B * det(J);
end

k = k * t;
end