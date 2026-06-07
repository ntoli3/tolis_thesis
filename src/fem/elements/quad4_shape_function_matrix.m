function [Nm] = quad4_shape_function_matrix(N)
% Calculates a matrix containing the shape functions that can be used to
% interpolate nodal displacements: [ux; uy] = N * u_nodal 
% Input:
% N = vector containing the shape functions at a point.
% Output:
% Nm = the shape function matrix (2x8)

Nm = [N(1) 0 N(2) 0 N(3) 0 N(4) 0; 
     0 N(1) 0 N(2) 0 N(3) 0 N(4)];
end