function [xew] = integration_with_subtriangles(element_id, ...
    intersection_mesh, num_gauss_points_per_triangle)
% Finds the Gauss points of subtriangles of an element, w.r.t the element's natural coord system.
% Ιnput: 
% intersection_mesh = object of IntersectionMesh
% num_gauss_points_per_triangle = how many Gauss to use (e.g. 1, 3, 7, ...)
% Output: 
% xew = matrix (num_gp x 3) containing the natural coords ξ,η and weight for each Gauss point.

num_triangles = intersection_mesh.countTrianglesOfElement(element_id);

% Coordinates and weights of each triangle in the auxiliary coord system (r,s)
rsw = gauss_integration_triangle(num_gauss_points_per_triangle);

% Coordinates in the natural system (xi, eta) if the element, for all triangles
num_gauss_points_of_element = num_triangles * num_gauss_points_per_triangle;
xew = zeros(num_gauss_points_of_element, 3);
gp = 0;
for t = 1 : num_triangles
    % Triangle point coords in natural system
    triangle_points_natural = intersection_mesh.findNaturalCoordsOfTriangle(t, element_id);
    A = triangle_points_natural(1,:);
    B = triangle_points_natural(2,:);
    C = triangle_points_natural(3,:);
    
    % Determinant of the map from auxiliary to natural
    AB = B-A;
    AC = C-A;
    J = [AB(1) AB(2);
         AC(1) AC(2)];
    detJ = det(J);

    for i = 1 : num_gauss_points_per_triangle
        % Coordinates in auxiliary system
        r = rsw(i,1);
        s = rsw(i,2);
        w = rsw(i,3);
        xi_eta = (1 - r - s)*A + r*B + s*C;
        
        % Store them
        gp = gp + 1;
        xew(gp , 1:2) = xi_eta;
        xew(gp , 3) = w * detJ;
    end
end

end

