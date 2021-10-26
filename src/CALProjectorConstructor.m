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
function [ProjectorObj] = CALProjectorConstructor(target_obj,proj_params,parallel)

    if ~exist('parallel','var')
        parallel = 0;
    end
    
    if ~isfield(proj_params,'inclination_angle')
        proj_params.inclination_angle = 0;
    end     
    
    if ~isfield(proj_params,'CUDA') || proj_params.CUDA == 0
        if target_obj.dim == 2
            ProjectorObj = Projector2DParallel(proj_params);
        elseif target_obj.dim == 3
            ProjectorObj = Projector3DParallel(proj_params,parallel);
        end
    
    elseif proj_params.CUDA == 1
        assert(testAstra()==1)
        
        if ~isfield(proj_params,'cone_angle') || proj_params.cone_angle == 0
            ProjectorObj = Projector3DParallelCUDA(target_obj,proj_params);
        else
            ProjectorObj = Projector3DConeCUDA(target_obj,proj_params);
        end
    
    else
        error('CALProjectorConstructor failed because projector parameters not defined');
    end

end

