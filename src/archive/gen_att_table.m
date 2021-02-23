%{
Function to generate a lookup table of matrices containing the exponential
decay of light intensity within a vial of given radius with resin of given
absorption coefficient

INPUTS:  params        =  struct, contains all parameters specific to the
                          process including vial radius, pentration depth,
                          interpolation method

OUTPUTS: att_table     =  matrix, [N x N x N_theta] contribution of resin 
                          attenuation at each angle in params.angles; 
                          each contribution is used as a multiplier
                          modifying the backprojected intensity in
                          exp_iradon()


Created by: Joseph Toombs 01/2020 as a modification of Matlab's iradon
funciton

----------------------------------------------------------------------------
Copyright © 2017-2020. The Regents of the University of California, Berkeley. All rights reserved.

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



function att_table = gen_att_table(params,occlusion)

if nargin < 3
    occlusion = NaN;
end


% Preallocate 3D matrix for lookup table
att_table = single(zeros([params.domain_size(1),params.domain_size(2),length(params.angles)]));
N = domain_size(1);

% Generate trignometric tables
costheta = cosd(angles);
sintheta = sind(angles);

% Define the x & y axes for the reconstructed image so that the origin
% (center) is in the spot which RADON would choose.
center = floor((N + 1)/2);
xleft = -center + 1;
x = (1:N) - 1 + xleft;
x = repmat(x, N, 1);

ytop = center - 1;
y = (N:-1:1).' - N + ytop;
y = repmat(y, 1, N);


% Convert physical parameters to dimensions of pixels if physical parameters are setup
if params.resin_abs_coeff ~= 0
    resin_abs_coeff_pix = params.resin_abs_coeff*params.voxel_size;
    vial_radius_pix = round(params.vial_radius/params.voxel_size);
end

x = x.*params.voxel_size;
y = y.*params.voxel_size;

% Circle that bounds the 
% radius_bound = (x.^2 + y.^2 < vial_radius_pix^2);


for i = 1:length(params.angles)

    t = x.*costheta(i) + y.*sintheta(i);
    t_perp = -x.*sintheta(i) + y.*costheta(i); 
    
    w = real(sqrt(params.vial_radius^2 - t.^2)) - t_perp;  % path length of light ray in resin
    w(abs(t) > params.vial_radius) =  inf;  % set all values outside vial radius to zero
    expProjContrib = exp(-w);   % also could be exp(w./(resin_abs_coeff_pix)^-1)) which is exp(w./(resin_penetration_depth_pix))
    
%     w = real(sqrt(params.vial_radius^2 - x.^2)) - y;  % path length of light ray in resin
%     w(:,abs(x(1,:)) > params.vial_radius) =  inf;  % set all values outside vial radius to zero
%     relative_intensity = exp(-w);   % also could be exp(w./(resin_abs_coeff_pix)^-1)) which is exp(w./(resin_penetration_depth_pix))
    
    
%     w = real(sqrt(vial_radius_pix^2 - x.^2)) - y;  % path length of light ray in resin
%     w(:,[1:size(x,1)/2-vial_radius_pix,size(x,1)/2+vial_radius_pix:end]) =  0;  % set all values outside vial radius to zero
%     relative_intensity = exp(-w.*resin_abs_coeff_pix);   % also could be exp(w./(resin_abs_coeff_pix)^-1)) which is exp(w./(resin_penetration_depth_pix))

    %%%% For physical units %%%%%
    %     volumetric_abs_factor = 2.3*resin_abs_coeff_pix.*exp(-2.3*w.*resin_abs_coeff_pix);   % also could be exp(w./(resin_abs_coeff_pix)^-1)) which is exp(w./(resin_penetration_depth_pix))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%     expProjContrib = reshape(interp2(x,y,relative_intensity,t,t_perp,'linear'),N,N);
%     expProjContrib1 = interp2(x,y,relative_intensity,t,t_perp,'linear');

%     if i == 60
%         figure(200)
%         imagesc(relative_intensity)
%         daspect([1 1 1])
%     end
%     figure
%     imagesc(expProjContribNN)    
    
%     if ~isnan(occlusion)
%         occlusion_line = ones(N,N).*((x == 0) & (y >= 0));
%         occlusion_line = imrotate(occlusion_line,params.angles(i),'nearest','crop');
%         shadow = conv2(occlusion_line,occlusion,'same');
%         figure(100); imagesc(shadow);
%         expProjContrib = expProjContrib.*radius_bound.*~shadow;
%     else
%         expProjContrib = expProjContrib.*radius_bound;
%     end
    
    
    
    att_table(:,:,i) = expProjContrib;
    

%     figure(100)
%     imagesc(att_table(:,:,i))
%     axis square  
%     pause(0.02)
    
end