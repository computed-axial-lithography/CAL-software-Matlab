%{
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

%% Main projector-control code
% Created by: Joseph Toombs 09/2019

clearvars -except optimized_projections

%% Options
params.wd_screen = 1920; % width in pixels of the projector's DMD
params.ht_screen = 1080; % height in pixels of the projector's DMD
params.scale_factor = 1; % projection image XY scaling factor 
params.invert_vertical = 0; % invert vertical orientation of projection
params.invert_horizontal = 0; % invert horizontal orientation of projection
params.rotate_projections = -45; % degrees, rotate images in plane 
params.ht_offset = 0; % height offset of projection within the bounds of the projected image
params.wd_offset = 0; % width offset of projection within the bounds of the projected image
params.array_num = 0;
params.array_shift = 0;
params.intensity_scale_factor = 1; % intensity scaling factor

params.max_angle = 360; % max angle of the projection set
params.rot_velocity = 12; % stage rotational velocity degrees/s
params.n_rotations = 100000; % maximum number of rotations to complete in projection; set arbitrarily large for infinite or otherwise unknown maximum rotations
params.time_project = 100000; % maximum time of projection; set arbitrarily high for infinite or otherwise unknown projection duration
params.verbose = 1;

%% Create projection set

% If the optimized projection matrix is not in the workspace or the
% projection set is already created, the user selects the file
if ~exist('optimized_projections','var') && ~exist('projection_set','var')
    select_data = input('Choose to select: \nprojection set (cell array) (1) \nOR \noptimized projection matrix (3D matrix) (0); \ndefault (1): ');
    if isempty(select_data)
        select_data = 1;
    end
    
    if select_data 
        disp('Select projection set file:')
        [proj_file, path] = uigetfile('*.mat');
        addpath(path);
        import_struct = load(proj_file);
        field_names = fieldnames(import_struct);
        
        projection_set = import_struct.(field_names{1});
        projection_set = create_projection_set(params,projection_set);

    else
        disp('Select optimized projection matrix file:')
        [opt_file, path] = uigetfile('*.mat');
        addpath(path);
        import_struct = load(opt_file);
        field_names = fieldnames(import_struct);
        
        optimized_projections = import_struct.(field_names{1});
        projection_set = create_projection_set(params,optimized_projections);

    end
elseif exist('optimized_projections','var')
    % If the optimized projection matrix is still in the workspace from
    % optimization proceed without file selection
    projection_set = create_projection_set(params,optimized_projections);

elseif exist('projection_set','var')
    % If projection set is still in workspace proceed without file
    % selection
    projection_set = create_projection_set(params,projection_set);
    
end

%% Continue to projection of images
if input('Continue to projection?    ')
    [final_projection_time] = project(params,projection_set);
end
