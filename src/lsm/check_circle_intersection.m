function [intersected_elements] = check_circle_intersection(x_c, y_c, radius, node_coords_all, element_nodes)
% elegxei an to element temnetai apo ton kyklo  
% input : 
% xc = to x toy kentroy toy kykloy
% yc = to y toy kentroy toy kykloy
% radius = aktina toy kykloy
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% element nodes = pinakas poy periexei toys kombous toy kathe element
% output : 
% intersected_elements = pinakas poy periexei tis times 1 kai 0 analoga an to element temnetai h oxi apo ton kyklo 

% elements: osa kai oi grammes toy element_nodes
num_elements = size(element_nodes,1); %size(A,1)= poses grammes exei o A, size(A,2)= poses sthles exei o A
%num_nodes = size(node_coords,1); 

% pinakas apotelesmatwn
intersected_elements = zeros(num_elements, 1);

% ypologizw tis apostaseis twn kombwn apo ton kyklo
for i = 1 : num_elements
    distances = zeros(1,4); 
    for j = 1 : 4 %einai oi komboi tou element
        n = element_nodes(i,j); % einai to noumero oty kombou
        x = node_coords_all(n,1); %einai to x toy kombou
        y = node_coords_all(n,2); % einai to y toy kombou

   d = sqrt((x-x_c).^2 + (y-y_c).^2) - radius;
   distances(1,j) = d;
      
    end 
% koitame an kobetai to element
       if min(distances) * max(distances) <= 0

        intersected_elements(i) = 1;
       else
        intersected_elements(i) = 0;
       end
   
end

end