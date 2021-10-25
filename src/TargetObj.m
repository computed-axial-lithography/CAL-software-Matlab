classdef TargetObj
    
    properties
        target
        resolution
        dim
        stl_filename
        bounds_x
        bounds_y
        bounds_z
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
            [obj.bounds_x,obj.bounds_y,obj.bounds_z] = TargetObj.findBoundingBox(obj.target);
        end
        
    end
    methods (Static=true)
        function [bounds_x,bounds_y,bounds_z] = findBoundingBox(target)
            bounds_x = zeros(1,2);
            bounds_y = zeros(1,2);
            if ndims(target) == 3
                bounds_z = zeros(1,2);
                bounds_z(1) = find(sum(target,[1,2]),1,'first');
                bounds_z(2) = find(sum(target,[1,2]),1,'last');
            else
                bounds_z = NaN;
            end
            
            bounds_y(1) = find(sum(target,[2,3]),1,'first');
            bounds_y(2) = find(sum(target,[2,3]),1,'last');
            bounds_x(1) = find(sum(target,[1,3]),1,'first');
            bounds_x(2) = find(sum(target,[1,3]),1,'last');
        end
    end
    
end
