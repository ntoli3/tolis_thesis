function [gauss_points] = gauss_integration_quad4(num_points_x, num_points_y)
% Gauss-Legendre integration for Quad4 elements
% Input:
% num_points_x = arithos shmeiwn sto x
% num_points_y = arithos shmeiwn sto y
% Output:
% gauss_points = matrix with as many rows as the number of gauss points.
%   Each row corresponds to 1 gauss point. Column 1 = xi coordinate. 
%   Column 2 = eta coordinate. Column 3 = weight

% Ορισμός σημείων και βαρών για τον άξονα X
switch num_points_x
    case 1
        x_pts = 0; w_x = 2;
    case 2
        x_pts = [-1/sqrt(3), 1/sqrt(3)]; w_x = [1, 1];
    case 3
        x_pts = [-sqrt(0.6), 0, sqrt(0.6)]; w_x = [5/9, 8/9, 5/9];
    otherwise
        error('Υποστηρίζονται μόνο 1, 2 ή 3 σημεία Gauss ανά άξονα.');
end

% Ορισμός σημείων και βαρών για τον άξονα Y
switch num_points_y
    case 1
        y_pts = 0; w_y = 2;
    case 2
        y_pts = [-1/sqrt(3), 1/sqrt(3)]; w_y = [1, 1];
    case 3
        y_pts = [-sqrt(0.6), 0, sqrt(0.6)]; w_y = [5/9, 8/9, 5/9];
    otherwise
        error('Υποστηρίζονται μόνο 1, 2 ή 3 σημεία Gauss ανά άξονα.');
end

% Δημιουργία του τελικού πίνακα gauss_points (Total rows = nx * ny)
gauss_points = zeros(num_points_x * num_points_y, 3);
row = 1;

for i = 1:num_points_x
    for j = 1:num_points_y
        gauss_points(row, 1) = x_pts(i);      % xi coordinate
        gauss_points(row, 2) = y_pts(j);      % eta coordinate
        gauss_points(row, 3) = w_x(i) * w_y(j); % Συνολικό βάρος W = wi * wj
        row = row + 1;
    end
end

end