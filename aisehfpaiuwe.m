clc;
clear;
close all;

fx = @(x1, x2, x3) 2 * x1^2 + 3 * x2^2 + x3^2 + 4 * x1 * x2 + 0.2 * x2 * x3;
dfx1 = @(x1, x2, x3, xi) (fx(x1 + xi, x2, x3) - fx(x1, x2, x3)) / xi;
dfx2 = @(x1, x2, x3, xi) (fx(x1, x2 + xi, x3) - fx(x1, x2, x3)) / xi;
dfx3 = @(x1, x2, x3, xi) (fx(x1, x2, x3 + xi) - fx(x1, x2, x3)) / xi;
xi = 1e-6;
x = [5 1 10];
numSteps = 500;
for i = 1:numSteps
    dx = -[dfx1(x(i, 1), x(i, 2) ,x(i, 3), xi), ...
        dfx2(x(i, 1), x(i, 2) ,x(i, 3), xi), ...
        dfx3(x(i, 1), x(i, 2) ,x(i, 3), xi)];
        
    alpha_1 = @(alpha) x(i, 1) + alpha * dx(1);
    alpha_2 = @(alpha) x(i, 2) + alpha * dx(2);
    alpha_3 = @(alpha) x(i, 3) + alpha * dx(3);
    
    
    fAlpha = @(alpha) fx(alpha_1(alpha), alpha_2(alpha), alpha_3(alpha));
    alpha = fminunc(fAlpha, 0.1);
    
    x(i + 1, :) = x(i, :) + alpha * dx;
end


plot3(x(:, 1), x(:, 2), x(:, 3));