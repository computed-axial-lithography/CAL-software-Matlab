function show_projections(projections)
% Function that displays projections
% 
% Input:
%   projections = matrix, if 3D (nR x nTheta x nZ) the display will be
%   sequential; if 2D (nR x nTheta) the display will be in sinogram form
%
% Output:
%   none
%
% Created by: Joseph Toombs 09/2019

addpath('inferno_bin');

if numel(size(projections)) == 2
    figure(80);
    imagesc(projections)
    colormap inferno
    pause(0.1);
else
    figure(80);
    [~, nTheta, ~] = size(projections);
    for ii_theta = 1:nTheta
        imagesc(squeeze(projections(:,ii_theta,:))')
        colormap inferno
        axis equal
        axis off
        pause(0.02);
    end
end