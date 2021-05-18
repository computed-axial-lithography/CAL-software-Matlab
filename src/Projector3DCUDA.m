classdef Projector3DCUDA
    
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
        function obj = Projector3DCUDA(target_obj,proj_params)
            obj.proj_params = proj_params;
            
            [obj.nX,obj.nY,obj.nZ] = size(target_obj.target);

            % nX = # of voxels in layer in x, nY = # of voxels in layer in y,
            % nZ = # of layers, e.g. for Matlab 3D matrix [nX,nY,nZ] =
            % size(vol); 
            
            % For specific case when nX = nY --> nX = nY = nT
            if obj.nX == obj.nY
                obj.nT = obj.nX;
                obj.astra_vol_geom = astra_create_vol_geom(obj.nT,obj.nT,obj.nZ);                           
            else
                obj.astra_vol_geom = astra_create_vol_geom(obj.nY,obj.nX,obj.nZ);
            end
            
            
            % astra_create_proj_geom('parallel3d', det_spacing_x, det_spacing_y, det_row_count, det_col_count, angles);
            obj.astra_proj_geom = astra_create_proj_geom('parallel3d', 1, 1, obj.nZ, obj.nT, deg2rad(proj_params.angles));

        end
        

        function [b] = forward(obj,x)
            
            [~, b] = astra_create_sino3d_cuda(x, obj.astra_proj_geom, obj.astra_vol_geom);

        end
        
        function [x] = backward(obj,b)

            [~, x] = astra_create_backprojection3d_cuda(b, obj.astra_proj_geom, obj.astra_vol_geom);

            x = clipToCircle(x);
        end
    end
end

