classdef CALSetup
    
    properties
        
    end
    
    methods 
        function obj = CALSetup()
            
        end

    end
    
    methods (Static = true)
        function focus(dimensions)        
            [Y,X,~] = CALSetup.createGrid(dimensions);            
            slices = 20;
            rings = 0;
            [theta,radius] = cart2pol(X,Y);
            image = 1+sin(slices*theta);
            image = double((image>1)&(radius<0.55)).*255;

            for ii = 1:rings
                radius = 0.9*ii*1/(rings);
                image(radius>(radius - 0.01) & radius<(radius + 0.01)) = 255;
            end

            CALProjectImage(image);
        end
        
        function [image] = opticalAlignment(dimensions)
            [Y,X,R] = CALSetup.createGrid(dimensions);
            image = zeros(dimensions(2),dimensions(1));
            image(abs(X)<=0.005) = 255;
            image(abs(Y)<=0.005) = 255;
            image(R<=0.2 & R>=0.19) = 255;
            image(R<=0.4 & R>=0.39) = 255;
            image(R<=0.6 & R>=0.59) = 255;
            image(R<=0.8 & R>=0.79) = 255;
            CALProjectImage(image);
        end
        
        function [image,thickness,spacing] = axisAlignment(dimensions,varargin)
            [~,X,~] = CALSetup.createGrid(dimensions);
            
            % convert all pixel dimensions to normalized dimensions
            if nargin == 1
                thickness = 5/dimensions(1);
                spacing = 200/dimensions(1);             
            elseif nargin == 2
                thickness = varargin{1}/dimensions(1);
                spacing = 200/dimensions(1);
            elseif nargin == 3
                thickness = varargin{1}/dimensions(1);
                spacing = varargin{2}/dimensions(1);
            end
                
            increment = 1/dimensions(1);
            
            image = createLines(thickness,spacing);

            SLM = PTB();
            SLM.drawImage(image);
            
                        
            while true
                pressed_key = PTB.checkKey();
                if pressed_key == KbName('RightArrow')
                    % increase spacing
                    spacing = spacing + increment;
                elseif pressed_key == KbName('LeftArrow')
                    % decrease spacing
                    spacing = spacing - increment;
                elseif pressed_key == KbName('UpArrow')
                    % increase thickness
                    thickness = thickness + increment;
                elseif pressed_key == KbName('DownArrow')
                    % decrease thickness
                    thickness = thickness - increment;
                elseif pressed_key == KbName('ESCAPE')
                    break
                end
                if thickness <= increment, thickness = 2*increment; end
                if spacing <= 0, spacing = increment; end
                
                image = createLines(thickness,spacing);
                SLM.drawImage(image);
            end
            
            % convert final values to pixel dimensions
            thickness = thickness*dimensions(1);
            spacing = spacing*dimensions(1);
            
            function image = createLines(thickness,spacing)
                image = zeros(dimensions(2),dimensions(1));
                image(abs(X)>=spacing/2 & abs(X)<=spacing/2 + thickness) = 255;
            end
        end
        
        function calibration()
            fprintf('Resin calibration not implemented yet.\n');
        end
        
        function [image] = powerCalibration(dimensions,gray_value)
            image = ones(dimensions(2),dimensions(1))*gray_value;
            CALProjectImage(image);
        end
        
        function [X,Y,R] = createGrid(dimensions)
            dim_x = dimensions(2);
            dim_y = dimensions(1);
            aspect_ratio = dim_x/dim_y;
            [Y,X] = meshgrid(linspace(-1,1,dim_y),linspace(-1*aspect_ratio,1*aspect_ratio,dim_x));
            R = sqrt(X.^2 + Y.^2);
        end
        
    end
end

