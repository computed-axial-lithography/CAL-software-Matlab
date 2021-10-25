classdef Projector3DParallelCUDA
    
    properties
        proj_params
        astra_vol_geom 
        astra_proj_geom
        nX
        nY
        nZ
        nT
    end
    
    methods
        function obj = Projector3DParallelCUDA(target_obj,proj_params)
            obj.proj_params = proj_params;
            
            [obj.nX,obj.nY,obj.nZ] = size(target_obj.target);

            % nX = # of voxels in layer in x, nY = # of voxels in layer in y,
            % nZ = # of layers, e.g. for Matlab 3D matrix [nX,nY,nZ] =
            % size(vol); 

            if obj.nX == obj.nY
                % For specific case when nX = nY --> nX = nY = nT
                obj.nT = obj.nX;
                obj.astra_vol_geom = astra_create_vol_geom(obj.nT,obj.nT,obj.nZ);                           
            elseif obj.nX > obj.nY
                % For case when nX > nY --> nT = nX
                obj.nT = obj.nX;
                obj.astra_vol_geom = astra_create_vol_geom(obj.nY,obj.nX,obj.nZ);
            else
                % For case when nY > nX --> nT = nY
                obj.nT = obj.nY;
                obj.astra_vol_geom = astra_create_vol_geom(obj.nY,obj.nX,obj.nZ);
            end
            

            if ~isfield(proj_params,'inclination_angle') || proj_params.inclination_angle == 0
                % det_spacing_x: distance between the centers of two horizontally adjacent detector pixels
                % det_spacing_y: distance between the centers of two vertically adjacent detector pixels
                % det_row_count: number of detector rows in a single projection
                % det_col_count: number of detector columns in a single projection
                % angles: projection angles in radians
                               
                % astra_create_proj_geom('parallel3d', det_spacing_x, det_spacing_y, det_row_count, det_col_count, angles);
                obj.astra_proj_geom = astra_create_proj_geom('parallel3d', 1, 1, obj.nZ, obj.nT, deg2rad(proj_params.angles));
            else
                vectors = genVectorsAstra(proj_params.angles,proj_params.inclination_angle);
                
                % det_row_count: number of detector rows in a single projection
                % det_col_count: number of detector columns in a single projection
                % vectors: a matrix containing the actual geometry
                
                obj.nZ = ceil(dot([obj.nX,obj.nZ],[cosd(90-proj_params.inclination_angle),sind(90-proj_params.inclination_angle)]));
%                               
                % astra_create_proj_geom('parallel3d_vec',  det_row_count, det_col_count, vectors);            
                obj.astra_proj_geom = astra_create_proj_geom('parallel3d_vec',  obj.nZ, obj.nT, vectors);

            end
            
        end
        

        function [b] = forward(obj,x)
            
            [proj_id, b] = astra_create_sino3d_cuda(x, obj.astra_proj_geom, obj.astra_vol_geom);
            astra_mex_data3d('delete', proj_id)
        end
        
        function [x] = backward(obj,b)

            [recon_id, x] = astra_create_backprojection3d_cuda(b, obj.astra_proj_geom, obj.astra_vol_geom);
            astra_mex_data3d('delete', recon_id)

            x = clipToCircle(x);
        end
    end
    
    
%     methods (Static=true)
%         function [vectors] = genVectors(angles,incline_angle)
%             
%             angles = deg2rad(angles);
%             incline_angle = deg2rad(incline_angle);
% 
%             vectors = zeros(length(angles),12);
%             
%             for i = 1:length(angles)
%                 % ray direction
%                 vectors(i,1) = sin(angles(i));
%                 vectors(i,2) = -cos(angles(i));
%                 vectors(i,3) = incline_angle;
% 
%                 % center of detector
%                 vectors(i,4) = 0;
%                 vectors(i,5) = 0;
%                 vectors(i,6) = 0;
% 
%                 % vector from detector pixel (0,0) to (0,1)
%                 vectors(i,7) = cos(angles(i));
%                 vectors(i,8) = sin(angles(i));
%                 vectors(i,9) = 0;
% 
%                 % vector from detector pixel (0,0) to (1,0)
%                 vectors(i,10) = sin(angles(i)) * cos(incline_angle);
%                 vectors(i,11) = -cos(angles(i)) * cos(incline_angle);
%                 vectors(i,12) = cos(incline_angle);
%                 
%                 
%             end
%         end
%     end
end

