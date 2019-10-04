function [target,target_care_area] = voxelize_target(params,verbose)
% Function that breaks meshed STL file into discrete voxelized domain where
% the value at an index in the output target matrix is 1 where there is
% solid and 0 where there is absence of solid
%
% Input:
%   params.stl_filename = string, file name of the STL in the working directory
%   params.resolution = scalar, # of voxels for the output target matrix to have
%   in the minimum x,y,or z dimension of the design STL file
%   verbose = 1 or 0, activates or deactivates visualization of the
%   voxelized STL and additional information display
%
% Output:
%   target = matrix, 2D matrix of input target or 3D matrix of voxelized STL
%   target_care_area = matrix, defines the dilated version of the target 
%
% Created by: Indrasen Bhattacharya 2017-05-07
% Modified by: Joseph Toombs 08/2019

if ~exist('verbose','var')
    verbose = 0;
end



% Run routine for 2D target or STL depending on which is specified
if isfield(params,'target_2D')
    if verbose
        fprintf('Preparing 2D target\n');
        tic;
    end
    target = params.target_2D;

    % Care area dilation with a few different structuring elements can be imposed
    se = strel('disk',2,4);
    target_care_area = imdilate(target,se);
    figure
    imagesc(target_care_area)
    
elseif isfield(params,'stl_filename')
    if verbose
        fprintf('Beginning voxelization of target\n');
        tic;
    end

    addpath('STL_read_bin'); % add functions specific to the STL read to the path

    fv = stlread(params.stl_filename); % read STL
    fvV = fv.vertices;
    N = params.resolution; % # of voxels along the minimum dimension of the part
    Lx = max(fvV(:,1)) - min(fvV(:,1));
    Ly = max(fvV(:,2)) - min(fvV(:,2));
    Lz = max(fvV(:,3)) - min(fvV(:,3));
    Lmin  = min([Lx Ly Lz]);

    % Scale the length of each axis
    if (Lx == Lmin) % x axis is has the smallest length
       nX = N; % set the x axis # of voxels to the resolution input
       if (mod(nX,2) ~= 0)
           nX = nX+1;
       end

       nY = round(N*Ly/Lx); %set the y axis # of voxels to scaled resolution input
       if (mod(nY,2) ~= 0)
           nY = nY+1;
       end

       nZ = round(N*Lz/Lx); %set the z axis # of voxels to scaled resolution input
       if (mod(nZ,2) ~= 0)
           nZ = nZ+1;
       end



    elseif (Ly == Lmin) % y axis has the smallest length
        nX = round(N*Lx/Ly);
        if(mod(nX,2) ~= 0)
            nX = nX+1;
        end

        nY = N;
        if(mod(nY,2) ~= 0)
            nY = nY+1;
        end

        nZ = round(N*Lz/Ly);
        if (mod(nZ,2) ~= 0)
           nZ = nZ+1;
        end

    else % z axis has the smallest length

        nX = round(N*Lx/Lz);
        if(mod(nX,2) ~= 0)
            nX = nX+1;
        end

        nY = round(N*Ly/Lz);
        if(mod(nY,2) ~= 0)
            nY = nY+1;
        end

        nZ = N;
        if (mod(nZ,2) ~= 0)
           nZ = nZ+1;
        end

    end

    % Define the coordinates of the planes at which the voxelization will occure
    gX = linspace(min(fvV(:,1)),max(fvV(:,1)),nX);
    gY = linspace(min(fvV(:,2)),max(fvV(:,2)),nY);   
    gZ = linspace(min(fvV(:,3)),max(fvV(:,3)),nZ); 

    target = double(VOXELISE(gX,gY,gZ,fv));


    % Largest dimension of projections is when the 
    nR = round(sqrt(nX^2+nY^2));
    if (mod(nR,2)~=0)
        nR = nR+1;
    end
    target = padarray(target, [0.5*(nR-nX) 0.5*(nR-nY)], 0, 'both'); % Pad target with zeros

    % Care area dilation with a few different structuring elements can be imposed
    se = strel('sphere',2);
    target_care_area = imdilate(target,se);

    % To change orientations:
    % padded_target = permute(target, [1 2 3]); 

    % To invert the geometry
    %T = ones(size(T))-T;


    if verbose
        figure;
        volshow(target);
        pause(0.1)
        runtime = toc;
        fprintf('Finished preparation of target %.2f seconds\n\n',runtime);
    end

else
    fprintf('No input geometry defined. Define input geometry by entering .stl filename in\n params.stl_filename or 2D geometry in params.target_2D.\n\n')
end