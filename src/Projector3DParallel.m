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
classdef Projector3DParallel
    
    properties
        proj_params
        parallel
    end
    
    methods
        function obj = Projector3DParallel(proj_params,parallel)
            obj.proj_params = proj_params;
            obj.parallel = parallel;
        end
        

        function [b] = forward(obj,x)
            [nT,~,nZ] = size(x);
            
            b = zeros(nT,length(obj.proj_params.angles),nZ);
            
            if obj.parallel
                parfor z = 1:nZ
                    tmp_b = radon(x(:,:,z), obj.proj_params.angles);
                    tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
                    b(:,:,z) = tmp_b;
            
                end
            else 
                for z = 1:nZ
                    tmp_b = radon(x(:,:,z), obj.proj_params.angles);
                    tmp_b([1:size(tmp_b,1)/2-nT/2, size(tmp_b,1)/2+nT/2+1:end],:) = [];
                    b(:,:,z) = tmp_b;
                end
            end
        end
        
        function [x] = backward(obj,b)
            [nT,~,nZ] = size(b);
            x = zeros(nT,nT,nZ);
            
            
            if obj.parallel
                parfor z = 1:nZ
                    x(:,:,z) = iradon(b(:,:,z), obj.proj_params.angles, 'none',nT);
                end        
            else
                for z = 1:nZ
                    x(:,:,z) = iradon(b(:,:,z), obj.proj_params.angles, 'none',nT);
                end
            end % end if parallel
            x = clipToCircle(x);
        end
    end
end

