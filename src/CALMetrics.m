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
classdef CALMetrics
    
    properties
        
    end
    
    methods 
        function obj = CALMetrics()
            
        end

    end
    
    methods (Static = true)
        function VER = calcVER(target,recon,varargin)
            [gel_inds,void_inds] = CALMetrics.getInds(target);
            num_gel_void = sum(gel_inds(:)) + sum(void_inds(:));
            if nargin == 2
                min_gel_dose = min(recon(gel_inds),[],'all');
                void_doses = recon(void_inds);
                n_pix_overlap = sum(void_doses>=min_gel_dose);
                VER = n_pix_overlap/num_gel_void;
                
            elseif nargin == 3 && strcmp(varargin(1),'layers')
                assert(ndims(target)==3,'Target must be 3 dimensional to calculate VER per layer')
                
                VER = zeros(1,size(target,3));
                for i = 1:size(target,3)
                    
                    recon_layer = recon(:,:,i);
                    min_gel_dose = min(recon_layer(gel_inds(:,:,i)),[],'all');
                    void_doses = recon_layer(void_inds(:,:,i));
                    try
                        n_pix_overlap = sum(void_doses>=min_gel_dose);
                        VER(i) = n_pix_overlap/(num_gel_void/size(target,3));
                    catch
                        VER(i) = NaN;
                    end
                end
            end
        end

        function PW = calcPW(target,recon,varargin)
            [gel_inds,void_inds] = CALMetrics.getInds(target);
            
            if nargin == 2   
                min_gel_dose = min(recon(gel_inds),[],'all');
                max_void_dose = max(recon(void_inds),[],'all');
                PW = min_gel_dose - max_void_dose;
                
            elseif nargin == 3 && strcmp(varargin(1),'layers')
                assert(ndims(target)==3,'Target must be 3 dimensional to calculate IPDR per layer')
                
                PW = zeros(1,size(target,3));
                for i = 1:size(target,3)

                    recon_layer = recon(:,:,i);
                    try
                        PW(i) = min(recon_layer(gel_inds(:,:,i)),[],'all') - max(recon_layer(void_inds(:,:,i)),[],'all');
                    catch
                        PW(i) = NaN;
                    end
                end
            end
        end
        
        function IPDR = calcIPDR(target,recon,varargin)
            [gel_inds,~] = CALMetrics.getInds(target);
            
            if nargin == 2   
                min_gel_dose = min(recon(gel_inds),[],'all');
                max_gel_dose = max(recon(gel_inds),[],'all');
                IPDR = max_gel_dose - min_gel_dose;
                
            elseif nargin == 3 && strcmp(varargin(1),'layers')
                assert(ndims(target)==3,'Target must be 3 dimensional to calculate IPDR per layer')
                
                IPDR = zeros(1,size(target,3));
                for i = 1:size(target,3)

                    recon_layer = recon(:,:,i);
                    try
                        IPDR(i) = max(recon_layer(gel_inds(:,:,i)),[],'all') - min(recon_layer(gel_inds(:,:,i)),[],'all');
                    catch
                        IPDR(i) = NaN;
                    end
                end
            end
        end
        
        function [gel_inds,void_inds] = getInds(target)
            circle_mask = CALMetrics.getCircleMask(target);
            gel_inds = circle_mask & target==1;
            void_inds = circle_mask & ~target;
        end
        
        function circle_mask = getCircleMask(target)
            target_dim = ndims(target);
            if target_dim == 2
                [X,Y] = meshgrid(linspace(-1,1,size(target,1)),linspace(-1,1,size(target,1)));
                R = sqrt(X.^2 + Y.^2);

            elseif target_dim == 3                
                [X,Y,~] = meshgrid(linspace(-1,1,size(target,1)),linspace(-1,1,size(target,1)),linspace(-1,1,size(target,3)));
                R = sqrt(X.^2 + Y.^2);
            end
            
            circle_mask = logical(R.*(R<=1));
        end
            
    end
end

