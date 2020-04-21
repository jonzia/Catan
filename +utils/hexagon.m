function [x, y] = hexagon(x_center, y_center)

% -------------------------------------------------------------------------
% This function returns the x and y coordinates of the vertices of a
% hexagon with unit side length centered on (x_center, y_center).
% -------------------------------------------------------------------------

% Set angles at which vertices are found
t = ((1/12):(1/6):1)'*2*pi + pi/2;

% Compute x and y coordinates
x = sin(t) + x_center; x = [x; x(1)];
y = cos(t) + y_center; y = [y; y(1)];
x = round(x, 4); y = round(y, 4);

end

