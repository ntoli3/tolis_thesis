function [mesh, node_coords, element_nodes] = create_mesh_quad4(...
  num_nodes_x, num_nodes_y, max_x, max_y)

% Dimiourgei ena plegma apo tetrakomvika stoixeia 
% Epistrefei tis suntetagmenes olwn twn komvwn kai poioi komvoi anikoun se
% poio stoixeio 
% Input:
% num_nodes_x = arithmos komvwn kata x
% num_nodes_y = arithmos komvwn kata y
% max_x = megisti timi syntetagmenis x
% max_y = megisti timi syntetagmenis y
% Output:
% mesh: see FemModel mesh property
% node_coords: see FemModel node_coords property
% element_nodes: see FemModel element_nodes property

  mesh = define_mesh_2D(num_nodes_x, num_nodes_y, max_x, max_y);
  node_coords = create_mesh_nodes2D(mesh);
  num_elements_x = num_nodes_x - 1;
  num_elements_y = num_nodes_y - 1;
  element_nodes = zeros(num_elements_x * num_elements_y, 4);

  element_id = 0;
  if num_nodes_x > num_nodes_y
    for ie = 1:num_elements_x
      for je = 1:num_elements_y
        node1 = (ie-1)*num_nodes_y + je;
        node2 = ie*num_nodes_y + je; % (ie+1-1)*num_nodes_y + je
        node3 = node2 + 1;
        node4 = node1 + 1;
        element_id = element_id + 1;
        element_nodes(element_id, 1) = node1;
        element_nodes(element_id, 2) = node2;
        element_nodes(element_id, 3) = node3;
        element_nodes(element_id, 4) = node4;
      end
    end
  else % num_nodes_x <= num_nodes_y
    % Homework 
    for je = 1:num_elements_y
      for ie = 1:num_elements_x
        node1 = (je-1)*num_nodes_x + ie;
        node2 = (je-1)*num_nodes_x + ie + 1;   % (je+1-1)*num_nodes_x + ke + 1
        node3 = je*num_nodes_x + ie + 1;
        node4 = je*num_nodes_x + ie;
        element_id = element_id + 1;
        element_nodes(element_id, 1) = node1;
        element_nodes(element_id, 2) = node2;
        element_nodes(element_id, 3) = node3;
        element_nodes(element_id, 4) = node4;
      end
    end
  end

end