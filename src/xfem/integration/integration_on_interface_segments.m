function [xew] = integration_on_interface_segments(element_id, ...
    intersection_segments, num_gauss_points_per_segment)
% Finds the Gauss points on the line segments defined by the LSM interface inside an element, w.r.t 
% the element's natural coord system.
% Ιnput: 
% intersection_segments = object of IntersectionSegments
% num_gauss_points_per_segment = how many Gauss points to use per segment
% Output: 
% xew = matrix (num_gp x 3) containing the natural coords ξ,η and weight for each Gauss point.

num_segments = intersection_segments.countSegmentsOfElement(element_id);

% Coordinates and weights of each segment in the auxiliary coord system (r)
rw = gauss_integration_1D(num_gauss_points_per_segment);

% Coordinates in the natural system (xi, eta) if the element, for all segments
num_gauss_points_of_element = num_segments * num_gauss_points_per_segment;
xew = zeros(num_gauss_points_of_element, 3);
gp = 0;
for t = 1 : num_segments
    % Triangle point coords in natural system
    segment_points_natural = intersection_segments.findNaturalCoordsOfSegment(t, element_id);
    A = segment_points_natural(1,:);
    B = segment_points_natural(2,:);
    detJ = 0.5 * norm(B-A);
    
    for i = 1 : num_gauss_points_per_segment
        % Coordinates in auxiliary system
        r = rw(i,1);
        w = rw(i,2);
        xi_eta = (1 - r)/2 * A + (1 + r)/2 * B;
        
        % Store them
        gp = gp + 1;
        xew(gp , 1:2) = xi_eta;
        xew(gp , 3) = w * detJ;
    end
end


end

