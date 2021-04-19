classdef CALProjectImageSet

    properties
        image_set_obj
        monitor_id
        frame_rate
        frame_hold_time
        blank_when_paused
        motor_sync % boolean
        startpos % 0 or +ve int =< 360
        motor_vel % float
        SLM
        blank_image
        movie
        num_frames
    end
    
    methods
        function obj = CALProjectImageSet(image_set_obj,rot_vel,varargin)
            obj.image_set_obj = image_set_obj;
            
            obj.num_frames = size(obj.image_set_obj.image_set,2);
            obj.frame_rate = obj.num_frames/360*rot_vel;
            obj.frame_hold_time = 1/obj.frame_rate;
            
            if obj.frame_rate > 60
                warning('Warning!!! Frame rate %6.1fHz is higher than 60Hz. Only proceed if your projector is capable of refresh rates >60Hz.',obj.frame_rate)
            end
            
            try
                ver_str = PsychtoolboxVersion;
            catch
                error('Pyschtoolbox is not installed or is improperly installed');
            end

            if str2num(ver_str(1)) < 3
                error('Pyschtoolbox version 3 is required. The installed version is %s.',ver_str);
            end

            AssertOpenGL; % Assure Screen() visual stimulation is working.
            KbName ('UnifyKeyNames'); % Use same key names on all operating systems.

            if nargin == 3
                obj.monitor_id = varargin{1};
            else
                screens = Screen('Screens');
                obj.monitor_id = max(screens);
            end
            
            if nargin == 4
                obj.blank_when_paused = varargin{2};
            else
                obj.blank_when_paused = 1;
            end
            
            sca % clear possible third screen window == screen('CloseAll')
            close all

            % Define the SLM struct
            Screen('Preference', 'Verbosity', 1);
            Screen('Preference', 'VisualDebugLevel', 1);
            try % first try to open window after performing sync tests
                Screen('Preference','SkipSyncTests',0);
                obj.SLM = Screen('OpenWindow',obj.monitor_id);
            catch % if this fails, display warning and skip the sync tests
                warning('Warning! Failed to open PyschToolbox window after Sync Tests. Continuing projection by skipping Sync Tests. Ensure that images are displaying correctly.');
                Screen('Preference','SkipSyncTests',2);
                obj.SLM = Screen('OpenWindow',obj.monitor_id);
            end

            obj.flipBlankImage();
        end
                
        %%% Sync w/ motor
        %%% Home rotation stage and set up rotation params
        function obj = motorsyncinit(obj,MotorSerialNum,Motor_Vel,Pos_start)
            obj.motor_sync = 1;
%           TODO: before actual rotation check motor_sync
            obj.startpos = Pos_start;   % 0 or +ve int =< 360
            obj.motor_vel = Motor_Vel;
           
            % Thorlabs APT functions. See APT Server help file for more
            % info
            handle = actxcontrol('MGMOTOR.MGMotorCtrl.1');
            handle.HWSerialNum = MotorSerialNum;
            handle.StartCtrl(); % shows a GUI window
