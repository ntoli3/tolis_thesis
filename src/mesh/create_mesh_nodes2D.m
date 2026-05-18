function node_coords = create_mesh_nodes2D(mesh) 
% Creates the node coordinates of a 2D uniform structured mesh
% Input:
% mesh: see define_mesh()
% Output: 
% node_coords = matrix where each row corresponds to one node, column 1 is
%   the x coordinate and col 2 is the y coordinate 

  dx = mesh.element_length(1);
  dy = mesh.element_length(2);
  num_nodes_x = mesh.num_nodes(1);
  num_nodes_y = mesh.num_nodes(2);
  
  node_coords = zeros(num_nodes_x * num_nodes_y, 2);

  if num_nodes_x > num_nodes_y
    for i = 1:num_nodes_x
      for j = 1:num_nodes_y
        t = (i-1)*num_nodes_y + j;
        x = (i-1)*dx;
        y = (j-1)*dy;
        node_coords(t, 1) = x;
        node_coords(t, 2) = y;
      end
    end
  else
    % Homework
    for j = 1:num_nodes_y
      for i = 1:num_nodes_x
        t = (j-1)*num_nodes_x + i;
        x = (i-1)*dx;
        y = (j-1)*dy;
        node_coords(t, 1) = x;
        node_coords(t, 2) = y;
      end
    end
  end

end
