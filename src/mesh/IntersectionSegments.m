classdef IntersectionSegments < handle
    % Represents the line segments created by the intersection of the level 
    % set interface with each element 

    properties
        point_coords_list_cartesian; % lista. Ana element apothikeuetai matrix me syntetagmenes(cartesian) twn shmeiwn twn segments tou
        point_coords_list_natural; % lista. Ana element apothikeuetai matrix me syntetagmenes(natural) twn shmeiwn twn segments tou 
    end

    methods
        function obj = IntersectionSegments(point_coords_list_cartesian, point_coords_list_natural)
            % Constructor
            % Input: 
            % point_coords_list_cartesian = lista. Ana element apothikeuetai matrix me syntetagmenes(cartesian) twn shmeiwn twn trigwnwn tou 
            % point_coords_list_natural = lista. Ana element apothikeuetai matrix me syntetagmenes(natural) twn shmeiwn twn trigwnwn tou
            
            obj.point_coords_list_cartesian = point_coords_list_cartesian;
            obj.point_coords_list_natural = point_coords_list_natural;
        end

        function num_segments = countSegmentsOfElement(obj, element_id)
            % Counts how many segments belong to a specific element.
            % INPUT:
            % element_id = ID of the element whose subtriangles will be counted.
            % OUTPUT:
            % num_triangles = Number of subtriangles stored for the selected element.
            points_of_element = obj.point_coords_list_cartesian{element_id};
            num_segments = size(points_of_element, 1) - 1;
        end

        function coords = findNaturalCoordsOfSegment(obj, segment_index, element_id)
            % Returns the natural coordinates of the 2 points of a selected segment inside a selected element.
            % INPUT:
            % segment_index = Local index of the triangle inside the selected element.
            % element_id = ID of the element that contains the segment.
            % OUTPUT:
            % coords: Matrix (2 x 2) containing the natural coordinates [xi eta] of the three triangle points.
            
            point_coords_of_element = obj.point_coords_list_natural{element_id};
            coords = zeros(2, 2);
            coords(1,:) = point_coords_of_element(segment_index, :);
            coords(2,:) = point_coords_of_element(segment_index + 1, :);
        end

        function coords = findCartesianCoordsOfSegment(obj, segment_index, element_id)
            % Returns the natural coordinates of the 2 points of a selected segment inside a selected element.
            % INPUT:
            % segment_index = Local index of the triangle inside the selected element.
            % element_id = ID of the element that contains the segment.
            % OUTPUT:
            % coords = Matrix (2 x 2) containing the natural coordinates [xi eta] of the three triangle points.
            
            point_coords_of_element = obj.point_coords_list_cartesian{element_id};
            coords = zeros(2, 2);
            coords(1,:) = point_coords_of_element(segment_index, :);
            coords(2,:) = point_coords_of_element(segment_index + 1, :);
        end

        function idxs = findPointsOfSegment(obj, segment_index, element_id)
            % Returns the ids the 2 points of a selected segment inside a selected element.
            % INPUT:
            % segment_index = Local index of the triangle inside the selected element.
            % element_id = ID of the element that contains the segment.
            % OUTPUT:
            % coords = Vector (2 x 1) containing the natural coordinates [xi eta] of the three triangle points.
            
            idxs = [segment_index, segment_index+1];
        end

        function n = findNormalOfSegment(obj, segment_index, element_id)
            % Returns the unit normal vector that points towards the region phi>0 
            % of a selected segment inside a selected element.
            % INPUT:
            % segment_index = Local index of the triangle inside the selected element.
            % element_id = ID of the element that contains the segment.
            % OUTPUT:
            % n = unit normal vector
            
            coords = obj.findCartesianCoordsOfSegment(segment_index, element_id);
            x1 = coords(1,:);
            x2 = coords(2,:);
            t = x2 - x1; % tangent vector
            n = [t(2); -t(1)]; % normal vector
            n = n / norm(n);
        end

    end
end