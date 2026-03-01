function [] = plot_intersected_elements(node_coords_all, element_nodes, phi_nodes_all, fig)
% sxediazei to plegma me ola ta element, ton kyklo kai xrwmatizei ta elements analoga an kovontai
% input:
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% element_nodes = pinakas pou periexei toys kombous toy kathe element
% phi nodes all = pinakas(num_nodes,1) poy exei tis level sets olwn twn kombwn toy plegmatos
% fig = o arithmos toy figure poy tha ginei h sxediash
% output: 


[intersected_elements] = check_intersection_elements_lsm (phi_nodes_all, element_nodes);

% pgon = polyshape([x1 x2 x3 x4], [y1 y2 y3 y4]);
num_elements = size(element_nodes,1);
figure(fig)
for e = 1 : num_elements
    X = zeros(1,4);
    Y = zeros(1,4);

    for j = 1 : 4 
        n = element_nodes(e,j); 
        X(1,j) = node_coords_all(n,1); 
        Y(1,j) = node_coords_all(n,2); 
    end
    pgon = polyshape(X, Y);
    hold on

    if intersected_elements(e) == 1
 
       plot(pgon,'FaceColor','yellow','FaceAlpha',0.1);
        
    else 
       plot(pgon,'FaceColor','blue','FaceAlpha',0.1);
     
     end

end
end