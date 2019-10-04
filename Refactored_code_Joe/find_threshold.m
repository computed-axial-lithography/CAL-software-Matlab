function [threshold] = find_threshold(reconstruction,target_voxel_count)
% Function to find the optimal scalar threshold so as to ensure 
% that the difference with the target image is minimized
% Binary search for 15 iterations
%
% Input:
%   reconstruction = matrix, 2D or 3D matrix of the backprojected
%   reconstruction
%   target_voxel_count = scalar, # of voxels in the boundary of the target
%
% Output:
%   threshold = scalar, threshold value that minimizes the difference
%   between the target and the reconstruction
%
%
% Created by: Indrasen Bhattacharya 2017-05-07
% Modified by: Joseph Toombs 08/2019


threshold_Low = min(reconstruction(:));
threshold_High = max(reconstruction(:));
threshold = 0.5*(threshold_Low + threshold_High); % initial guess is simple average

% Binary search
% Modify it to compare with the actual structure than with just the count
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
