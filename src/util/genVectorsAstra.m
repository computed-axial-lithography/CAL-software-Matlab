function [vectors] = genVectorsAstra(angles,incline_angle,varargin)
    
    vectors = zeros(length(angles),12);
    angles = deg2rad(angles);
    incline_angle = deg2rad(incline_angle);

    if nargin == 2
        for i = 1:length(angles)
            % ray direction
            vectors(i,1) = sin(angles(i));
            vectors(i,2) = -cos(angles(i));
            vectors(i,3) = -sin(incline_angle);

            % center of detector
            vectors(i,4) = 0;
            vectors(i,5) = 0;
            vectors(i,6) = 0;

            % vector from detector pixel (0,0) to (0,1)  U
            vectors(i,7) = cos(angles(i));
            vectors(i,8) = sin(angles(i));
            vectors(i,9) = 0;

            % vector from detector pixel (0,0) to (1,0)  V
            vectors(i,10) = sin(incline_angle)*sin(angles(i));
            vectors(i,11) = sin(incline_angle)*-cos(angles(i));
            vectors(i,12) = cos(incline_angle);
        end
        
    elseif nargin > 2
        distance_origin_source = varargin{1};
        a = varargin{2};
        for i = 1:length(angles)
            % source
            vectors(i,1) = sin(angles(i)) * distance_origin_source;
            vectors(i,2) = -cos(angles(i)) * distance_origin_source;
            vectors(i,3) = -sin(incline_angle) * distance_origin_source;

            % center of detector
            vectors(i,4) = -sin(angles(i)) * (distance_origin_source-a);
            vectors(i,5) = cos(angles(i)) * (distance_origin_source-a);
            vectors(i,6) = sin(incline_angle) * (distance_origin_source-a);

            % vector from detector pixel (0,0) to (0,1)
            vectors(i,7) = cos(angles(i));
            vectors(i,8) = sin(angles(i));
            vectors(i,9) = 0;

            % vector from detector pixel (0,0) to (1,0)
            vectors(i,10) = sin(incline_angle) * sin(angles(i));
            vectors(i,11) = sin(incline_angle) * -cos(angles(i));
            vectors(i,12) = cos(incline_angle);
        end
    end
    
end