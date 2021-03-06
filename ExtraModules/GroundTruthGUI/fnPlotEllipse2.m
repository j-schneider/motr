function hHandle = fnPlotEllipse2(fX,fY,fA,fB,fTheta, afCol, iLineWidth, hAxes)
% Plots an ellipse which is represented as a 5 tuple.
%
% Inputs:
%   <fX,fY,fA,fB,fTheta> - ellipse parameters
%    afCol - 1x3 color vector (RGB)
%    iLineWidth - 1x1 line width
% Outputs:
%    hHandle - handle to the plotted ellipse
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

N = 60;

% Generate points on circle
%fTheta = fTheta + pi/2;
afTheta = linspace(0,2*pi,N);%2*pi*[0:N]/N;
apt2f = [fA * cos(afTheta); fB * sin(afTheta)];
R = [ cos(fTheta), sin(fTheta);
    -sin(fTheta), cos(fTheta)];
apt2fFinal = R*apt2f + repmat([fX;fY],1,N);
hHandle  = plot(hAxes, apt2fFinal(1,:), apt2fFinal(2,:),'Color', afCol, 'LineWidth', iLineWidth);

return;
