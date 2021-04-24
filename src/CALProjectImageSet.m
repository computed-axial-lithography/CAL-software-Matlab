classdef CALProjectImageSet
%%% TODO: error control, stop timer when paused
    properties
        image_set_obj
        monitor_id
        frame_rate
        frame_hold_time
        blank_when_paused
        
        motor_sync % boolean
        motor   % handle for motor stage
        startpos % 0 or +ve int =< 360
        rot_vel % float
        acc
        
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
            obj.rot_vel = rot_vel;
            
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
            obj = obj.prepareFrames();
        end
                
        % Home rotation stage and set up rotation params. OPTIONAL
        function obj = motorsyncinit(obj,MotorSerialNum,Start_Pos)
            assert(0<=Start_Pos && Start_Pos<=360,'Start_Pos is not between 0 and 360.')
            obj.startpos = Start_Pos;
            obj.acc = 24;
           
            % Start Thorlabs APT. See APT Server help file for more info
            try
                obj.motor = actxcontrol('MGMOTOR.MGMotorCtrl.1');
            catch ME
                switch ME.identifier 
                    case 'MATLAB:COM:InvalidProgid'
                        close   % close empty figure window
                        error('Thorlabs APT ActiveX control program ID(MGMOTOR.MGMotorCtrl.1) not found. Check that the program is installed.');
                    otherwise
                        close
                        rethrow(ME)
                end
            end
            
            obj.motor.HWSerialNum = MotorSerialNum;
            obj.motor.StartCtrl(); % shows a GUI window   
%             close;  % closes GUI window. Note: can cause crashing sometimes

            obj.motor.SetVelParams(0,0,obj.acc,obj.rot_vel);
            
            fprintf('\nHoming rotation stage\n')
            obj.motor.MoveHome(0,true);
            fprintf('\nMotor stage initialized\n')
            obj.motor_sync = 1;  
        end
        

        function [obj,total_run_time] = startProjecting(obj,varargin)
            
%             obj = obj.prepareFrames();
%%%TODO
            if isempty(obj.motor_sync)
                obj.motor_sync = 0;
            end

            if nargin == 2
                wait_to_start = varargin{1};
            else
                wait_to_start = 1;
            end
            
            if wait_to_start
                if obj.motor_sync
                    str = '\n\n---------Press spacebar to start stage rotation and image projection--------\n\n';
                else
                    str = '\n\n---------Press spacebar to start image projection--------\n\n';
                end
                fprintf(str);
                obj.pauseUntilKey(KbName('space')); % 32 is spacebar
                fprintf('\nStarted...\n');
            end
               
            % set the stage moving
            if obj.motor_sync
                obj.startStage()
            end
            
            % show movie            
            run_flag = 1;
            global_time = tic;
            
            if obj.motor_sync
                tol = 0.2; % tolerance of position error in degrees
                at_pos = 0;
                
                % wait for stage to arrive start position
                while ~at_pos
                    currpos = obj.motor.GetPosition_Position(0);
                    if currpos>=obj.startpos-tol && currpos<obj.startpos+tol
                        at_pos = 1;
                        fprintf('\nStarting position reached\n')
                    end
                end
                % set image counter at start position
                angles = linspace(0,360-360/obj.num_frames,obj.num_frames);
                indexes = 1:obj.num_frames;
                i = interp1(angles,indexes,obj.startpos,'nearest',obj.num_frames);
%                 i = round(obj.startpos/360*obj.num_frames);
                proj_started = 0;
                
            else
                i = 1;
            end
            
            while run_flag
                
                if obj.motor_sync
                    if ~proj_started
                        fprintf('\nStarting projection\n')
                        proj_started = 1;
                    else
                        % check stage position and set image counter at that
                        % position
                        currpos = obj.motor.GetPosition_Position(0); % format: .4f
%                         i = round(currpos/360*obj.num_frames);
                        i = interp1(angles,indexes,currpos,'nearest',obj.num_frames);
                    end
                else
                    if mod(i,obj.num_frames)~=0
                        i = mod(i,obj.num_frames);
                    elseif i/obj.num_frames >=1
                        i = obj.num_frames;
                    end
                end
                
                Screen('CopyWindow',obj.movie(i),obj.SLM);
                Screen('Flip', obj.SLM);
                if ~obj.motor_sync
                    frame_local_time = tic;
                    obj.holdOnFrame(frame_local_time,obj.frame_hold_time);
                    i = i+1;                
                end
                
                pressed_key = obj.checkKey();
                if pressed_key == KbName('tab') % if pressed key is tab, pause until spacebar is pressed again
                    obj.printPaused(i,toc(global_time));
                    if obj.blank_when_paused
                        obj.flipBlankImage();
                    end
                    if obj.motor_sync
                        obj.motor.StopImmediate(0);
                    end
                    
                    pressed_key = obj.pauseUntilKey([KbName('space'), KbName('ESCAPE')]);
                    if pressed_key == KbName('space')
                        obj.printResumed();
                        if obj.motor_sync
                            obj.startStage();
                        end
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
            
            % stop stage and exit motor stage control
            if obj.motor_sync
                obj.motor.StopImmediate(0);
                obj.motor.StopCtrl();
                fprintf('\nStage control terminated. Run obj.motorsyncinit() to re-initialize motor stage.\n')
            end
            
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
        
        function [] = startStage(obj)
            assert(obj.motor_sync==1,'Motor stage not initialized. Run obj.motorsyncinit() to initialize motor stage.')
            acc_time = obj.rot_vel/obj.acc;
            fprintf('\nStarting stage\n')
            obj.motor.MoveVelocity(0,1); 
            pause(acc_time);
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
