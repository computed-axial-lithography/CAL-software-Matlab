%{
Function to find the optimal scalar threshold so as to ensure 
that the difference with the target image is minimized
Binary search for 15 iterations

INPUT:
  reconstruction = matrix, 2D or 3D matrix of the backprojected
  reconstruction
  target_voxel_count = scalar, # of voxels in the boundary of the target

OUTPUT:
  threshold = scalar, threshold value that minimizes the difference
  between the target and the reconstruction


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

function [threshold] = find_threshold(reconstruction,target_voxel_count)

threshold_Low = min(reconstruction(:));
threshold_High = max(reconstruction(:));
threshold = 0.5*(threshold_Low + threshold_High); % initial guess is simple average

% Binary search
% 15 iterations gives good results and convergence
for u=1:15
    voxels_above_threshold = (reconstruction > threshold);
    if (sum(voxels_above_threshold(:)) <= target_voxel_count)
        threshold_High = threshold;
        threshold = 0.5*(threshold + threshold_Low);
    else
        threshold_Low = threshold;
        threshold = 0.5*(threshold + threshold_High);
    end
end
end