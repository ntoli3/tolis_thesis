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
Em = (E/(1-v^2)) * [1 v 0;
                    v 1 0;
                    0 0 (1-v)/2];
k = zeros(8, 8);
gauss_points = gauss_integration_quad4(2, 2);
for i = 1: size(gauss_points, 1)
    xi = gauss_points(i, 1);
    eta = gauss_points(i, 2);
    w = gauss_points(i, 3);

    % Synarthseis sxhmatos
    N = quad4_shape_functions(xi, eta);

    % Paragwgoi twn N1, N2, ...
    dN_dxi = 1/4 * [-(1-eta) (1-eta) (1+eta) -(1+eta)];
    dN_deta = 1/4 * [-(1-xi) -(1+xi) (1+xi) (1-xi)];

    % Jacobian
    J = [dN_dxi; dN_deta] * nodes;
    detJ = det(J);

    dN = J \ [dN_dxi; dN_deta];

    % B matrix
    B = zeros(3,8);
    for j = 1:4
        B(1,2*j-1) = dN(1,j);
        B(2,2*j)   = dN(2,j);
        B(3,2*j-1) = dN(2,j);
        B(3,2*j)   = dN(1,j);
    end

   
     k = k + w* (B' * Em * B) * detJ;
end

k = k * t;
end