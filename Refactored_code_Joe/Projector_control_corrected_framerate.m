%Projector control

clear all

%% input parameters
omega_deg = 12; %degrees/s
max_angle = 360; %deg
delay_start = 10;
delay_end = 5;
n_rotations = 1e6;

readSTL=0;

if ~readSTL
    disp('Select projection file')
    [projFile, path] = uigetfile('*.mat');
    addpath(path);
    load(projFile);
end
totalFrames = size(image_stack,2); %Total number of frames 
frameRate = totalFrames/max_angle*omega_deg
%% Clean-up and basic setup
sca %clear possible third screen window == screen('CloseAll')
close all

%defining the SLM struct here
SLM.window = Screen('Preference','SkipSyncTests',2);
SLM.window = Screen('OpenWindow',2);

%%%%%%%%%%
%image_stack = image_stack(1:80);
n_angles = size(image_stack,2);
hold_time = max_angle/n_angles/omega_deg;

%create blank image
blank_image = zeros(1528,2716);
Screen(SLM.window, 'PutImage',blank_image);
Screen(SLM.window,'Flip');
%image_stack{end+1} = blank_image;

frame_stop_time = hold_time;
%display images, Mount it first
windPtrs = zeros(1,totalFrames);
for i=1:totalFrames
    if mod(i,50) ==0
        display(['Mounting image:', num2str(i)]);
    end
    windPtrs(i)=Screen('OpenOffscreenWindow', SLM.window, 0);
    Screen('PutImage',windPtrs(i), image_stack{i});
end

t_start_all = tic;
for k = 1:n_rotations
%while 1
%     t_start_rot = tic;
for i = 1:n_angles %n_angles+1
Screen(SLM.window,'Flip');  %flip the current image
tstart = tic;
Screen('CopyWindow',windPtrs(i), SLM.window);
% Screen(SLM.window, 'PutImage',image_stack{i}); %mount the next image
% pause(hold_time)
while true
%     pause(.001)
    t_end = toc(t_start_all);
    if t_end >= frame_stop_time
        frame_stop_time = frame_stop_time + hold_time;
            break
    end
end
end
%%%%%%%%% added this for 360deg rotation. Delete it later
% Screen(SLM.window, 'PutImage',blank_image);
% Screen(SLM.window,'Flip');
% % pause(180/omega_deg-2)
% Screen(SLM.window, 'PutImage',blank_image);
% while true
%     t_rot = toc(t_start_rot);
%     if t_rot >= 360/omega_deg
%             break
%     end  
% end
%%%%%%%%%%%%%%
end

Screen(SLM.window,'Flip');  %flip the current image
t_end_all = toc(t_start_all)

Screen(SLM.window, 'PutImage',blank_image);
Screen(SLM.window,'Flip');
% pause(delay_end)