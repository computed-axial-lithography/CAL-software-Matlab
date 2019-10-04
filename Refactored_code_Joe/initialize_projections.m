function [projections] = initialize_projections(params,target,verbose)
% Function to make initial guess of projections for an input voxelized
% target. First, performs Radon transform at each layer in the target, ramp filter,
% truncate negatives, and combine projections into matrix of dimensions: nR x nTheta x nZ
%
% Input:
%   target = matrix, 2D or 3D matrix of the design target
%   params.angles = vector, angles in degrees at which the Radon transform should
%   be calculated
%   verbose = 1 or 0, activates or deactivates visualization of the
%   projections and additional information display
%
% Output:
%   projections = matrix, 2D matrix if target is 2D, dimensions: nR x
%   nTheta; 3D matrix if target is 3D, dimensions: nR x nTheta x nZ
%
% Created by: Indrasen Bhattacharya 2017-05-07
% Modified by: Joseph Toombs 08/2019

addpath('inferno_bin') % addpath containing files for inferno colormap

if ~exist('verbose','var')
    verbose = 0;
end

% Start local parallel pool if parallel computation is desired
if ~isfield(params,'parallel')
    params.parallel = 0;
else 
    if params.parallel == 1
        pool = gcp;
        if isempty(pool)
            pool = parpool('local',8);
        end
    end    
end

if verbose
    fprintf('Beginning initialization of projections\n');
    tic;
end



% Determine if target is 2D or 3D
if numel(size(target)) == 2
    [nX, nY] = size(target);
else 
    [nX, nY, nZ] = size(target);
end

% Determine dimensions of the output projection matrix
nTheta = length(params.angles);
nR = round(sqrt(nX^2+nY^2));
if (mod(nR,2)~=0)
    nR = nR+1;
end


% Preallocate projection matrix
if numel(size(target)) == 2
    projections = zeros(nR,nTheta); % projections matrix for 2D target
else
    projections = zeros(nR,nTheta,nZ); % projections matrix for 3D target
end



rampK = abs(linspace(-1,1,nR)).'; % Create ramp filter vector in Fourier space
rampK_matrix = repmat(rampK,[1,nTheta]); % Repeat vector for each angle in projections


% 2D target and reconstructions
if numel(size(target)) == 2
    
    projections = imresize(radon(target, params.angles),[nR nTheta]);
    FT_projections = fftshift(fft(projections,[],1)); % Fourier transform projections
    projections = real(ifft(ifftshift(FT_projections.*rampK_matrix))); % apply ramp filter in Fourier space
    projections = double(projections > 0).*(projections); % truncate negatives

else
    if params.parallel
        parfor z = 1:nZ
            projection_z = imresize(radon(target(:,:,z), params.angles),[nR nTheta]);
            FT_projection_z = fftshift(fft(projection_z,[],1)); % Fourier transform projections
            projection_z = real(ifft(ifftshift(FT_projection_z.*rampK_matrix))); % apply ramp filter in Fourier space
            projection_z = double(projection_z > 0).*(projection_z); % truncate negatives
            projections(:,:,z) = projection_z;
        end
    else
        for z = 1:nZ
            projection_z = imresize(radon(target(:,:,z), params.angles),[nR nTheta]);
            FT_projection_z = fftshift(fft(projection_z,[],1)); % Fourier transform projections
            projection_z = real(ifft(ifftshift(FT_projection_z.*rampK_matrix))); % apply ramp filter in Fourier space
            projection_z = double(projection_z > 0).*(projection_z); % truncate negatives
            projections(:,:,z) = projection_z;
        end 
    end
end


if verbose
    figure(20);
    if numel(size(target)) == 2
        imagesc(projections)
        colormap inferno
    else
        set(gcf,'position',[500 500 1200 400]);
        
        subplot(1,4,1)
        imagesc(squeeze(projections(:,1,:))')
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(1));
        title(str)
        axis off
        
        subplot(1,4,2)
        imagesc(squeeze(projections(:,round(nTheta*1/3),:))')
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(round(nTheta*1/3)));
        title(str)
        axis off
        
        subplot(1,4,3)
        imagesc(squeeze(projections(:,round(nTheta*2/3),:))')    
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(round(nTheta*2/3)));
        title(str)
        axis off
        
        subplot(1,4,4)
        imagesc(squeeze(projections(:,nTheta,:))')
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(nTheta));
        title(str)
        axis off
    end
    pause(0.5);
    runtime = toc;
    fprintf('Finished initialization of projections in %.2f seconds\n\n',runtime);
end

