%{
Function to interface with the projector and project images 

INPUTS:
  params
  image_stack = cell array, images of the projector resolution containing
  optimized projection set

OUTPUTS:
  runtime = scalar, length of time for projections until stopped by 

Created by: Joseph Toombs 9/2019
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

function [t_end] = project(params,image_stack)


n_angles = size(image_stack,2);  % number of angles to project in 360 degrees of rotation
hold_time = params.max_angle/n_angles/params.rot_velocity; % time each projection should remain on the projector screen
total_frames = size(image_stack,2); % total number of frames 
frame_rate = total_frames/params.max_angle*params.rot_velocity

% calculate wait time between start of rotation and projection of first
% image
frame_angular_separation = params.max_angle/n_angles;
start_wait_time = sqrt(2*frame_angular_separation/params.rot_acceleration);

sca % clear possible third screen window == screen('CloseAll')
close all

% Define the SLM struct
SLM.window = Screen('Preference','SkipSyncTests',2);
SLM.window = Screen('OpenWindow',2);

% Create blank image
blank_image = zeros(params.ht_screen,params.wd_screen);
blank_image_ptr = Screen('OpenOffscreenWindow', SLM.window, 2);
Screen('PutImage',blank_image_ptr,blank_image);

Screen(SLM.window,'PutImage',blank_image); % start by projection of a blank image
Screen(SLM.window,'Flip');


%% Initialize motor control
thorlabs_devices = motor.listdevices;   % List connected devices
rotation_stage = motor;              % Create a motor object

fprintf('\nConnecting to rotation stage\n');
connect(rotation_stage,thorlabs_devices{1})      % Connect the first devce in the list of devices
fprintf('Successfully connected\n');

setvelocity(rotation_stage,params.rot_velocity,params.rot_acceleration)

% start continuous rotation for vial centering
movecont(rotation_stage,24,24)
input('\nCenter vial in fixture, then press enter to continue.\n')
stop(rotation_stage)
Screen(SLM.window,'PutImage',blank_image); 
Screen(SLM.window,'Flip');

% home the rotation stage
input('\nSet starting position of rotation stage, then press enter to continue.\n')
Screen(SLM.window,'PutImage',blank_image);
Screen(SLM.window,'Flip');


%% Create a GUI window to display projections and stop projection
projection_control_window = figure;
H = uicontrol('Style', 'PushButton', 'String', 'Stop', 'Callback', 'delete(gcbf)');
ax = axes('Parent',projection_control_window,'position',[0.13 0.39  0.77 0.54]);
projection_image_plot = imagesc(ax,zeros(size(image_stack{1})));
pause(0.5)

%% Assign projection images to pointers

window_ptrs = zeros(1,total_frames); % vector for storing the pointers to each image
for i=1:total_frames
    if mod(i,50) == 0
        display(['Mounting image:', num2str(i)]);
    end
    window_ptrs(i)=Screen('OpenOffscreenWindow', SLM.window, 2); % mount sll images to an offscreen window
    Screen('PutImage',window_ptrs(i), image_stack{i});
end



%% Project images
% Begin sequential projection of image stack
frame_stop_time = hold_time;
t_start_all = tic;
t_end = 0;
break_flag = 0;

movecont(rotation_stage,params.rot_velocity,params.rot_acceleration)

current_rotation = 1;
for k = 1:params.n_rotations

    if current_rotation == 1
        tstart = tic;
        while true 
            if toc(tstart) >= start_wait_time
                break
            end
        end
    end
    
    for i = 1:n_angles %n_angles+1
        Screen('CopyWindow',window_ptrs(i), SLM.window);  % copy the image from the offscreen window to the onscreen currently displaying window
        Screen(SLM.window,'Flip');  % display the current image on the projector screen
        
        set(projection_image_plot,'CData',image_stack{i})
        pause(0.0001)
        
        while true
            drawnow;
            t_end = toc(t_start_all);
            if t_end >= frame_stop_time
                frame_stop_time = frame_stop_time + hold_time;
                break
            end
            
            if ~ishandle(H)
                break
            end
        end
        
        if t_end >= params.time_project
            Screen('CopyWindow',blank_image_ptr, SLM.window);
            Screen(SLM.window,'Flip');  % display the current image on the projector screen
            break_flag = 1;
            t_end = toc(t_start_all);
            break
        end
        
        if ~ishandle(H)
            break
        end
    end
    
    if break_flag

        fprintf('\nTotal projection duration: %3.2f seconds\n\n', t_end); 

        break
    end
    if ~ishandle(H)
        break
    end
    current_rotation = current_rotation + 1;
end
stop(rotation_stage)
disconnect(rotation_stage)
end




