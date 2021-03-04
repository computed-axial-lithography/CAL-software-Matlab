classdef CALProjectImageSet

    properties
        image_set_obj
        monitor_id
        frame_rate
        frame_hold_time
        blank_when_paused
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
            
            obj.blank_image = uint8(zeros(obj.image_set_obj.image_params_used.image_height,...
                                          obj.image_set_obj.image_params_used.image_width));
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
            
            
            try
                ver_str = PsychtoolboxVersion;
            catch
                error('Pyschtoolbox is not installed or is improperly installed');
            end
            
            if str2num(ver_str(1)) < 3
                error('Pyschtoolbox version 3 is required. The installed version is %s.',ver_str);
            end
            
            sca % clear possible third screen window == screen('CloseAll')
            close all

            % Define the SLM struct
            Screen('Preference', 'Verbosity', 1);
            Screen('Preference', 'VisualDebugLevel', 1);
            % Screen('Preference','SkipSyncTests',0);
            
            obj.SLM = Screen('OpenWindow',obj.monitor_id);
            Screen(obj.SLM, 'PutImage',obj.blank_image); 
            Screen(obj.SLM,'Flip');
        end
                
        
        function [obj,total_run_time] = startProjecting(obj,varargin)
            
            
            obj = obj.prepareFrames();

            if nargin == 2
                wait_to_start = varargin{1};
            else
                wait_to_start = 1;
            end
            
            if wait_to_start
                fprintf('\n\n---------Press spacebar to start image projection--------\n\n');
                obj.pauseUntilKey(32); % 32 is spacebar
                fprintf('\nStarted...\n');
            end
            
            
            % show movie
            i = 0;
            run_flag = 1;
            global_time = tic;
            
            while run_flag

                    
                i = mod(i + 1,obj.num_frames); if i==0; i=i+1; end
                frame_local_time = tic;
                Screen('CopyWindow',obj.movie(i),obj.SLM);
                Screen('Flip', obj.SLM);
                obj.holdOnFrame(frame_local_time,obj.frame_hold_time);
                
                
                pressed_key = obj.checkKey();
                if pressed_key == 9 % if pressed key is tab, pause until spacebar is pressed again
                    obj.printPaused(i,toc(global_time));
                    if obj.blank_when_paused
                        obj.flipBlankImage();
                    end
                    pressed_key = obj.pauseUntilKey([32,27]);
                    if pressed_key == 32
                        obj.printResumed();
                    end
                end
                if pressed_key == 27 % if pressed key is esc, exit loop
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
            Screen(obj.SLM, 'PutImage',obj.blank_image); 
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
