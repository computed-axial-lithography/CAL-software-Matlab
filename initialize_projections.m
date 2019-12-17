%{
Function to make initial guess of projections for an input voxelized
target. First, performs Radon transform at each layer in the target, ramp filter,
truncate negatives, and combine projections into matrix of dimensions: nR x nTheta x nZ

INPUTS:
  target = matrix, 2D or 3D matrix of the design target
  params.angles = vector, angles in degrees at which the Radon transform should
  be calculated
  params.verbose = 1 or 0, activates or deactivates visualization of the
  projections and additional information display

OUTPUTS:
  projections = matrix, 2D matrix if target is 2D, dimensions: nR x
  nTheta; 3D matrix if target is 3D, dimensions: nR x nTheta x nZ

Created by: Indrasen Bhattacharya 2017-05-07
Modified by: Joseph Toombs 08/2019

----------------------------------------------------------------------------
Copyright © 2017-2019. The Regents of the University of California, Berkeley. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the distribution.
3. Neither the name of the University of California, Berkeley nor the names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS 
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.
%}

function [projections] = initialize_projections(params,target)

addpath('inferno_bin') % addpath containing files for inferno colormap

if ~isfield(params,'verbose')
    params.verbose = 0;
end

% Start local parallel pool if parallel computation is desired and default
% to unactive if params.parallel is undefined
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

if params.verbose
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
nR = size(radon(zeros(nX,nX),params.angles),1);
% nR = 2*ceil(nX/sqrt(2))+1;
% if (mod(nR,2)~=0)
%     nR = nR+1;
% end


% Preallocate projection matrix
if numel(size(target)) == 2
    projections = zeros(nR,nTheta); % projections matrix for 2D target
else
    projections = zeros(nR,nTheta,nZ); % projections matrix for 3D target
end


% [~,projections_filtered,filter_vector] = iradon_filter(projections(:,:,1),params.angles,'Ram-Lak');
% filter_matrix = repmat(filter_vector,[1,nTheta]);

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
%             projection_z = imresize(radon(target(:,:,z), params.angles),[nR nTheta]);
%             FT_projection_z = fftshift(fft(projection_z,[],1)); % Fourier transform projections
%             projection_z = real(ifft(ifftshift(FT_projection_z.*rampK_matrix))); % apply ramp filter in Fourier space
            
            [projection_z_filt,H] = filter_projections(radon(target(:,:,z),params.angles),'ram-lak',1);
            projection_z_filt = double(projection_z_filt > 0).*(projection_z_filt); % truncate negatives
            projections(:,:,z) = projection_z_filt;
        end
    else
        for z = 1:nZ
%             projection_z = imresize(radon(target(:,:,z), params.angles),[nR nTheta]);
%             FT_projection_z = fftshift(fft(projection_z,[],1)); % Fourier transform projections
%             projection_z = real(ifft(ifftshift(FT_projection_z.*rampK_matrix))); % apply ramp filter in Fourier space
            
            [projection_z_filt,H] = filter_projections(radon(target(:,:,z),params.angles),'ram-lak',1);
            projection_z_filt = double(projection_z_filt > 0).*(projection_z_filt); % truncate negatives
            projections(:,:,z) = projection_z_filt;
        end 
    end
end


if params.verbose
    
    if numel(size(target)) == 2
        imagesc(projections)
        colormap inferno
    else
        
        
        subplot(2,4,5)
        imagesc(squeeze(projections(:,1,:))')
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(1));
        title(str)
        axis off
        axis equal
        
        subplot(2,4,6)
        imagesc(squeeze(projections(:,round(nTheta*1/3),:))')
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(round(nTheta*1/3)));
        title(str)
        axis off
        axis equal
        
        subplot(2,4,7)
        imagesc(squeeze(projections(:,round(nTheta*2/3),:))')    
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(round(nTheta*2/3)));
        title(str)
        axis off
        axis equal
        
        subplot(2,4,8)
        imagesc(squeeze(projections(:,nTheta,:))')
        colormap inferno
        str = sprintf('\\theta = %2.0f°',params.angles(nTheta));
        title(str)
        axis off
        axis equal
    end
    pause(0.5);
    runtime = toc;
    fprintf('Finished initialization of projections in %.2f seconds\n\n',runtime);
end
end

