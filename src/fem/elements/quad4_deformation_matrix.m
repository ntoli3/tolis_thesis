function [B] = quad4_deformation_matrix(dN_dx)
% Calculates the deformation matrix B that can be used to calculate strains:
% [ex; ey; exy] = B * u_nodal 
% Input:
% dN_dx = matrix 2x4 containing the derivatives of the shape functions in 
%   the cartesian system. Row 1 corrsponds to derivatives w.r.t. x and row
%   2 to derivatives w.r.t. y.
% Output:
% B = the deformation matrix (3x8)

B = zeros(3,8);
for n = 1 : 4
    Ni_x = dN_dx(1, n);
    Ni_y = dN_dx(2, n);
    B(1, 2*n-1) = Ni_x;
    B(2, 2*n) = Ni_y;
    B(3, 2*n-1) = Ni_y;
    B(3, 2*n) = Ni_x;
end

end