%           TODO: close GUI window w/o crashing
            handle.SetVelParams(0,0,24,MaxV); % default IChanID=0, MinV=0, Acc=24
            
            fprintf('\nHoming rotation stage\n')
            handle.MoveHome(0,true); % default IChanID=0 and bWait=true
            fprintf('\nDone homing\n')
        end
        
        %%% TODO: start proj only if Agnle_start AND MaxV is reached
        function [obj,total_run_time] = startProjecting(obj,varargin)
            
            obj = obj.prepareFrames();

            if nargin == 2
                wait_to_start = varargin{1};
            else
                wait_to_start = 1;
            end
            
            if wait_to_start && obj.motor_sync
                error("wait_to_start and motor_sync cannot be both 1") 
            elseif wait_to_start
                fprintf('\n\n---------Press spacebar to start image projection--------\n\n');
                obj.pauseUntilKey(KbName('space')); % 32 is spacebar
                fprintf('\nStarted...\n');
            end
            
            %%% TODO: add wait to start
            %%% outline of main
            %%% start stage rotation
            %%% at startangle check if speed=MaxV+-tolerance
            %%% if speed=MaxV+-tolerance, start projection by showing the
            %%% img in the bin that the angle belongs to 
            %%% repeat until projection stopped by user
            %%% stop the stage 
            
            % at startangle check if speed=MaxV+-tolerance
            if ~wait_to_start && obj.motor_sync
                fprintf('\nMoving stage\n')
                handle.MoveVelocity(0,1); %(IChanID, direction sense=forward)
                
                speed_flag = 0;
                tol = 0.2; %%% pos err tolerance. TODO

                while ~speed_flag
                    currpos = handle.GetPosition_Position(0);
                    % try combining the 2 statements 
                    while currpos>=startangle-tol && currpos<startangle+tol
                        currvel = handle.GetVelParams_MaxVel(0);
                        if currvel >= obj.motor_vel
                            speed_flag = 1;
                        end
                        currpos = handle.GetPosition_Position(0);
                    end
                end
            end
            
            % show movie
            if ~wait_to_start && obj.motor_sync
                i = round(obj.startpos/obj.num_frame*360);
            else
                i = 0;  % TODO
            end
            
            run_flag = 1;
            global_time = tic;
            
            while run_flag
                
                if ~wait_to_start && obj.motor_sync
                    currpos = handle.GetPosition_Position(0);
                    i = round(currpos/obj.num_frame*360);%%TODO: check num_i
                else
                    i = mod(i + 1,obj.num_frames); if i==0; i=i+1; end
                end
                
                frame_local_time = tic;
                %%% TODO: check if cp window causes flashing
                Screen('CopyWindow',obj.movie(i),obj.SLM);
                Screen('Flip', obj.SLM);
                if ~wait_to_start && obj.motor_sync
                   return
                else
                    obj.holdOnFrame(frame_local_time,obj.frame_hold_time);
                end
                
                
                pressed_key = obj.checkKey();
                if pressed_key == KbName('tab') % if pressed key is tab, pause until spacebar is pressed again
                    obj.printPaused(i,toc(global_time));
                    if obj.blank_when_paused
                        obj.flipBlankImage();
                    end
                    pressed_key = obj.pauseUntilKey([KbName('space'), KbName('ESCAPE')]);
                    if pressed_key == KbName('space')
                        obj.printResumed();
                    end
                end
                if pressed_key == KbName('ESCAPE') % if pressed key is esc, exit loop
                    total_run_time = toc(global_time);
                    obj.printStopped(i,total_run_time);
                    run_flag = 0;
                end
            end
            
            % display blank image before closing to avoid white screen on
            % close
            obj.flipBlankImage()
            Screen('CloseAll');
            
        end
        
            
        function obj = prepareFrames(obj)
            
            % First create image pointers
            obj.movie = zeros(1,obj.num_frames); % vector for storing the pointers to each image
            for i=1:obj.num_frames

                disp(['Mounting images: ', num2str(i),'/',num2str(obj.num_frames)]);

                obj.movie(i)=Screen('OpenOffscreenWindow', obj.SLM, 0); % mount all images to an offscreen window
                Screen('PutImage',obj.movie(i), obj.image_set_obj.image_set{i});
            end
        end
        
        function [] = flipBlankImage(obj)
            Screen('FillRect', obj.SLM, 0);
            Screen(obj.SLM,'Flip');   
        end
        
    end
    
    methods (Static = true)
        function [] = holdOnFrame(frame_timer,hold_time)
            while true
                curr_time = toc(frame_timer);
                if curr_time >= hold_time
                    break
                end
            end
        end

        function key_number = checkKey()
            % 19 for pause/break, 32 for space, 27 for esc, 9 for tab
            [~,~,key_code,~] = KbCheck;
            key_number = find(key_code); 
        end
        
        function [pressed_key] = pauseUntilKey(key_number)
            function key_number = checkKey()
                [~,~,key_code,~] = KbCheck;
                key_number = find(key_code); 
            end
            
            start_flag = 0;
            while ~start_flag
                pressed_key = checkKey();
                if ismember(pressed_key,key_number)
                    start_flag = 1;
                end
            end
            
        end
        function [] = printResumed()
            fprintf('\nResumed...                              (tab to pause, esc to stop)\n')
        end
        
        function [] = printPaused(curr_frame,global_time)
            fprintf('\nPaused on image #%5.0f at %5.1f s...    (spacebar to resume, esc to stop)\n',curr_frame,global_time)
        end
        
        function [] = printStopped(curr_frame,total_run_time)
            fprintf('\n---------------------------------------------------------\n')
            fprintf('\n----Stopping projection on image #%5.0f at %7.1f s-----\n',curr_frame,total_run_time)
            fprintf('\n---------------------------------------------------------\n')
        end


    end
end
