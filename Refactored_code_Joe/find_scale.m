function [projections_power,scale] = find_scale(projections)
% Function to find the optimal value that scales the input projections to produce power
% distribution that maximizes the total output power, so that print time can
% be reduced
%
% Input:
%   projections = matrix, for 2D target projections size is nR x nTheta; 
%   for 3D target projections size is nR x nTheta x nZ
%
% Output:
%   projPower = matrix, projections mapped to the calibration curve of real
%   intensities of the projector
%   scale = scalar, value of the scaling factor used
%
% Created by: Indrasen 2017-06-13
% Modified by: Joseph Toombs 08/2019

   
[Values, Edges] = histcounts(projections(:)); % bins the projections into 
Edges = Edges(1:end-1);

vMax = mean(Edges(Edges.*Values == max(Edges.*Values)));
scale = 100/vMax;


proj_actual = uint8(projections*scale)+1; % changes data type to 8-bit values with range of 1-256 for projection
projections_power = projectorMap(proj_actual); % maps projActual to the calibration curve of the projector


% Linear interpolation of projection intensities into projector intensity
% calibration curve 'intensity_sorted.mat' for Wintech LC4500 projector
function y = projectorMap(x)
    load('intensity_sorted.mat','intensity_sorted');  
    maxInt = max(intensity_sorted);
    y = 256*(intensity_sorted(x)-min(intensity_sorted))/maxInt; % scale projection intensities to the 
end
end
