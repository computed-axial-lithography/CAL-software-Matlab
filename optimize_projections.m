%{
Function that optimizes a set of initial projections to minimize the
error between the backprojected reconstruction and the input target

INPUTS:
  params.angles = vector, angles at which the Radon and Inverse Radon transforms
                  are calculated; without accounting for absorption within the resin the
                  range of angles only needs to be 0 to 180 degrees
  params.max_iterations = scalar, maximum # of iterations in the optimization
  initial_projections = matrix, matrix of initial guess projections; can be
                        2D (nR x nTheta) or 3D (nR x nTheta x nZ)
  target = matrix, voxelized design STL padded with zeros
  target_care_area = matrix, defines the dilated version of the target 
  params.verbose = 1 or 0, activates or deactivates visualization and display of
            extra information about the optimization

OUTPUTS:
  opt_projections = matrix, 2D or 3D matrix of the 8-bit projections
                    needed for projection
  error = vector, error at each iteration of the optimization

Created by: Indrasen Bhattacharya 2017-05-07
Modified by: Joseph Toombs 09/2019

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

function [opt_projections,error,thresholds] = optimize_projections(params,initial_projections,target,target_care_area)

if ~isfield(params,'verbose')
    params.verbose = 0;
end

% If params.parallel is undefined it defaults to 0
if ~isfield(params,'parallel')
    params.parallel = 0;
end

if params.verbose
    fprintf('Beginning optimization of projections\n');
    tic;


end

if numel(size(target)) == 2
    [nX,nY] = size(target);
    [nR,nTheta] = size(initial_projections);
else
    [nX,nY,~] = size(target);
    [nR,nTheta,nZ] = size(initial_projections);
end

% Preallocate vectors for storing information about results of optimization
error = zeros(params.max_iterations,1); % Error vector storing the total error as a function of the iteration number
thresholds = zeros(params.max_iterations,1); % Threshold for gelation

% Preallocate error matrices
opt_projections = initial_projections;
delta_projections = opt_projections; % Projection space error
delta_projections_prev = opt_projections;
%delta_target = zeros(size(target)); % Error feedback

% Preallocate reconstruction
curr_reconstruction = zeros(size(target));
target_orig = target; % store a copy of the original padded_target


% 3D volshow() parameters
intensity = [-3000, -10, 600, 3000];
alpha = [0, 0, 0.7, 1];
color = ([255 255 255; 231 231 231; 186 186 186; 0 0 0]) ./ 255;
queryPoints = linspace(min(intensity),max(intensity),256);
alphamap = interp1(intensity,alpha,queryPoints)';
colormap = interp1(intensity,color,queryPoints);


target_voxel_count = get_voxel_count(target);

for curr_iter = 1:params.max_iterations
    
    [projections_power,~] = find_scale(opt_projections); % maps the current optimized projections to 8-bit numbers with the calibration curve of the projector
    
    % Backproject with the current realistic 8-bit projections so that when
    % calculating the error the comparison is between the target and a
    % tangible reconstruction
    for z = 1:nZ
        curr_reconstruction(:,:,z) = imresize(iradon(projections_power(:,:,z), params.angles, 'none'),[nX nY]);
    end
    curr_reconstruction = curr_reconstruction/sum(curr_reconstruction(:))*sum(target(:));

    curr_threshold = find_threshold(curr_reconstruction,target_voxel_count);
    thresholds(curr_iter) = curr_threshold; % store thresholds as a function of the iteration number

    
    [curr_voxel_count,coord_above_threshold] = get_voxel_count(curr_reconstruction,curr_threshold);
   
    
    % Apply Gauss filter to the padded_target to soften boundary
%     sigma_AA = params.sigma_init - (curr_iter-1)/(params.max_iterations-1)*(params.sigma_init - params.sigma_end); %Anti-aliasing parameter
%     target = imgaussfilt3(target_orig,sigma_AA); %anti-aliased version of the padded_target
    
    
    %Rho = Rho+0.006*k/nLoop1; %Forcing more robustness at every iteration
    
    %Define thresholding function
    mu = curr_threshold;
    sigma = 0.01; %(0.51-k/nLoop1)*threshTPos;
    mu_dilated = (1-params.Rho)*curr_threshold; %Recipe change
    mu_eroded = (1+params.Rho)*curr_threshold;
    

    % curr_reconstruction consists of normalized continuous values while
    % thresholded_reconstruction consists of sigmoid thresholded values of
    % curr_reconstruction
%     thresholded_reconstruction = imgaussfilt3(1./(1+exp(-(curr_reconstruction-mu)/sigma)),sigma_AA); 
%     thresholded_reconstruction = imgaussfilt3( sigmoid((curr_reconstruction-mu)/sigma), sigma_AA);
        thresholded_reconstruction = sigmoid((curr_reconstruction-mu)/sigma);

%     thresholded_reconstruction_eroded = imgaussfilt3(1./(1+exp(-(curr_reconstruction-mu_eroded)/sigma)),sigma_AA); 
%     thresholded_reconstruction_eroded = imgaussfilt3( sigmoid((curr_reconstruction-mu_eroded)/sigma), sigma_AA);
        thresholded_reconstruction_eroded = sigmoid((curr_reconstruction-mu_eroded)/sigma);

%     thresholded_reconstruction_dilated = imgaussfilt3(1./(1+exp(-(curr_reconstruction-mu_dilated)/sigma)),sigma_AA); 
%     thresholded_reconstruction_dilated = imgaussfilt3( sigmoid((curr_reconstruction-mu_dilated)/sigma), sigma_AA);
        thresholded_reconstruction_dilated = sigmoid((curr_reconstruction-mu_dilated)/sigma);

    
    
    % Calculate error between target [padded version of target] and thresholded negative truncated
    % reconstruction [thresholded_reconstruction] for exact, lower, and higher thresholds
    delta_target = (thresholded_reconstruction - target).*target_care_area; % Target space error   
    delta_target_eroded = (thresholded_reconstruction_eroded - target).*target_care_area; % Eroded version
    delta_target_dilated = (thresholded_reconstruction_dilated - target).*target_care_area; % Dilated version
    
    
    error(curr_iter) = sum(abs(delta_target(:)))/curr_voxel_count;
    

    if isfield(params,'tol')
        if (error(curr_iter) <= params.tol)
            break;
        end
    end

    % Average the target space errors
    delta_target_feedback = (delta_target + delta_target_eroded + delta_target_dilated)/3;
      
    % update optimized projections over z-positions
    if params.parallel
        parfor z = 1:nZ 
            delta_projections(:,:,z) = imresize(radon(delta_target_feedback(:,:,z), params.angles),[nR nTheta]); % transform error in target space to error in projection space
            gradientApprox = ((1-params.Beta)*delta_projections(:,:,z) + params.Beta*delta_projections_prev(:,:,z))/(1-params.Beta^curr_iter);
            opt_projections(:,:,z) = opt_projections(:,:,z) - params.learningRate*gradientApprox; %Update involving a controlled step size and memory effect
            opt_projections(:,:,z) = opt_projections(:,:,z).*(double(opt_projections(:,:,z) >= 0)+params.Theta*double(opt_projections(:,:,z) < 0)); %Impose positivity constraint using a relaxation parameter
        end
    else
        for z = 1:nZ 
            delta_projections(:,:,z) = imresize(radon(delta_target_feedback(:,:,z), params.angles),[nR nTheta]); % transform error in target space to error in projection space
            gradientApprox = ((1-params.Beta)*delta_projections(:,:,z) + params.Beta*delta_projections_prev(:,:,z))/(1-params.Beta^curr_iter);
            opt_projections(:,:,z) = opt_projections(:,:,z) - params.learningRate*gradientApprox; %Update involving a controlled step size and memory effect
            opt_projections(:,:,z) = opt_projections(:,:,z).*(double(opt_projections(:,:,z) >= 0)+params.Theta*double(opt_projections(:,:,z) < 0)); %Impose positivity constraint using a relaxation parameter
        end
    end
    delta_projections_prev = delta_projections;
        
    
    if params.verbose
        % Plot evolving error
        figure(4)
        %subplot(2,4,3)
        semilogy(1:params.max_iterations,error,'LineWidth',2); 
        xlim([1 params.max_iterations]); 
        ylim([1e-4 1]);
        xlabel('Iteration #')
        ylabel('Error')
        title_string = sprintf('Iteration = %2.0f',curr_iter);
        title(title_string)
        
        figure(5)
%         subplot(2,4,2)
        if strcmp(params.vol_viewer,'volshow')
            % Show evolving reconstruction using volshow
            
            volshow(curr_reconstruction,'Renderer','Isosurface','Isovalue',curr_threshold,'BackgroundColor','w');
            camlight
            lighting gouraud
            axis vis3d
            title_string = sprintf('Optimized reconstruction\nIteration = %2.0f',curr_iter);
            annotation('textbox',[0.2 0.5 0.3 0.3],'String',title_string,'FitBoxToText','on');

            title(title_string)
        elseif strcmp(params.vol_viewer,'pcshow')
            % Alternative method of plotting reconstruction (requires Computer
            % Vision Toolbox)
            
            pcshow(coord_above_threshold(1:curr_voxel_count,:));
            axis vis3d
            title_string = sprintf('Optimized reconstruction\nIteration = %2.0f',curr_iter);
            title(title_string)            
        end
        pause(0.05);
        
        
    end
    
end

[opt_projections,~] = find_scale(opt_projections);

if params.verbose
    runtime = toc;
    fprintf('Finished optimization of projections in %5.2f seconds\n\n',runtime);
end
end

function y = sigmoid(x)

    y = 1./(1+exp(-x));

end

