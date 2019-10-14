%{
Function to create a set of projections in image form of size equal to the
projector

INPUTS:
  params.ht_screen = scalar, # of pixels in screen in height
  params.wd_screen = scalar, # of pixels in screen in width
  params.scale_factor = scalar, XY scaling factor of projection within the
  projection image
  params.intensity_scale_factor = scalar, simple scaling factor for the
  intensity within the projection
  params.invert_vertical = 1 or 0, invert the projections' vertical
  orientation
  params.invert_horizontal = 1 or 0, invert the projections' horizontal
  orientation
  projections = matrix, 3D matrix of projections

OUTPUTS:
  image_stack = cell array, images of the projector resolution containing
  optimized projection set

Created by: Joseph Toombs 09/2019

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


function [image_stack] = create_projection_set(params,projections)

% Reshape the input projections matrix for easier understanding
projections = permute(projections, [1 3 2]);
[nR, nZ, N_projections] = size(projections);

ht_image = round(params.scale_factor*nZ);
wd_image = round(params.scale_factor*nR);

% Define the position of the projection within the full size projected
% image
if mod(ht_image,2) == 0
    img_rows = params.ht_screen/2 - ht_image/2 - params.ht_offset: params.ht_screen/2 + ht_image/2-1 - params.ht_offset;
else
    img_rows = params.ht_screen/2 - (round(ht_image/2)-1) - params.ht_offset : params.ht_screen/2 + (round(ht_image/2)-1) - params.ht_offset;  %need this when width is odd number
end

if mod(wd_image,2) == 0
    img_cols = params.wd_screen/2 - wd_image/2 + params.wd_offset: params.wd_screen/2 + wd_image/2-1 + params.wd_offset;
else
    img_cols = params.wd_screen/2 - (round(wd_image/2)-1) + params.wd_offset: params.wd_screen/2 + (round(wd_image/2)-1) + params.wd_offset;  %need this when width is odd number
end


image_stack = cell(1,size(projections,3));

if params.verbose
    figure
end

% Apply any pre-processing to images
if params.scale_factor ~= 1
    nR_in = linspace(0,1,nR);
    nZ_in = linspace(0,1,nZ);
    
    if params.invert_vertical
        nZ_out = linspace(1,0,params.scale_factor*nZ);
    else
        nZ_out = linspace(0,1,params.scale_factor*nZ);
    end
    
    if params.invert_horizontal
        nR_out = linspace(1,0,params.scale_factor*nR);
    else
        nR_out = linspace(0,1,params.scale_factor*nR);
    end
    
    % Interpolating the entire 3D matrix of projections based on the input
    % pre-processing
    gi = griddedInterpolant;
    gi.GridVectors = {nR_in, nZ_in, 1:N_projections};
    gi.Values = projections;
    gi.Method = 'cubic';
    
    projections_scaled = gi({nR_out,nZ_out,1:N_projections});
else
    projections_scaled = projections;
end

% Build the projection set
for i = 1:N_projections  % # of projections in 180 degrees
    
    curr_image = zeros(params.ht_screen,params.wd_screen);
    curr_image(img_rows,img_cols) = squeeze(projections_scaled(:,:,i))';
    image_stack{i} = uint8(params.intensity_scale_factor.*curr_image);
    
    if params.verbose && mod(i,20) == 0
        imagesc(image_stack{i}); 
        title(['Frame ' num2str(i) ' of ' num2str(2*N_projections)]);
        axis equal
        axis off
        pause(0.01)
    end
end

for i = N_projections+1:2*N_projections  % reverse and concatenate projections of 180 degress

    curr_image = zeros(params.ht_screen,params.wd_screen);
    curr_image(img_rows,img_cols) = squeeze(projections_scaled(:,:,i - N_projections))';
    image_stack{i} = uint8(params.intensity_scale_factor*curr_image);

    
    if params.verbose && mod(i,20) == 0
        imagesc(image_stack{i}); 
        title(['Frame ' num2str(i) ' of ' num2str(2*N_projections)])
        axis equal
        axis off
        pause(0.01)
    end
end

end






