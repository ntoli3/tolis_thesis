function [] = plot_intersection_segments(xfem_model, fig, color, normal_head_size)

normal_scale = 0.2;

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
        % Line segment
        segment_points = intersection_segments.findPointsOfSegment(s,e);
        point_coords = intersection_segments.findCartesianCoordsOfSegment(s,e);
        p1 = point_coords(segment_points(s,1), :);
        p2 = point_coords(segment_points(s,2), :);

        plot([p1(1) p2(1)], [p1(2) p2(2)], 'LineStyle', '-',  'Color', color, 'LineWidth', 2);

        % Normal vector
        t = (p2 - p1); % tangent vector
        n = [t(2) -t(1)];
        n = n / norm(n);
        pm = 0.5*(p1+p2);
        scale = normal_scale * norm(p2-p1);
        n = n * scale;
        h = quiver(pm(1), pm(2), n(1), n(2), 0,'Color', color, 'LineWidth', 1);
        h.MaxHeadSize = normal_head_size;   % controls relative head scaling
    end
end

end