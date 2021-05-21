classdef TargetObj
    
    properties
        target
        resolution
        dim
        stl_filename
    end
    
    methods
%         function obj = TargetObj(target,target_care_area,resolution,varargin)
        function obj = TargetObj(target,resolution,varargin)

            obj.target = target;
%             obj.target_care_area = target_care_area;
            obj.dim = length(size(target));
            if obj.dim == 3 && exist('resolution','var')
                obj.resolution = resolution;
            elseif obj.dim == 3 && ~exist('resolution','var')
                x = size(target);
                obj.resolution = x(end);   
            elseif obj.dim == 2 && ~exist('resolution','var')
                obj.resolution = [];
            end
            
            if nargin == 4
                obj.stl_filename = varargin{1};
            else
                obj.stl_filename = [];
            end
        end
        

    end
end
