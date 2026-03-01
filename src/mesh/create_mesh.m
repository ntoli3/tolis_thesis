function [node_coords_all, element_nodes] = create_mesh(Nx, Ny, x_min, x_max, y_min, y_max)
% dhmioyrgei plegma me omoiomorfh katanomh
% input :
% Nx = arithmos kombwn sth dieuthunsh x
% Ny = arithmos kombwn sth dieuthunsh y
% x min = elaxisto x
% x max = megisto x
% y min = elaxisto y
% y max = megisto y
% output :
% node coords = pinakas poy periexei tis syntetagmenes twn kombwn
% element nodes = pinakas pou periexei toys kombous toy kathe element

node_coords_all = zeros(Nx * Ny, 2);
dx = (x_max - x_min)/ (Nx - 1);
dy = (y_max - y_min)/ (Ny -1);
n = 0;
for i = 1 : Ny
    for j = 1 : Nx 
        n = n + 1;
        x = x_min + dx * (j - 1); % einai to x toy kombou j,i
        y = y_min + dy * (i - 1); % einai to y toy kombou j,i
        node_coords_all(n,1) = x;
        node_coords_all(n,2) = y;

    end

end

% emfanish plegamtos
%figure;
% plot(X, Y, 'rs', 'MarkerSize', 5);
% axis equal;
% xlabel('X');
% ylabel('Y');
% title('KOMBOI');
% grid on;

% metatroph tvn plegmatwn se lista syntetagmenwn kombwn
%node_coords = [Y(:), X(:)];

% elements
num_elements = (Nx-1)*(Ny-1);
element_nodes = zeros(num_elements, 4);
for i = 1 : Nx-1
    for j = 1 : Ny-1
        t = (j-1)*(Nx-1) + i; % eniaia arithmisi stoixeiou
        I = i; % 2D arithmisi toy katw aristera kombou
        J = j;

        element_nodes(t,1) = (J-1)*Nx + I;
        element_nodes(t,2) = (J-1)*Nx + (I+1);
        element_nodes(t,3) = ((J+1)-1)*Nx + (I+1);
        element_nodes(t,4) = ((J+1)-1)*Nx + I;
    end
end
end




