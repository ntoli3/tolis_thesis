function [] = plot_intersection_segments(xfem_model, fig, color)

intersection_segments = xfem_model.intersection_segments;
intersected_elements = xfem_model.intersected_elements;
num_elements = length(intersected_elements);
figure(fig)
for e = 1 : num_elements
    if intersected_elements(e) ~= 0
        continue
    end
    
    % Segments for this element
    num_segments = intersection_segments.countSegmentsOfElement(e);
    for s = 1:num_segments
        segment_points = intersection_segments.findPointsOfSegment(s,e);
        point_coords = intersection_segments.findCartesianCoordsOfSegment(s,e);
        p1 = point_coords(segment_points(s,1), :);
        p2 = point_coords(segment_points(s,2), :);

        plot([p1(1) p2(1)], [p1(2) p2(2)], 'LineStyle', '-',  'Color', [0 0.6 0], 'LineWidth', 2);
    end
end

end