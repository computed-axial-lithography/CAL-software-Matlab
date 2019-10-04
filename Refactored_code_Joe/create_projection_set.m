function [image_stack] = create_projection_set(params,projections)
% Function to control display of projections
%
% Input:
%   params.ht_screen = scalar, # of pixels in screen in height
%   params.wd_screen = scalar, # of pixels in screen in width
%   projections = matrix, 3D matrix of projections
%
% Output:
%   image_stack = cell array, images of the projector resolution containing
%   optimized projection set



[nR, N_projections, nZ] = size(projections);


%% File remaming based on options selected
% if f ~= 1
%     filename = [filename '_f=4K'];
% end
% 
% if invert_vertical && invert_horizontal
%     filename = [filename '_flipHV'];
% elseif invert_vertical
%     filename = [filename '_flipV'];
% elseif invert_horizontal
%     filename = [filename '_flipH'];
% end
% 
% if ht_offset ~= 0 || wd_offset ~=0
%     filename = [filename '_translate4'];
% end
% 
% if I_f ~=1
%     filename = [filename '_If=2'];
% end


%% Generate Projections
image = zeros(nR,nZ);

ht_image = round(params.f*nZ);
wd_image = round(params.f*nR);

if mod(ht_image,2) == 0
    img_rows = params.ht_screen/2 - ht_image/2 : params.ht_screen/2 + ht_image/2-1;
else
    img_rows = params.ht_screen/2 - (round(ht_image/2)-1) : params.ht_screen/2 + (round(ht_image/2)-1);  %need this when width is odd number
end

if mod(wd_image,2) == 0
    img_cols = params.wd_screen/2 - wd_image/2 : params.wd_screen/2 + wd_image/2-1;
else
    img_cols = params.wd_screen/2 - (round(wd_image/2)-1) : params.wd_screen/2 + (round(wd_image/2)-1);  %need this when width is odd number
end

row_mid = floor(params.ht_screen/2);
col_mid = floor(params.wd_screen/2);
row_start = row_mid-floor(ht_image/2) - params.ht_offset;
row_end = row_start + ht_image;
col_start = col_mid-floor(wd_image/2) - params.wd_offset;
col_end = col_start + wd_image;
image_stack = cell(1,size(projections,2));

if params.verbose
    figure
end



if params.f ~= 1
    nR_in = linspace(0,1,nR);
    nZ_in = linspace(0,1,nZ);
    
    if params.invert_vertical
        nZ_out = linspace(1,0,params.f*nZ);
    else
        nZ_out = linspace(0,1,params.f*nZ);
    end
    
    if params.invert_horizontal
        nR_out = linspace(1,0,params.f*nR);
    else
        nR_out = linspace(0,1,params.f*nR);
    end
    
    gi = griddedInterpolant;
    gi.GridVectors = {nR_in, 1:N_projections, nZ_in};
    gi.Values = projections;
    gi.Method = 'cubic';
    
    projections_scaled = gi({nR_out,1:N_projections,nZ_out});
    
end


for i = 1:N_projections  % # of projections in 180 degrees
  
    curr_image = zeros(params.ht_screen,params.wd_screen);
    curr_image(img_rows,img_cols) = squeeze(projections_scaled(:,i,:))';
    image_stack{i} = uint8(params.I_f.*curr_image);
%     image_stack{i}(:,:) = imresize(uint8(params.I_f*curr_image), size(image_stack{i}(:,:)));
    
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
    curr_image(img_rows,img_cols) = squeeze(projections_scaled(:,i-N_projections,:))';
    image_stack{i} = uint8(params.I_f.*curr_image);
    
    if params.verbose && mod(i,20) == 0
        imagesc(image_stack{i}); 
        title(['Frame ' num2str(i) ' of ' num2str(2*N_projections)])
        axis equal
        axis off
        pause(0.01)
    end
end





