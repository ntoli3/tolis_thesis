function [line_intersects_elements]=line_intersects(coordinates_xel,distance_func,l)
line_intersects_elements=all(abs(distance_func(coordinates_xel(:,1)))<=l);
end