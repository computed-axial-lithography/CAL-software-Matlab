%{ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Copyright (C) 2020-2021  Hayden Taylor Lab, University of California, Berkeley
Website https://github.com/computed-axial-lithography/CAL-software-Matlab

This file is part of the CAL-software-Matlab toolbox.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%} 
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

