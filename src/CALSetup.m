classdef CALSetup
    
    properties
        
    end
    
    methods 
        function obj = CALSetup()
            
        end

    end
    
    methods (Static = true)
        function [image] = focus(dimensions)    
            % Siemens star for adusting focus of optical system
            
            [X,Y,~] = CALSetup.createGrid(dimensions);            
            slices = 20;
            rings = 0;
            [theta,radius] = cart2pol(X,Y);
            image = 1+sin(slices*theta);
            image = double((image>1)&(radius<0.95)).*255;

            for ii = 1:rings
                radius = 0.9*ii*1/(rings);
                image(radius>(radius - 0.01) & radius<(radius + 0.01)) = 255;
            end
            CALProjectImage(image);
        end
        
        function [image] = opticalAlignment(dimensions)
            % Cross hairs for adusting alignment and centering of optical
            % elements
            [X,Y,R] = CALSetup.createGrid(dimensions);
            image = zeros(dimensions(2),dimensions(1));
            image(abs(X)<=0.005) = 255;
            image(abs(Y)<=0.005) = 255;
            image(R<=0.2 & R>=0.19) = 255;
            image(R<=0.4 & R>=0.39) = 255;
            image(R<=0.6 & R>=0.59) = 255;
            image(R<=0.8 & R>=0.79) = 255;
            CALProjectImage(image);
        end
        
        function [image,spacing,thickness,x_offset] = axisAlignment(dimensions,varargin)
            % Two parallel vertical lines for alignment of rotation axis to
            % central projection axis
            KbName('UnifyKeyNames');
            [X,~,~] = CALSetup.createGrid(dimensions);
            
            % convert all pixel dimensions to normalized dimensions
            if nargin == 1
                thickness = 5/dimensions(1);
                spacing = 200/dimensions(1);
                x_offset = 0; 
            elseif nargin == 3
                spacing = varargin{1}/dimensions(1);
                thickness = varargin{2}/dimensions(1);
                x_offset = varargin{3}/dimensions(1);
            end

            increment = 1/dimensions(1);
            
            image = createLines(thickness,spacing,x_offset);
            SLM = PTB();
            SLM.drawImage(image);
            
                        
            while true
                pressed_key = PTB.checkKey();
                if pressed_key == KbName(']}')
                    % increase spacing
                    spacing = spacing + increment;
                elseif pressed_key == KbName('[{')
                    % decrease spacing
                    spacing = spacing - increment;
                elseif pressed_key == KbName('=+')
                    % increase thickness
                    thickness = thickness + increment;
                elseif pressed_key == KbName('-_')
                    % decrease thickness
                    thickness = thickness - increment;
                elseif pressed_key == KbName('LeftArrow')
                    % shift left
                    x_offset = x_offset + increment;
                elseif pressed_key == KbName('RightArrow')
                    % shift right     
                    x_offset = x_offset - increment;
                elseif pressed_key == KbName('ESCAPE')
                    break
                end
                if thickness <= increment, thickness = 2*increment; end
                if spacing <= 0, spacing = increment; end
                
                image = createLines(thickness,spacing,x_offset);
                SLM.drawImage(image);
            end
            
            % convert final values to pixel dimensions
            thickness = round(thickness*dimensions(1));
            spacing = round(spacing*dimensions(1));
            x_offset = round(x_offset*dimensions(1));
            
            function image = createLines(thickness,spacing,x_offset)
                image = zeros(dimensions(2),dimensions(1));
                image(abs(X+x_offset)>=spacing/2 & abs(X+x_offset)<=spacing/2 + thickness) = 255;
            end
        end
        
        function [image,spacing,circle_radius,z_offset] = resinCalibration(dimensions,varargin)
            % Disks for calibration of induction period for resin and
            % dose vs intensity estimation
            KbName('UnifyKeyNames');
            if nargin == 1
                circle_radius = 40/dimensions(2);
                spacing = 100/dimensions(2);
                z_offset = 0;
                t_offset = 0;
            elseif nargin == 3
                spacing = varargin{1}/dimensions(2);
                circle_radius = varargin{2}/dimensions(2);
                z_offset = varargin{3}/dimensions(2);
                t_offset = varargin{4}/dimensions(2);
            end
            
            intensities = round(fliplr(linspace(10,255,7)));
            increment = 1/dimensions(2);
            image = createDisks(spacing,circle_radius,z_offset,t_offset);
            SLM = PTB();
            SLM.drawImage(image);

            
            
            while true
                pressed_key = PTB.checkKey();
                if pressed_key == KbName(']}')
                    % increase spacing
                    spacing = spacing + increment;
                elseif pressed_key == KbName('[{')
                    % decrease spacing
                    spacing = spacing - increment;
                elseif pressed_key == KbName('=+')
                    % increase radius
                    circle_radius = circle_radius + increment;
                elseif pressed_key == KbName('-_')
                    % decrease radius
                    circle_radius = circle_radius - increment;
                elseif pressed_key == KbName('UpArrow')
                    % shift up
                    z_offset = z_offset + increment;
                elseif pressed_key == KbName('DownArrow')
                    % shift down   
                    z_offset = z_offset - increment;
                elseif pressed_key == KbName('ESCAPE')
                    break
                end
                if circle_radius <= increment, circle_radius = 2*increment; end
                if spacing <= 0, spacing = increment; end
                
                image = createDisks(spacing,circle_radius,z_offset,t_offset);
                SLM.drawImage(image);
            end
            
            % convert final values to pixel dimensions
            spacing = round(spacing*dimensions(1));
            circle_radius = round(circle_radius*dimensions(1));
            z_offset = round(z_offset*dimensions(1));

            function image = createDisks(spacing,circle_radius,z_offset,x_offset)
                image = zeros(dimensions(2),dimensions(1));
                [~,~,R1] = CALSetup.createGrid(dimensions,[x_offset,3*spacing-z_offset]);
                [~,~,R2] = CALSetup.createGrid(dimensions,[x_offset,2*spacing-z_offset]);
                [~,~,R3] = CALSetup.createGrid(dimensions,[x_offset,1*spacing-z_offset]);
                [~,~,R4] = CALSetup.createGrid(dimensions,[x_offset,0*spacing-z_offset]);
                [~,~,R5] = CALSetup.createGrid(dimensions,[x_offset,-1*spacing-z_offset]);
                [~,~,R6] = CALSetup.createGrid(dimensions,[x_offset,-2*spacing-z_offset]);
                [~,~,R7] = CALSetup.createGrid(dimensions,[x_offset,-3*spacing-z_offset]);
                image(R1 < circle_radius) = intensities(1);
                image(R2 < circle_radius) = intensities(2);
                image(R3 < circle_radius) = intensities(3);
                image(R4 < circle_radius) = intensities(4);
                image(R5 < circle_radius) = intensities(5);
                image(R6 < circle_radius) = intensities(6);
                image(R7 < circle_radius) = intensities(7);
            end
            
        end
        
        function [image] = intensityCalibration(dimensions,gray_value)
            % Gray value for measurement of optical power/intensity
            image = ones(dimensions(2),dimensions(1))*gray_value;
            CALProjectImage(image);
        end
        
        
        function showSaveImage(image,name)
            figure;
            imshow(image,[0,255]);
            axis off
            
            saveas(gcf,name)
            
        end
        function [X,Y,R] = createGrid(dimensions,varargin)
            if nargin == 2
                x_offset = varargin{1}(1);
                y_offset = varargin{1}(2);
            else 
                x_offset = 0;
                y_offset = 0;
            end
            dim_x = dimensions(1);
            dim_y = dimensions(2);
            aspect_ratio = dim_x/dim_y;
            [X,Y] = meshgrid(linspace(-1*aspect_ratio,1*aspect_ratio,dim_x),linspace(-1,1,dim_y));
            Y = Y - y_offset;
            X = X - x_offset;
            R = sqrt((X - x_offset).^2 + (Y - y_offset).^2);
        end
        
    end
end

