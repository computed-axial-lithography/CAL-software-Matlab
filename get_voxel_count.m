%{
Function that sums the number of voxels that are larger than an input
threshold
Input:
  input = 2D or 3D matrix, to determine # of voxels in target or
  reconstruction
  threshold = scalar, threshold

Output:
  voxel_count = scalar, # of voxels larger than the input threshold
  coordinates = Nx2 or Nx3 matrix, coordinates in voxel space of the
  voxels larger than the input threshold

Created by: Joseph Toombs 08/2019

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

function [voxel_count,coordinates] = get_voxel_count(input,threshold)

if ~exist('threshold','var')
    threshold = 1;
end

% 2D target and reconstruction
if numel(size(input)) == 2
    nX = size(input,2);
    nY = size(input,1);
    nZ = 1;
    
    voxel_count = 0;
    coordinates = single(zeros(nX*nY,3));
    
    for x = 1:nX
        for y = 1:nY
            if (input(x,y) >= threshold)
                voxel_count = voxel_count+1;
                coordinates(voxel_count,:) = [x y 0];
            end
        end
    end
end

% 3D target and reconstruction
if numel(size(input)) == 3
    nR = size(input,1);
    nZ = size(input,3);

    voxel_count = 0;
    coordinates = single(zeros(nR*nR*nZ,3));

    for z=1:nZ
        for y=1:nR
            for x=1:nR
                if (input(x,y,z) >= threshold)
                    voxel_count = voxel_count+1;
                    coordinates(voxel_count,:) = [x y z];
                end
            end
        end
    end
end
end