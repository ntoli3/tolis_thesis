classdef IntersectionMesh < handle
    % Represents the subtriangles created by the intersection of the level 
    % set interface with each element 

    properties
        point_coords_list_cartesian; % lista. Ana element apothikeuetai matrix me syntetagmenes(cartesian) twn shmeiwn twn trigwnwn tou
        point_coords_list_natural; % lista. Ana element apothikeuetai matrix me syntetagmenes(natural) twn shmeiwn twn trigwnwn tou 
        triangle_points_list % lista. Ana element apothikeuetai matrix me arithish twn shmeiwn twn trigwnwn tou 
    end

    methods
        function obj = IntersectionMesh(point_coords_list_cartesian, ...
                point_coords_list_natural, triangle_points_list)
            % Constructor
            % Input: 
            % triangle_points_list = lista. Ana element apothikeuetai matrix me arithish twn shmeiwn twn trigwnwn tou 
            % point_coords_list_cartesian = lista. Ana element apothikeuetai matrix me syntetagmenes(cartesian) twn shmeiwn twn trigwnwn tou 
            % point_coords_list_natural = lista. Ana element apothikeuetai matrix me syntetagmenes(natural) twn shmeiwn twn trigwnwn tou
            
            obj.point_coords_list_cartesian = point_coords_list_cartesian;
            obj.point_coords_list_natural = point_coords_list_natural;
            obj.triangle_points_list = triangle_points_list;
        end

        function num_triangles = countTrianglesOfElement(obj, element_id)
            % Counts how many subtriangles belong to a specific element.
            % INPUT:
            % element_id: ID of the element whose subtriangles will be counted.
            % OUTPUT:
            % num_triangles: Number of subtriangles stored for the selected element.
            triangles_of_element = obj.triangle_points_list{element_id};
            num_triangles = size(triangles_of_element, 1);
        end

        function coords = findNaturalCoordsOfTriangle(obj, triangle_index, element_id)
            % Returns the natural coordinates of the three points of a selected subtriangle inside a selected element.
            % INPUT:
            % triangle_index: Local index of the triangle inside the selected element.
            % element_id: ID of the element that contains the triangle.
            % OUTPUT:
            % coords: Matrix (3 x 2) containing the natural coordinates [xi eta] of the three triangle points.
            triangles_of_element = obj.triangle_points_list{element_id};
            points_of_triangle = triangles_of_element(triangle_index, :);
            point_coords_of_element = obj.point_coords_list_natural{element_id};
            coords = zeros(3, 2);
            for p = 1:3
                point_index = points_of_triangle(p);
                coords(p, :) = point_coords_of_element(point_index, :);
            end
        end

    end
end