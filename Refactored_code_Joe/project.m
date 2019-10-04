function project(params,image_stack)
% Function to interface with the projector and project images 
%
% Input:
%   params
%   image_stack = cell array, images of the projector resolution containing
%   optimized projection set
%
% Output:
%   runtime = scalar, length of time for projections until stopped by 
%
% 

n_angles = size(image_stack,2);  % number of angles to project in 360 degrees of rotation
hold_time = params.max_angle/n_angles/params.rot_velocity;
total_frames = size(image_stack,2); %Total number of frames 
frame_rate = total_frames/params.max_angle*params.rot_velocity

sca %clear possible third screen window == screen('CloseAll')
close all

%defining the SLM struct here
SLM.window = Screen('Preference','SkipSyncTests',2);
SLM.window = Screen('OpenWindow',2);

% Create blank image
blank_image = zeros(1528,2716);
blank_image_ptr = Screen('OpenOffscreenWindow', SLM.window, 2);
Screen('PutImage',blank_image_ptr,blank_image);

Screen(SLM.window, 'PutImage',blank_image);
Screen(SLM.window,'Flip');

frame_stop_time = hold_time;

% First create image pointers
window_ptrs = zeros(1,total_frames); % vector for storing the pointers to each image
for i=1:total_frames
    if mod(i,50) ==0
        display(['Mounting image:', num2str(i)]);
    end
    window_ptrs(i)=Screen('OpenOffscreenWindow', SLM.window, 0); % mount the image to an offscreen window
    Screen('PutImage',window_ptrs(i), image_stack{i});
end

t_start_all = tic;
for k = 1:n_rotations
    if t_end >= params.time_project
        Screen('CopyWindow',blank_image_ptr, SLM.window);
        break
    end
    
    for i = 1:n_angles %n_angles+1
        Screen(SLM.window,'Flip');  %flip the current image
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




