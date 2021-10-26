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
classdef DisplayEvolving < handle
    %DISPLAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        panel_3D
        vol
        an
    end
    
    methods
        function obj = DisplayEvolving(dim)
            
            if dim ~= 2
                obj.panel_3D = uipanel(figure(3));
            end
        end
    
    
    
        function [obj] = displayEvolvingReconstruction(obj,x,curr_iter,curr_threshold)
            Display.addPathsDisplay();
            title_str = sprintf('Optimized reconstruction iter = %d',curr_iter);
            
            if ndims(x) == 2
                figure(3)
                imagesc(x)
                colorbar
                daspect([1 1 1])
                title(title_str)
                colormap(CMRmap())
            elseif  ndims(x) == 3
                figure(3)
                if curr_iter == 1
                    obj.vol = volshow(x,'Parent',obj.panel_3D,'Renderer','Isosurface','Isovalue',curr_threshold,'BackgroundColor','white','Isosurfacecolor','cyan');
                    axis vis3d
                    obj.an = annotation(obj.panel_3D,'textbox',[0.01 0 0.05 0.1],'String',title_str,'FitBoxToText','on','Color','k','Edgecolor','none');
                else
                    setVolume(obj.vol,x)
                    obj.vol.Isovalue = curr_threshold;
                    axis vis3d  
                    obj.an.String = title_str; 

                end
            end
        end
    
    end
    
    
    methods (Static = true)
        
        function [] = displayReconstruction(x,varargin)
            Display.addPathsDisplay()
            
            if ~exist('varargin{1}','var')
                title_str = sprintf('Target');
            else
                title_str = varargin{1};
            end
            
            if ndims(x) == 2
                figure(1)
                imagesc(x)
                colorbar
                daspect([1 1 1])
                title(title_str)
                colormap(CMRmap())
            elseif  ndims(x) == 3
                panel_3D_static = uipanel;
                figure(1)
                volshow(x,'Parent',panel_3D_static,'Renderer','Isosurface','Isovalue',curr_threshold,'BackgroundColor','white','Isosurfacecolor','cyan');
                axis vis3d
                annotation(panel_3D_static,'textbox',[0.01 0 0.05 0.1],'String',title_str,'FitBoxToText','on','Color','k','Edgecolor','none');
            end
        end
        
        
        function [] = errorPlot(curr_iter,max_iter,error)
            
            if isempty(curr_iter)
                curr_iter = max_iter;
            end
            
            figure(2)
            plot(1:curr_iter,error(1:curr_iter),'r','LineWidth',2); 
            xlim([1 max_iter]);
            ylim([0 max(error)+0.1*max(error)])
            xlabel('Iteration #')
            ylabel('Error')
            title_string = sprintf('Iteration = %2.0f',curr_iter);
            title(title_string)
            grid on
        end
        
        function [] = histogramProjRecon(b,x,gel_inds,void_inds)
            figure(4)
            
            subplot(2,1,1)
            hold on
            histogram(x(void_inds)./max(x(:)),linspace(0,1,100),'facecolor','r','facealpha',0.5)
            histogram(x(gel_inds)./max(x(:)),linspace(0,1,100),'facecolor','b','facealpha',0.5)
            xlim([0,1])
            set(gca,'yscale','log')
            title('Dose distribution')
            xlabel('Normalized Dose')
            ylabel('Voxel Counts')
            legend('Out-of-part Dose','In-part Dose','Location','northwest')
            
            subplot(2,1,2)
            histogram(b./max(b(:)),linspace(0,1,256),'facecolor','r','facealpha',0.5)
            xlim([0,1])
            set(gca,'yscale','log')
            title('Projection intensity distribution')
            xlabel('Normalized Intensity')
            ylabel('Counts')

        end
        
        
        
    end
end

