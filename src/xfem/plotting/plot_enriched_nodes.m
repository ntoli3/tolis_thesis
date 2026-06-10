function [] = plot_enriched_nodes(node_coords, enr_nodes, fig, color, point_size)

% Find the coords of enriched nodes
num_nodes = size(node_coords, 1);
num_enriched_nodes = sum(enr_nodes == 1);
xy = zeros(num_enriched_nodes, 2);
idx = 0;
for n = 1 : num_nodes
    if enr_nodes(n)==1
        idx = idx + 1;
        xy(idx,:) = node_coords(n,:);
    end
end

% Plot them
figure(fig)
hold on
h = plot(xy(:,1), xy(:,2), 'o', 'Color', color, 'MarkerFaceColor', 'none', 'MarkerSize', point_size);
legend(h, 'Enriched nodes')

end