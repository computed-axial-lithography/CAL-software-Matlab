classdef ExposureTimer
    properties
        total_exposure_time
        exposure_timer
    end
    
    methods
        function obj = ExposureTimer()
            obj.total_exposure_time = 0;
        end
        
        function obj = start(obj)
            obj.exposure_timer = tic;
        end
        
        function obj = pause(obj)
            obj.total_exposure_time = obj.total_exposure_time + toc(obj.exposure_timer);
        end
        
        function obj = resume(obj)
            obj.exposure_timer = tic;
        end
        
        function [total_exposure_time] = stop(obj)
            obj = obj.pause();
            total_exposure_time = obj.total_exposure_time;
            clear obj.exposure_timer
        end
    end
end

