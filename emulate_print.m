%{
Function to simulate the printing process by 

INPUT:
  projections = matrix, 2D or 3D matrix of the optimized projection matrix 
    2D (nR x nTheta) or 3D (nR x nTheta x nZ)
  num_thresholds = scalar, # of threshold values to simulate; this is
    analgous to the number of time steps to take in the simulation

OUTPUT:
  none


Created by: Indrasen Bhattacharya 2017-05-07
Modified by: Joseph Toombs 08/2019

----------------------------------------------------------------------------
Copyright � 2017-2019. The Regents of the University of California, Berkeley. All rights reserved.

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
function emulate_print(projections,num_thresholds)

if length(size(projections)) == 3
    [nX,nTheta,nZ] = size(projections);
    cumulative_dose = zeros(nX, nX, nZ);
elseif length(size(projections)) == 2
    [nX,nTheta] = size(projections);
    cumulative_dose = zeros(nX,nX);
end
    
if length(size(projections)) == 3
    for z=1:nZ
        cumulative_dose(:,:,z) = imresize(iradon(projections(:,:,z), linspace(0,180,nTheta), 'none'),[nX nX]);

    end
elseif length(size(projections)) == 2
    cumulative_dose = imresize(iradon(projections, linspace(0,180,nTheta),'none'),[nX nX]);
end



if length(size(projections)) == 3
    thresholds = linspace(max(max(max(cumulative_dose))),min(min(min(cumulative_dose))),num_thresholds);
    
    dummy_space = ones(nX,nX,nZ);
    dummy_space(1:round(nX/2),1:round(nX/2),:) = 0;
    cross_section_mask = repmat(dummy_space(:),[1,3]);
    
    colors = jet;
    colors_threshold = interp1(linspace(0,1,length(colors)),colors,linspace(0,1,num_thresholds));
    colors_matrix = zeros([nX*nX*nZ,3],'single');
    figure
    for threshold_i = 1:num_thresholds
        [num_voxels,coordinates] = get_voxel_count(cumulative_dose,thresholds(threshold_i));
        curr_coordinates = any(coordinates,2);

        if threshold_i == 1

            colors_matrix(curr_coordinates,:) = repmat(colors_threshold(threshold_i,:),[num_voxels,1]);
            pcshow(coordinates.*cross_section_mask,colors_matrix);
            prev_coordinates = curr_coordinates;
            prev_num_voxels = num_voxels;

        else     
            curr_num_voxels = num_voxels - prev_num_voxels;
            curr_coordinates(curr_coordinates&prev_coordinates) = 0;
            colors_matrix(curr_coordinates,:) = repmat(colors_threshold(threshold_i,:),[curr_num_voxels,1]);
            pcshow(coordinates.*cross_section_mask,colors_matrix);
            prev_coordinates = coordinates;       
            prev_num_voxels = num_voxels;
        end

        title(sprintf('Dose (a.u.) = %d',threshold_i));
        axis equal tight;
        xlim([0 nX])
        ylim([0 nX])
        zlim([0 nZ])
        colormap jet;
        pause(0.02);
    end
end

end
% elseif length(size(projections)) == 2
%     
    