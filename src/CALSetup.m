classdef CALSetup
    
    properties
        
    end
    
    methods 
        function obj = CALSetup()
            
        end

    end
    
    methods (Static = true)
        function focus(dimensions)        
            [X,Y] = meshgrid(linspace(0,dimensions(1)/2,dimensions(1)),linspace(0,dimensions(2)/2,dimensions(2)));
            f_x = X./dimensions(1);
            f_y = Y./dimensions(2);
            grating_x = cos(2*pi*f_x)>0;
            grating_y = cos(2*pi*f_y)>0;

            A = zeros(dimensions(2),dimensions(1));
            A(Y>X) = grating_y(Y>X);
            A(Y<=X) = grating_x(Y<=X);
            
            figure;
            imagesc(grating_x)
            colormap('gray')
            truesize
%             CALProjectImage(image);
        end
        
        function [image] = alignment(dimensions)
            [X,Y,R] = CALSetup.createGrid(dimensions);
            image = zeros(dimensions(2),dimensions(1));
            image(abs(X)<=0.005) = 255;
            image(abs(Y)<=0.005) = 255;
            image(R<=0.2 & R>=0.19) = 255;
            image(R<=0.4 & R>=0.39) = 255;
            image(R<=0.6 & R>=0.59) = 255;
            image(R<=0.8 & R>=0.79) = 255;
%             CALProjectImage(image);
        end
        
        function calibration()
            fprintf('Resin calibration not implemented yet.\n');
        end
        
        function [image] = powerCalibration(dimensions,gray_value)
            image = ones(dimensions(2),dimensions(1))*gray_value;
%             CALProjectImage(image);
        end
        
        function [X,Y,R] = createGrid(dimensions)
            dim_x = dimensions(2);
            dim_y = dimensions(1);
            aspect_ratio = dim_x/dim_y;
            [Y,X] = meshgrid(linspace(-1,1,dim_y),linspace(-1*aspect_ratio,1*aspect_ratio,dim_x));
            R = sqrt(X.^2 + Y.^2);
        end
        
%         function [gel_inds,void_inds] = getInds(target)
%             circle_mask = CALMetrics.getCircleMask(target);
%             gel_inds = circle_mask & target==1;
%             void_inds = circle_mask & ~target;
%         end
%         
%         function circle_mask = getCircleMask(target)
%             target_dim = ndims(target);
%             if target_dim == 2
%                 [X,Y] = meshgrid(linspace(-1,1,size(target,1)),linspace(-1,1,size(target,1)));
%                 R = sqrt(X.^2 + Y.^2);
% 
%             elseif target_dim == 3                
%                 [X,Y,~] = meshgrid(linspace(-1,1,size(target,1)),linspace(-1,1,size(target,1)),linspace(-1,1,size(target,3)));
%                 R = sqrt(X.^2 + Y.^2);
%             end
%             
%             circle_mask = logical(R.*(R<=1));
%         end
%         
%         function run(type,dimensions)
%             if strcmp(type,'alignment')
%                 image = CALSetup.alignment(dimensions);
%             elseif strcmp(type,'focus')
%                 image = CALSetup.focus(dimensions);
%             elseif strcmp(type,'power')
%                 varargin
%                 image = CALSetup.powerCalibration(dimensions,
%             end
%             CALProjectImage(image);
%         end
    end
end

