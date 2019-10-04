function [voxel_count,coordinates] = get_voxel_count(input,threshold)
% Function that sums the number of voxels that are larger than an input
% threshold
% Input:
%   input = 2D or 3D matrix, to determine # of voxels in target or
%   reconstruction
%   threshold = scalar, threshold
%
% Output:
%   voxel_count = scalar, # of voxels larger than the input threshold
%   coordinates = Nx2 or Nx3 matrix, coordinates in voxel space of the
%   voxels larger than the input threshold
%
% Created by: Joseph Toombs 08/2019

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