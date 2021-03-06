% Thomas Satterly
% AAE 550
% HW 1, Part II (a)
clear;
close all;
clc;

% Setup problem
aae550.hw1.partII_setup;


cs = ones(1, numel(gs));
% Set constraint coefficients

for i = 1:numel(gs)
    gs{i} = @(x) cs(i) * gs{i}(x);
end

% Define penalty coefficient
rp = 1e3;
maxErr = 1e-6;
err = inf;
fLast = inf;
x0 = [0.3805; 0.3697];
isValid = 0;
minCount = 0;
iterationCount = 0;
j  = 0;
cj = ones(size(gs));
while err > maxErr || max(gx) > 1e-4;
    j = j + 1;
    
    % Update constraint coefficients
%     dx = 1e-3;
%     gradF = [f(x0 + [dx; 0]) - f(x0 - [dx; 0]); ...
%         f(x0 + [0; dx]) - f(x0 - [0; dx])] ./ (2 * dx);
%     for i = 1:numel(gsOrig)
%         gradG = [gsOrig{i}(x0 + [dx; 0]) - gsOrig{i}(x0 - [dx; 0]); ...
%             gsOrig{i}(x0 + [0; dx]) - gsOrig{i}(x0 - [0; dx])] ./ (2 * dx);
%         cj(i) = norm(gradF) / norm(gradG);
%     end
    
    % Create pseudo-objective function
    objFunc = @(x) aae550.hw1.extPenalty(f, x, rp, gs, cj);
    
    options = optimoptions(@fminunc, 'Display', 'iter', 'PlotFcn', @optimplotfval);
    
    [x_opt, f_opt, exitFlag, output, grad] = fminunc(objFunc, x0, options);
    [~, gx] = aae550.hw1.checkConstraints(gsOrig, x_opt);
    
    % Record values for table
    data(j).minimization = j;
    data(j).rp = rp;
    data(j).x0 = x0;
    data(j).xOpt = x_opt;
    data(j).fOpt = f(x_opt);
    data(j).gx = gx;
    data(j).iterations = output.iterations;
    data(j).exitFlag = exitFlag;
    
    err = abs(f_opt - fLast);
    fLast = f_opt;
    x0 = x_opt;
    rp = rp * 5;
    
    % Update counters
    minCount = minCount + 1;
    iterationCount = iterationCount + output.iterations + 1; % Oh, so now Matlab decides to start indecies at 0
end

% Make sure final solution is valid
[isValid, gx] = aae550.hw1.checkConstraints(gs, x_opt);
assert(isValid, 'Solution is invalid!');

% Post data to excel table

% File name
fName = [mfilename('fullpath'), '.xlsx'];

if exist(fName, 'file') == 2
    delete(fName);
end

% Create table column titles
gCell = {};
for i = 1:numel(gs)
    gCell{i} = sprintf('g%d(x_star)', i);
end
xlswrite(fName, {'Minimization', 'r_p', 'x_0', 'x_star', 'f(x_star)', gCell{:}, '# of Iterations', 'Exit Flag'}, 'sheet1');

for i = 1:numel(data)
    dataCell = {};
    dataCell{1} = data(i).minimization;
    dataCell{2} = data(i).rp;
    dataCell{3} = num2str(data(i).x0');
    dataCell{4} = num2str(data(i).xOpt');
    dataCell{5} = data(i).fOpt;
    for j = 1:numel(data(i).gx)
        dataCell{end + 1} = data(i).gx(j);
    end
    dataCell{end + 1} = data(i).iterations;
    dataCell{end + 1} = data(i).exitFlag;
    xlswrite(fName, dataCell, 'sheet1', sprintf('A%d', i + 1));
end
