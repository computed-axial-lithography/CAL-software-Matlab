function mytimer = setTimer(duration)
    mytimer = timer;
    mytimer.startdelay = duration;
    mytimer.UserData = 1; % default run_flag = 1
    mytimer.StartFcn = @(~,~)fprintf('\nStarting stopwatch of %7.1f s\n',duration);
    mytimer.TimerFcn = {@setFlag};
end

function [] = setFlag(timerobj,~)
    set(timerobj,'UserData',0);
end
