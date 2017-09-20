% Thomas Satterly
% AAE 537
% HW 1, Problem 1

clear;
close all;

import aeroBox.shockBox.*;

gamma = 1.4;
% Mach 2 conditions
rampAngle = 4; % degrees

% Part (i)
% Solve for the total turning angle at the end when M_0 = 2
[shockAngle, M1] = calcObliqueShockAngle('rampAngle', rampAngle, ...
    'mach', 2, 'gamma', gamma, 'useDegrees', 1);
v1 = aeroBox.shockBox.prandtlMeyerFcn('mach', M1, 'gamma', 1.4);
v_end = aeroBox.shockBox.prandtlMeyerFcn('mach', 1, 'gamma', 1.4);
isoRampTurning = rad2deg(v1 - v_end);
totalTurning = isoRampTurning + rampAngle;
% End Part (i)


% Part (ii)
% Solve for conditions and geometry at mach 4

% Ramp section
[shockAngle, M1] = calcObliqueShockAngle('rampAngle', rampAngle, ...
    'mach', 4, 'gamma', gamma, 'useDegrees', 1);
v1 = aeroBox.shockBox.prandtlMeyerFcn('mach', M1, 'gamma', 1.4);
x(1) = 0;
x_0 = 1 / tand(shockAngle);
h_0 = 1; % Total inlet height (to cowl lip)
% Solve for h_w
slope1 = tand(rampAngle + asind(1 / M1));
slope2 = tand(rampAngle);
yInt1 = h_0 - slope1 * x_0;
yInt2 = 0;
x_w = (yInt2 - yInt1) / (slope1 - slope2);

%mu_0 = asind(1 / 4);
%y_w = (x_0 - (h_0 / tand(rampAngle + mu_0))) / ((1 / tand(rampAngle)) - (1 / (tand(rampAngle + mu_0))));
h_w = h_0 - slope2 * x_w;
%mu_w = asind(1 / M1);

% Isentropic spike section


startMach = M1;
endMach = aeroBox.shockBox.calcPMExpansionFan('mach', M1, 'gamma', 1.4, 'useDegrees', 1, 'turningAngle', -isoRampTurning);
numSteps = 20;
machs = linspace(startMach, endMach, numSteps - 1);

% fAngle = asind(1 / endMach) + totalTurning;
% fx = [0, x_0];
% yInt = h_0 - x_0 * tand(fAngle);
% fy = [yInt, h_0];

% M_enter = M1;
% lastSlope = tand(rampAngle);
% lastYInt = 0;
slope2 = tan(deg2rad(rampAngle));
yInt2 = 0;
for i = 1:numel(machs);
    thisMach = machs(i);
    mu = asin(1 / thisMach);
    v =  aeroBox.shockBox.prandtlMeyerFcn('mach', thisMach, 'gamma', 1.4);
    h(i) = h_w * (M1 / thisMach) * ((2 + (gamma - 1) * M1^2) / (2 + (gamma - 1) * thisMach^2))^-((gamma + 1) / (2 * (gamma - 1)));
    x(i) = x_0 - h(i) / (tan(mu + deg2rad(rampAngle) + v1 - v));
    
%     [shockAngle, M_enter] = calcObliqueShockAngle('rampAngle', angleStep, ...
%         'mach', M_enter, 'gamma', gamma, 'useDegrees', 1);
%     shockSlope = tand(shockAngle + (i * angleStep) + rampAngle);
%     yInt = h - (shockSlope * l);
%     x(1 + i) = (yInt - lastYInt) / (lastSlope - shockSlope);
%     y(1 + i) = shockSlope * x(1 + i) + yInt;
%     lastSlope = tand((i * angleStep) + rampAngle);
%     lastYInt = y(1 + i) - (lastSlope * x(1 + i));
end

% Inlet so far
x = [0, x_w, x];
y = h_0 - [h_0, h_w, h];

% End of part (ii)



% Part (iii)
% Determine throat height & make throat with an entry


% Find the ratio of throat height to length
LtOverHt = 10 * ((endMach - 1) / 2.2)^0.5;

h2 = h_0 - (slope2 * x_0);
h3 = h2 * cosd(rampAngle);
ht = h3 / aeroBox.isoBox.calcARatio(M1, gamma);
rad = 4 * ht; % If this is to be beleived

% Extend the iso ramp to give a throat of ht after the arc
y(end + 1) = 1 - ht - (rad - cosd(totalTurning) * rad);
x(end + 1) = (y(end) - y(end - 1)) / tand(totalTurning) + x(end);

% Arc parameters

yc = y(end) - cosd(totalTurning) * rad;
xc = x(end) + sind(totalTurning) * rad;

% Draw the arc
numPoints = 200;
startAngle = 360 - totalTurning;
endAngle = 360;
angleStep = (endAngle - startAngle) / numPoints;
for i = 1:numPoints
    xr(i) = xc + sind(startAngle + angleStep * i) * rad;
    yr(i) = yc + cosd(startAngle + angleStep * i) * rad;
end

% Add the arc and throat
x = [x xr (xr(end) + ht * LtOverHt)];
y = [y yr yr(end)];

% Diffuser

% Area function
areaFunc = @(x, angle, r) (pi * (r^2 - (r - tand(angle) * x)^2)) / (pi * r^2);

throatEndHeight = y(end);
diffAngle = 3;
dMin = 0;
dMax = throatEndHeight / tand(diffAngle);
numSteps = 200;
dStep = (dMax - dMin) / numSteps;
for i = 1:numSteps
    areaRat = areaFunc(i * dStep, diffAngle, throatEndHeight);
    xd(i) = x(end) + dStep * i;
    yd(i) = throatEndHeight - areaRat * throatEndHeight;
end

x = [x xd];
y = [y yd];

figure;
hold on;
plot(x, y, 'k');
axis equal;


% Now let's make the cowl
xCowl(1) = x_0;
yCowl(1) = h_0;

% Translate the arc
startAngle = 360 - atand((xc - xCowl) / (yCowl - yc));
endAngle = 360;
numPoints = 200;
angleStep = (endAngle - startAngle) / numPoints;
rad = sqrt((xCowl - xc)^2 + (yCowl - yc)^2);
for i = 1:numPoints
    xCowl(i) = xc + sind(startAngle + angleStep * i) * rad;
    yCowl(i) = yc + cosd(startAngle + angleStep * i) * rad;
end

% Extend cowl to the end of the diffuser
xCowl(end + 1) = x(end);
yCowl(end + 1) = yCowl(end);

plot(xCowl, yCowl, 'k');




