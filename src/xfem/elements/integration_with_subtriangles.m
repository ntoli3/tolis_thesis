function [xew] = integration_with_subtriangles(element_id, ...
    intersection_mesh, num_gauss_points_per_triangle)
% ypologizei ta shmeia oloklhrwshs gauss se ena trigwno sto fisiko systhma
% input: 
%
%
% output: 
% xew = pinakas poy periexei gia kathe shmeio tis fysikes syntetagmenes ξ,η kai to varos w 

num_triangles = intersection_mesh.countTrianglesOfElement(element_id);

% Syntegmenes kai barh gia kathe trigwno se boithitiko systima (r,s)
rsw = triangle_gauss_points(num_gauss_points_per_triangle);

% Syntegmenes kai barh sto natural systima (xi, eta) tou element, gia ola
% ta trigwna
num_gauss_points_of_element = num_triangles * num_gauss_points_per_triangle;
xew = zeros(num_gauss_points_of_element, 3);

gp = 0;
for t = 1 : num_triangles
    triangle_points_natural = intersection_mesh.findNaturalCoordsOfTriangle(t, element_id);
    
    % Koryfes trigwnou sto natural
    A = triangle_points_natural(1,:);
    B = triangle_points_natural(2,:);
    C = triangle_points_natural(3,:);
    
    for i = 1 : num_gauss_points_per_triangle
        % Coordinates in natural system
        r = rsw(i,1);
        s = rsw(i,2);
        w = rsw(i,3);
        xi_eta = (1 - r - s)*A + r*B + s*C;
        
        % Store them
        gp = gp + 1;
        xew(gp , 1:2) = xi_eta;
        xew(gp , 3) = w;
    end
end





% koryfes toy trigwnoy


end

