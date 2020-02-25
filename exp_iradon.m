%{
Function to backproject projections at each angle specified in
params.angles with exponential light intensity decay according to the
Beer-Lambert law. 

INPUTS:   params       =  struct, contains all parameters specific to the
                          process including vial radius, pentration depth,
                          interpolation method
          projections  =  matrix, projections from radon transform

OUTPUTS:  recon        =  matrix, reconstruction with size of
                          params.domain_size

Created by: Joseph Toombs 01/2020 as a modification of Matlab's iradon
funciton

References:
     A. C. Kak, Malcolm Slaney, "Principles of Computerized Tomographic
     Imaging", IEEE Press 1988.
----------------------------------------------------------------------------

Base Code: Copyright 1993-2017 The MathWorks, Inc.

Modifications: Copyright © 2017-2020. The Regents of the University of California, Berkeley. All rights reserved.

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



function [recon] = exp_iradon(params,projections)

% Generate lookup table of exponential absorption at each angle in
% params.angles

persistent exp_contrib_LU
if isempty(exp_contrib_LU)
    % Only generate lookup table if it does not exist
    exp_contrib_LU = gen_att_table(params);
end


p = projections;
N = params.domain_size(1);

% Define the x & y axes for the reconstructed image so that the origin
% (center) is in the spot which RADON would choose.
center = floor((N + 1)/2);
xleft = -center + 1;
x = (1:N) - 1 + xleft;
x = repmat(x, N, 1);

ytop = center - 1;
y = (N:-1:1).' - N + ytop;
y = repmat(y, 1, N);

len = size(p,1);
ctrIdx = ceil(len/2);     % index of the center of the projections

% Zero pad the projections to size 1+2*ceil(N/sqrt(2)) if this
% quantity is greater than the length of the projections
imgDiag = 2*ceil(N/sqrt(2))+1;  % largest distance through image.
if size(p,1) < imgDiag
    rz = imgDiag - size(p,1);  % how many rows of zeros
    p = [zeros(ceil(rz/2),size(p,2)); p; zeros(floor(rz/2),size(p,2))];
    ctrIdx = ctrIdx+ceil(rz/2);
end


% Backprojection - vectorized in (x,y), looping over angles

% Generate trignometric tables
costheta = cosd(params.angles);
sintheta = sind(params.angles);

% Allocate memory for the image
recon = zeros(N,'like',p);


%%%%%%%%%%%%%%
radius = [0.1, 0.2, 0.3, 0.4];
I = zeros(length(radius),length(params.angles));

%%%%%%%%%%%%


for i=1:length(params.angles)
    proj = p(:,i);
    
    %%%%%% For physical units %%%%%%%
%     proj = p(:,i)./max(p,[],'all')*params.light_intensity;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    taxis = (1:size(p,1)) - ctrIdx;
    t = x.*costheta(i) + y.*sintheta(i);

    proj_contrib = reshape(interp1(taxis,proj,t(:),'linear'),N,N);
    curr_dose = exp_contrib_LU(:,:,i).*proj_contrib;
    recon = recon + curr_dose;
    

%%%%%%%%%%%%%%%%%%%%
    I(:,i) = curr_dose(N/2,round(N.*radius./2)+N/2);
%     figure(100)
%     imagesc(curr_dose)
%     pause(0.01)
%%%%%%%%%%%%%%%%%%%%%%

end

% Replace NaNs created by interp2 with zeros
recon(isnan(recon)) = 0;


figure(90)
plot(repmat(params.angles,[4,1])',I')
pause(0.1)




recon = recon*pi/(2*length(params.angles));
