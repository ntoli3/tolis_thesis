function [gauss_points] = integration_on_interface_segments(element_id, ...
    intersection_segments, num_gauss_points_per_segment)
% Finds the Gauss points on the line segments defined by the LSM interface inside an element, w.r.t 
% the element's natural coord system.
% Ιnput: 
% intersection_segments = object of IntersectionSegments
% num_gauss_points_per_segment = how many Gauss points to use per segment
% Output: 
% gauss_points = matrix (num_gauss_points x 5) with columns: xi, eta, t_xi, t_eta, w. 
%   (t_xi t_eta) is the tangent vector in the natural system and w is the reference weight. 

num_segments = intersection_segments.countSegmentsOfElement(element_id);

% Coordinates and weights of each segment in the auxiliary coord system (r)
sw = gauss_integration_1D(num_gauss_points_per_segment);

% Coordinates in the natural system (xi, eta) if the element, for all segments
num_gauss_points_of_element = num_segments * num_gauss_points_per_segment;
gauss_points = zeros(num_gauss_points_of_element, 5);
gp = 0;
for k = 1 : num_segments
    % Triangle point coords in natural system
    segment_points_natural = intersection_segments.findNaturalCoordsOfSegment(k, element_id);
    A = segment_points_natural(1,:);
    B = segment_points_natural(2,:);
    t = 0.5 * B-A;
    
    for i = 1 : num_gauss_points_per_segment
        % Coordinates in auxiliary system
        s = sw(i,1);
        xi_eta = (1 - s)/2 * A + (1 + s)/2 * B;
        
        % Store them
        gp = gp + 1;
        gauss_points(gp, 1:2) = xi_eta;
        gauss_points(gp, 3:4) = t;
        gauss_points(gp, 5) = sw(i,2);
    end
end


end

