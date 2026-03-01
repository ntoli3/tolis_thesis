function [] = plot_intersection_triangles(node_coords_all, element_nodes,...
    phi_nodes_all, point_coords_list, triangle_points_list, fig)
% sxediazei ta trigwna pou prokyptoun apo thn tomh twn stoixeiwn me thn kampylh 
% input:
% node coords all = pinakas poy periexei tis syntetagmenes twn kombwn
% element nodes = pinakas pou periexei toys kombous toy kathe element
% phi nodes all = pinakas(num_nodes,1) poy exei tis level sets olwn twn kombwn toy plegmatos
% point coords list = lista me tis syntetagmenes tvn shmeiwn kathe stoixeioy
% triangle points list = lista me toys komboys gia kathe trigwno poy dhmioyrgeitai ana stoixeio
% fig = o arithmos toy figure poy tha ginei h sxediash
% output:


[intersected_elements] = check_intersection_elements_lsm (phi_nodes_all, element_nodes);

% pgon = polyshape([x1 x2 x3 x4], [y1 y2 y3 y4]);
num_elements = size(element_nodes,1);
figure(fig)
for e = 1 : num_elements
    if intersected_elements(e) == 1
        % vriskw ta trigwna gia ayto to element  
        triangles = triangle_points_list{e};
        coords = point_coords_list{e};
        num_triangles = size(triangles,1) ;

        % gia kathe trigwno
        for t = 1 : num_triangles
            % ftiaxnw pinakes x,y (1,3)
            x = zeros(1,3);
            y = zeros(1,3);
            % gemizw ta x,y apo ta triangle_points gia ayto to element
            for k = 1 : 3
                m = triangles(t,k);
                x(k) = coords(m,1);
                y(k) = coords(m,2);
            end
            % plotarw to polygwno(kitrino)
            pgon = polyshape(x, y);
            hold on
            plot(pgon,'FaceColor','red','FaceAlpha',0.1);
        end

    else 
        X = zeros(1,4);
        Y = zeros(1,4);
    
        for j = 1 : 4 
            n = element_nodes(e,j); 
            X(1,j) = node_coords_all(n,1); 
            Y(1,j) = node_coords_all(n,2); 
        end
        pgon = polyshape(X, Y);
        hold on
        plot(pgon,'FaceColor','blue','FaceAlpha',0.1);
     
    end

end

end