function target_obj = CALPrepTarget(stl_filename,resolution,verbose,varargin)

    if ~exist('verbose','var') || isempty(verbose)
        verbose = 0;
    end

        
    if ~isempty(stl_filename)
        [vox_target] = voxelizeTarget(stl_filename,resolution,verbose);
        target_obj = TargetObj(vox_target,resolution,stl_filename);
    elseif nargin==4
        [prepped_target] = prepTarget(varargin{1},verbose);
        target_obj = TargetObj(prepped_target);
        
    end
end

function [prepped_target] = prepTarget(target,verbose)
    if length(size(target)) == 2
        if verbose
            fprintf('Preparing 2D target\n');
            tic;
        end
        
        prepped_target = double(target > 0);
        
        % Care area dilation with a disk structuring element
%         se = strel('disk',1,4);
%         target_care_area = imdilate(target,se);

        if verbose
            Display.displayReconstruction(target);
            runtime = toc;
            fprintf('Finished preparation of 2D target in %.2f seconds\n',runtime);
        end
        
    elseif length(size(target)) == 3
        if verbose
            fprintf('Preparing 3D target\n');
            tic;
        end
        
        prepped_target = double(target > 0);
        
        % Care area dilation with a sphere structuring element
%         se = strel('sphere',4);
%         target_care_area = imdilate(prepped_target,se);
        
        if verbose
            Display.displayReconstruction(prepped_target,'Voxelized Target');

            pause(0.1)
            runtime = toc;
            fprintf('Finished preparation of 3D target in %.2f seconds\n',runtime);
    %         fprintf('Target is [X,Y,Z]: %3.2f x %3.2f x %3.2f mm\n\n',nX*params.voxel_size,nY*params.voxel_size,nZ*params.voxel_size);

        end
    end
end


        
function [voxelized_target] = voxelizeTarget(stl_filename,resolution,verbose)

    if verbose
        fprintf('Beginning voxelization of target\n');
        tic;
    end
    
    bin_filepath = fullfile(mfilename('fullpath'));
    bin_filepath = erase(bin_filepath,'CALPrepTarget');
    bin_filepath = fullfile(bin_filepath,'STL_read_bin');
    addpath(bin_filepath); % add functions specific to the STL read to the path

    fv = stlread(stl_filename); % read STL
    fvV = fv.vertices;
    N = resolution; % # of voxels along the minimum dimension of the part
    Lx = max(fvV(:,1)) - min(fvV(:,1));
    Ly = max(fvV(:,2)) - min(fvV(:,2));
    Lz = max(fvV(:,3)) - min(fvV(:,3));
%     Lmin  = min([Lx Ly Lz]);


    nX = round(N*Lx/Lz);
    if(mod(nX,2) == 0)
        nX = nX+1;
    end

    nY = round(N*Ly/Lz);
    if(mod(nY,2) == 0)
        nY = nY+1;
    end

    nZ = N;
%     if (mod(nZ,2) == 0)
%        nZ = nZ+1;
%     end


    % Define the coordinates of the planes at which the voxelization will occure
    gX = linspace(min(fvV(:,1)),max(fvV(:,1)),nX);
    gY = linspace(min(fvV(:,2)),max(fvV(:,2)),nY);   
    gZ = linspace(min(fvV(:,3)),max(fvV(:,3)),nZ); 

    voxelized_target = double(VOXELISE(gX,gY,gZ,fv));


    % Largest dimension of projections is when the diagonal of the cubic target matrix is perpendicular to the projection angle 
    nR = round(sqrt(nX^2+nY^2));
    if (mod(nR,2)==0)
        nR = nR+1;
    end
    voxelized_target = padarray(voxelized_target, [0.5*(nR-nX) 0.5*(nR-nY)], 0, 'both'); % Pad target with zeros

    domain_size = size(voxelized_target);

    % Care area dilation with a spherical structuring element
%     se = strel('sphere',4);
%     target_care_area = imdilate(voxelized_target,se);


    if verbose
        Display.displayReconstruction(voxelized_target,'Voxelized Target');

        pause(0.1)
        runtime = toc;
        fprintf('Finished voxelization of target in %.2f seconds\n',runtime);
%         fprintf('Target is [X,Y,Z]: %3.2f x %3.2f x %3.2f mm\n\n',nX*params.voxel_size,nY*params.voxel_size,nZ*params.voxel_size);

    end
end




