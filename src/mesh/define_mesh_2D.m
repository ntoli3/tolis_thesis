function mesh = define_mesh_2D(num_nodes_x, num_nodes_y, max_x, max_y)
% Defines the properties of a 2D mesh
% Input:
% num_nodes_x = arithmos komvwn kata x
% num_nodes_y = arithmos komvwn kata y
% max_x = megisti timi syntetagmenis x
% max_y = megisti timi syntetagmenis y
% Output:
% mesh = a 2D mesh

% Dimension
mesh.dimension = 2;

% Nodes & elements
mesh.num_nodes = [num_nodes_x num_nodes_y]; % Number of nodes along each axis
mesh.num_elements = [num_nodes_x-1, num_nodes_y-1]; % Number of elements along each axis 

% Geometry
mesh.axis_length = [max_x max_y]; % Length of domain along each axis
dx = max_x / (num_nodes_x - 1);
dy = max_y / (num_nodes_y - 1);
mesh.element_length = [dx dy]; % Element length along each axis

end