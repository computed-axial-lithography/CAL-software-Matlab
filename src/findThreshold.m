function [thresh] = findThreshold(x,target)
    
    [gel_inds,void_inds] = CALMetrics.getInds(target);
    
    thresh_low = min(x,[],'all');
    thresh_high = max(x,[],'all');

    test_thresh = linspace(thresh_low,thresh_high,100);

    score = zeros(size(test_thresh));
    for i=1:length(test_thresh)
        x_thresh = x >= test_thresh(i);

        if ndims(target) == 2
            total_gel_not_in_target = sum(x_thresh(void_inds));
            total_gel_in_target = sum(x_thresh(gel_inds));
        elseif ndims(target) == 3
            total_gel_not_in_target = sum(x_thresh(void_inds));
            total_gel_in_target = sum(x_thresh(gel_inds));
        end
        score(i) = total_gel_in_target/length(gel_inds) - total_gel_not_in_target/length(void_inds);

    end

    [~,opt_thresh_i] = max(score);
    thresh = test_thresh(opt_thresh_i);

end

%     def thresholdReconstruction(self,reconstruction):
%         """
%         Thresholds the reconstruction using the threshold value
%         that minimizes the difference between the number of voxels in 
%         the target and the number of voxels in the thresholded reconstruction.
% 
%         Parameters
%         ----------
%         reconstruction : ndarray
% 
%         Returns
%         -------
%         thresholded_reconstruction : ndarray
%             thresholded reconstruction
% 
%         """
%         threshold_low = np.amin(reconstruction)
%         threshold_high = np.amax(reconstruction)
% 
%         test_thresholds = np.linspace(threshold_low,threshold_high,100)
%         if self.attenuation is not None:
%             sum_target_voxels = np.sum(self.target) - np.sum(self.attenuation)
%         else:
%             sum_target_voxels = np.sum(self.target)
% 
%         voxel_num_diff = np.zeros(len(test_thresholds))
% 
%         score = np.zeros(len(test_thresholds))
%         for i in range(0,len(test_thresholds)):
%             thresholded = np.where(reconstruction > test_thresholds[i], 1, 0)
%             
%             if self.target.ndim == 2:
%                 total_gel_not_in_target = np.sum(thresholded[self.void_inds[0],self.void_inds[1]])
%                 total_gel_in_target = np.sum(thresholded[self.gel_inds[0],self.gel_inds[1]])
%             else:
%                 total_gel_not_in_target = np.sum(thresholded[self.void_inds[0],self.void_inds[1],self.void_inds[2]])
%                 total_gel_in_target = np.sum(thresholded[self.gel_inds[0],self.gel_inds[1],self.gel_inds[2]])
% 
%             score[i] = total_gel_in_target/len(self.gel_inds[0]) - total_gel_not_in_target/len(self.void_inds[0])
% 
% 
%             # voxel_num_diff[i] = np.abs(np.sum(reconstruction>=test_thresholds[i]) - sum_target_voxels)
% 
%         opt_threshold_ind = np.argmax(score)
%         threshold = test_thresholds[opt_threshold_ind]
% 
%         # opt_threshold_ind = np.argmin(voxel_num_diff)
%         # threshold = test_thresholds[opt_threshold_ind]
% 
%         #D-mu
%         recon_sub_mu = reconstruction - threshold
% 
%         # Sigmoid Function Implementation to calculate new dose/sigmoid param determines sharpness
%         thresholded_reconstruction = 1 / (1 + np.exp(-(float(self.optimizer_params['sigmoid_param']) * recon_sub_mu)))
% 
%         return thresholded_reconstruction, threshold