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

function project(params,image_stack)


n_angles = size(image_stack,2);  % number of angles to project in 360 degrees of rotation
hold_time = params.max_angle/n_angles/params.rot_velocity; % time each projection should remain on the projector screen
total_frames = size(image_stack,2); % total number of frames 
frame_rate = total_frames/params.max_angle*params.rot_velocity

sca % clear possible third screen window == screen('CloseAll')
close all

% Define the SLM struct
SLM.window = Screen('Preference','SkipSyncTests',2);
SLM.window = Screen('OpenWindow',2);

% Create blank image
blank_image = zeros(params.ht_screen,params.wd_screen);
blank_image_ptr = Screen('OpenOffscreenWindow', SLM.window, 2);
Screen('PutImage',blank_image_ptr,blank_image);

Screen(SLM.window, 'PutImage',blank_image); % start by projection of a blank image
Screen(SLM.window,'Flip');


% First create image pointers
window_ptrs = zeros(1,total_frames); % vector for storing the pointers to each image
for i=1:total_frames
    if mod(i,50) == 0
        display(['Mounting image:', num2str(i)]);
    end
    window_ptrs(i)=Screen('OpenOffscreenWindow', SLM.window, 0); % mount sll images to an offscreen window
    Screen('PutImage',window_ptrs(i), image_stack{i});
end

% Begin sequential projection of image stack
frame_stop_time = hold_time;
t_start_all = tic;
for k = 1:n_rotations
    if t_end >= params.time_project
        Screen('CopyWindow',blank_image_ptr, SLM.window); % project blank window when projection time is complete
        break
    end
    
    for i = 1:n_angles %n_angles+1
        Screen(SLM.window,'Flip');  % display the current image on the projector screen
        tstart = tic;
        Screen('CopyWindow',window_ptrs(i), SLM.window);  % copy the image from the offscreen window to the onscreen currently displaying window
                
        while true
            t_end = toc(t_start_all);
            if t_end >= frame_stop_time
                frame_stop_time = frame_stop_time + hold_time;
                break
            end
        end
        
        if t_end >= params.time_project
            Screen('CopyWindow',blank_image_ptr, SLM.window);
            t_end = toc(t_start_all);
            break
        end
    end

end




