% orismos diastasewn tou plegmatos
Nx = 100; %arithmos kombwn sth dieuthunsh x
Ny = 100; %arithmos kombwn sth dieuthunsh y

% orismos twn oriwn toy xwrou
x_min = 0;
x_max = 1;
y_min = 0;
y_max = 1;

% dhmioyrgia plegmatos me omoiomorfh katanomh
x = linspace(x_min, x_max, Nx)
y = linspace (y_min, y_max, Ny)

% dhmioyrgia plegmatos me xrhsh pinakwn plegmatos
[X, Y] = meshgrid(x, y)

% emfanish plegamtos
figure;
plot(X, Y, 'k.', 'MarkerSize', 5);
axis equal;
xlabel('X');
ylabel('Y');
title('[PLEGMA 100x100 KOMBWN');
grid on;

% metatroph tvn plegmatwn se lista syntetagmenwn kombwn
node_coords = [X(:), Y(:)];


