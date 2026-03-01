function [distances] = compute_distance_from_circle(x_c, y_c, radius, node_coords_all)
% ypologizei thn apostash kathe komboy apo ton kyklo
% input : 
% xc = to x toy kentroy toy kykloy
% yc = to y toy kentroy toy kykloy
% radius = aktina toy kykloy
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% output : 
% distances = pinakas poy periexei tis times twn apostasewn metaji komboy kai kykloy

num_nodes = size(node_coords_all, 1); % etsi briskw tis grammes enos pinaka!!!


 for i = 1 : num_nodes
       x_i = node_coords_all(i,1);
       y_i = node_coords_all(i,2);

       d = sqrt((x_i-x_c).^2 + (y_i-y_c).^2) - radius;

    
       distances(i,1) = d;
 end
 

end