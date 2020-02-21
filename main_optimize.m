%{
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

%% Main projection-generation code
% Created by: Joseph Toombs 09/2019

%% Clean workspace
clc
clearvars
clear exp_iradon
close all

%% Input parameters

% General parameters
params = struct;
params.verbose = 1; % 1 to activate informational display; 0 to deactivate
params.vol_viewer = 'pcshow'; % defines the type of volume viewer to be used; change to 'pcshow' if point cloud is desired
params.stl_filename = 'JET.stl';
% params.target_3D ; % use this to directly define the 3D target matrix
params.resolution = 40; % number of voxels in the dimension of minimum length
params.angles = 0:2:358; % vector of real angles of projection; should be [0-180 deg]
params.parallel = 0; % 1 to activate parallel computing; 0 to deactivate; require Parallel Computing toolbox


% Physical setup parameters (NOTE: if resin_abs_coeff is set angles should
% go from [0-360 deg]
params.voxel_size = 0.05; % side length of cubic voxel in mm
params.vial_radius = 20; % radius of resin container in mm
params.resin_abs_coeff = 0.01; % absorption coefficient of resin at projector's center wavelength in 1/mm

% Optimization parameters
params.learningRate = 0.009; % Relaxation parameter: how far along do we move in the Newton iteration
params.Rho = 0.01; % Robustness parameter
params.Theta = 0.2; % Hybrid input-output parameter; Theta = 0 corresponds to perfect constraint
params.Beta = 0.85; % Memory Effect - how much of the previous iteration error is used in computing the current iteration update; Beta = 0 corresponds no memory
params.sigmoid = 2;
params.sigma_init = 2;
params.sigma_end = 1.0;
params.max_iterations = 2;
% params.tol; % use this to set the error tolerance of optimization

%% Optimization procedure
[target,target_care_area] = voxelize_target(params); % prepare target 

projections = initialize_projections(params,target); % create initial guess of projections

[optimized_projections,optimized_reconstruction,error,thresholds] = optimize_projections(params,projections,target,target_care_area); % optimize projections to minimize error between target and reconstruction  

show_projections(optimized_projections,[0,255]) % display projections

show_dose_slices(optimized_reconstruction)


