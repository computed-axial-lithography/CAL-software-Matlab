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
classdef Projector2DParallel
    
    properties
        proj_params
    end
    
    methods
        function obj = Projector2DParallel(proj_params)
            obj.proj_params = proj_params;
            
            if ~isscalar(obj.proj_params.zero_constraint)
                obj.proj_params.proj_mask = obj.getProjMask(obj.proj_params.zero_constraint);
            end
        end
        
        function [b] = getProjMask(obj,fills)
            x = fills;
            [nT,~] = size(x);

            tmp_b = radon(x, obj.proj_params.angles);
            tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
            b = logical(tmp_b);
        end
        
        function [b] = forward(obj,x)
            [nT,~] = size(x);

            tmp_b = radon(x, obj.proj_params.angles);
            tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
            b = tmp_b;
            
            if ~isscalar(obj.proj_params.zero_constraint)
                b(obj.proj_params.proj_mask) = 0;
            end
        end
        
        function [x] = backward(obj,b)
            if ~isscalar(obj.proj_params.zero_constraint)
                b(obj.proj_params.proj_mask) = 0;
            end
            [nT,~] = size(b);

            x = iradon(b, obj.proj_params.angles, 'none',nT);
            x = clipToCircle(x);
        end
    end
end

