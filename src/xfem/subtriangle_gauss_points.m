function [xew] = subtriangle_gauss_points(num_gauss_points, triangle_points_natural)
% ypologizei ta shmeia oloklhrwshs gauss se ena trigwno sto fisiko systhma
% input: 
% num_gauss_points = plhthos shmeiwn gauss
% triangle_points_natural = pinakas me tis syntetagmenes ξ,η twn korhfwn toy trigwnoy
% output: 
% xew = pinakas poy periexei gia kathe shmeio tis fysikes syntetagmenes ξ,η kai to varos w 

[rsw] = triangle_gauss_points(num_gauss_points);

n = size(rsw,1);
xew = zeros(n,3);

% koryfes toy trigwnoy
A = triangle_points_natural(1,:);
B = triangle_points_natural(2,:);
C = triangle_points_natural(3,:);

for i = 1 : n 
    r = rsw(i,1);
    s = rsw(i,2);
    w = rsw(i,3);
    xi_eta = (1 - r - s)*A + r*B + s*C;
    xew(i , 1:2) = xi_eta;
    xew(i , 3) = w;
end

end

