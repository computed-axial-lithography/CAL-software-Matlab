classdef Display
    
    properties

    end
    
    methods
        function obj = Display()

        end
  
    
    end
    
    
    methods (Static = true)
        function [] = addPathsDisplay()
            bin_filepath = fullfile(mfilename('fullpath'));
            bin_filepath = erase(bin_filepath,'Display');
            addpath(fullfile(bin_filepath,'colormaps_bin'));
            addpath(fullfile(bin_filepath,'imshow_3D_bin'));
            addpath(fullfile(bin_filepath,'autoArrangeFigures_bin'));
        end
        
        function [] = displayReconstruction(x,varargin)
            
            Display.addPathsDisplay();
            
            if nargin==1
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
                volshow(x,'Parent',panel_3D_static,'Renderer','Isosurface','Isovalue',0.5,'BackgroundColor','white','Isosurfacecolor','cyan');
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
        
        function [] = histogramProjRecon(target,b,x)
            
            
            [gel_inds,void_inds] = CALMetrics.getInds(target);
            
            figure(4)
            
            subplot(2,1,1)
            hold on
            histogram(x(void_inds)./max(x(:)),linspace(0,1,100),'facecolor','r','facealpha',0.5)
            histogram(x(gel_inds)./max(x(:)),linspace(0,1,100),'facecolor','b','facealpha',0.5)
            xlim([0,1])
            set(gca,'yscale','log')
            set(gca,'YMinorTick','on')
            set(gca,'TickDir','out')
            set(gca,'box','on')
            title('Dose distribution')
            xlabel('Normalized Dose')
            ylabel('Voxel Counts')
            legend('Out-of-part Dose','In-part Dose','Location','northwest')
            
            subplot(2,1,2)
            h = histogram(b(b~=0)./max(b(:)),linspace(min(b(b~=0)),1,256),'facecolor','r','facealpha',0.5);
            cdf = cumsum(h.Values);
            hold on
            plot(h.BinEdges(2:end),cdf,'r')
            hold off
            xlim([0,1])
            set(gca,'yscale','log')
            set(gca,'YMinorTick','off')
            set(gca,'TickDir','out')
            set(gca,'box','on')
            title('Projection intensity distribution')
            xlabel('Normalized Intensity')
            ylabel('Counts')
            legend('Counts','CDF','Location','northwest')

        end
        
        function [] = showProjections(b,title_string,intensity_range,figure_number)
            Display.addPathsDisplay();
            
            if ~exist('intensity_range','var') || isempty(intensity_range)
                intensity_range = NaN;
            end

            if ~exist('figure_number','var') || isempty(figure_number)
                figure_number = NaN;
            end

            if ~exist('title_string','var') || isempty(title_string)
                title_string = 'Projections';
            end

          
            pause(0.2)
            
            if ndims(b) == 2
                if ~isnan(figure_number)
                    figure(figure_number)
                else
                    figure
                end    
                imagesc(b)
                colormap(CMRmap())
                colorbar
                
                if ~isnan(title_string)
                    title(title_string)
                end
                
                pause(0.02);
            else

                if isnan(intensity_range)

                    b = flip(b,3);
                    if ~isnan(figure_number)
                        figure(figure_number)
                    else
                        figure
                    end
                    colormap(CMRmap())
                    if isnan(title_string)
                        imshow3D(permute(b,[3,1,2]),[],1);
                    else
                        imshow3D(permute(b,[3,1,2]),[],1,title_string);
                    end

                else

                    b = flip(b,3);
                    if ~isnan(figure_number)
                        figure(figure_number)
                    else
                        figure
                    end
                    colormap(CMRmap())

                    if isnan(title_string)
                        imshow3D(permute(b,[3,1,2]),intensity_range,1);
                    else
                        imshow3D(permute(b,[3,1,2]),intensity_range,1,title_string);
                    end
                end
            end
        end
        
        function [] = showDose(x,title_string,intensity_range,figure_number)
            Display.addPathsDisplay();
            
            if ~exist('intensity_range','var') || isempty(intensity_range)
                intensity_range = NaN;
            end

            if ~exist('figure_number','var') || isempty(figure_number)
                figure_number = NaN;
            end

            if ~exist('title_string','var') || isempty(title_string)
                title_string = 'Reconstruction';
            end

            pause(0.2)

            if ndims(x) == 2
                if ~isnan(figure_number)
                    figure(figure_number)
                else
                    figure
                end
                
                imagesc(x)
                colormap(CMRmap())
                daspect([1 1 1])
                colorbar
                if ~isnan(intensity_range)
                    caxis(intensity_range)
                end
                if ~isnan(title_string)
                    title(title_string)
                end
                pause(0.02);
            else

                if isnan(intensity_range)

                    if ~isnan(figure_number)
                        figure(figure_number)
                    else
                        figure
                    end
                    colormap(CMRmap())
                    if isnan(title_string)
                        imshow3D(x,[],1);
                    else
                        imshow3D(x,[],1,title_string);
                    end 
                else

                    if ~isnan(figure_number)
                        figure(figure_number)
                    else
                        figure
                    end
                    colormap(CMRmap())

                    if isnan(title_string)
                        imshow3D(x,intensity_range,1);
                    else
                        imshow3D(x,intensity_range,1,title_string);
                    end        

                end
            end
        end
            
        function [] = showImageSet(image_set_obj)
            Display.addPathsDisplay();
            
            figure
            if ~isequal(class(image_set_obj),'ImageSetObj')
                error('Input should be a ImageSetObj object')
                return
            end
            image_set = image_set_obj.image_set;
            
%             tmp_projections = zeros([size(proj_set{1},2),size(proj_set,2),size(proj_set{1},1)]);
            tmp_images = zeros([size(image_set{1}),size(image_set,2)],'single'); % changed to single to save memory
            for i=1:size(image_set,2)
                tmp_images(:,:,i) = image_set{i};
            end
            colormap(CMRmap())
            
            imshow3D(tmp_images,[],1)
        end
    end
end

