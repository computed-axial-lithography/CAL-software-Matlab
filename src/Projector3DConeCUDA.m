classdef Projector3DConeCUDA
    
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
        function obj = Projector3DConeCUDA(target_obj,proj_params)
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
            
            
            DSO = obj.nT/sin(deg2rad(proj_params.cone_angle)); % distance source-to-origin
            nT_detector = ceil(2*(DSO+obj.nT)*tan(deg2rad(proj_params.cone_angle)));
            
            
            if ~isfield(proj_params,'inclination_angle') || proj_params.inclination_angle == 0
                % det_spacing_x: distance between the centers of two horizontally adjacent detector pixels
                % det_spacing_y: distance between the centers of two vertically adjacent detector pixels
                % det_row_count: number of detector rows in a single projection
                % det_col_count: number of detector columns in a single projection
                % angles: projection angles in radians
                % source_origin: distance between the source and the center of rotation
                % origin_det: distance between the center of rotation and the detector array
                
                % astra_create_proj_geom('cone',  det_spacing_x, det_spacing_y, det_row_count, det_col_count, angles, source_origin, origin_det);
                obj.astra_proj_geom = astra_create_proj_geom('cone', 1, 1, obj.nZ, nT_detector, deg2rad(proj_params.angles), DSO, obj.nT);

            else
                vectors = genVectorsAstra(proj_params.angles,proj_params.inclination_angle,DSO);
                
                % det_row_count: number of detector rows in a single projection
                % det_col_count: number of detector columns in a single projection
                % vectors: a matrix containing the actual geometry
                
                % astra_create_proj_geom('cone_vec',  det_row_count, det_col_count, vectors);
                obj.astra_proj_geom = astra_create_proj_geom('cone_vec',  obj.nZ, nT_detector, vectors);
            end
            

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

