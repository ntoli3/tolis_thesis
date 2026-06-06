function [] = plot_circle(x_center, y_center, radius, fig)
% Create a vectortheta.
theta = linspace(0,2*pi,200); 

% Generate x-coordinates.
x = x_center + radius*cos(theta); 

% Generate y-coordinate.
y = y_center + radius*sin(theta); 

% plot the circle.
figure(fig)
plot(x,y); 

 % Set equal scale on axes.
axis('equal');

end