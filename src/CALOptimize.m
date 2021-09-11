classdef CALOptimize
    
    properties
        target_obj
        default_opt
        default_proj
        opt_params
        proj_params
        A
        verbose
        
        thresholds
        error
    end
    
    methods
        function obj = CALOptimize(target_obj,opt_params,proj_params,verbose)
            % set default values
            obj.default_opt.filter = true;
            obj.default_opt.parallel = 0;
            obj.default_opt.max_iter = 10;
            obj.default_opt.learning_rate = 0.005;
            obj.default_opt.threshfunc = 'sigmoid';
            obj.default_opt.threshfunc_params = {};
            obj.default_opt.thresh_width = 0.01;
            obj.default_opt.threshold = NaN;
            obj.default_opt.Beta = 0;
            obj.default_opt.Theta = 0;           
            obj.default_opt.Rho = 0;
            
            obj.default_proj.angles = linspace(0,179,180);  
            obj.default_proj.bit8 = 0;  
            obj.default_proj.equalize8bit = 0;  
            obj.default_proj.zero_constraint = false;
            obj.default_proj.proj_mask = false;

            obj = obj.parseParams(opt_params,proj_params);
            
            obj.target_obj = target_obj;
            
            
            
            obj.verbose = verbose;
            
            
            
            if obj.proj_params.zero_constraint == true
                % run image segmentation flood fill routine
                [obj.proj_params.zero_constraint,~] = getFills(target_obj.target);
            end
            obj.A = CALProjectorConstructor(target_obj,obj.proj_params,obj.opt_params.parallel);
            


            obj.thresholds = zeros(1,opt_params.max_iter);
            obj.error = zeros(1,opt_params.max_iter);
        end
        
        function [obj] = parseParams(obj,opt_params,proj_params)
            
            obj.opt_params = opt_params;
            obj.proj_params = proj_params;
            
            if ~isfield(opt_params,'filter')
                obj.opt_params.filter = obj.default_opt.filter;
            end
            if ~isfield(opt_params,'parallel')
                obj.opt_params.parallel = obj.default_opt.parallel;
            end
            if ~isfield(opt_params,'max_iter')
                obj.opt_params.max_iter = obj.default_opt.max_iter;
            end
            if ~isfield(opt_params,'learning_rate')
                obj.opt_params.learning_rate = obj.default_opt.learning_rate;
            end
            if ~isfield(opt_params,'threshfunc')
                obj.opt_params.threshfunc = obj.default_opt.threshfunc;
            end
            if ~isfield(opt_params,'threshfunc_params')
                obj.opt_params.threshfunc_params = obj.default_opt.threshfunc_params;
            else 
                assert(isa(obj.opt_params.threshfunc_params,'cell'),'threshfunc_params must be a 1xn cell array.')
                assert(size(obj.opt_params.threshfunc_params,1)==1,'threshfunc_params must be a 1xn cell array.')
            end
            if ~isfield(opt_params,'thresh_width')
                obj.opt_params.thresh_width = obj.default_opt.thresh_width;
            end
            if ~isfield(opt_params,'threshold')
                obj.opt_params.threshold = obj.default_opt.threshold;
            end
            if ~isfield(opt_params,'Beta')
                obj.opt_params.Beta = obj.default_opt.Beta;
            end
            if ~isfield(opt_params,'Theta')
                obj.opt_params.Theta = obj.default_opt.Theta;
            end
            if ~isfield(opt_params,'Rho')
                obj.opt_params.Rho = obj.default_opt.Rho;
            end

            
            if ~isfield(proj_params,'angles')
                obj.proj_params.angles = obj.default_proj.angles;
            end
            if ~isfield(proj_params,'bit8')
                obj.proj_params.bit8 = obj.default_proj.bit8;
            end
            if ~isfield(proj_params,'equalize8bit')
                obj.proj_params.equalize8bit = obj.default_proj.equalize8bit;
            end
            if ~isfield(proj_params,'zero_constraint')
                obj.proj_params.zero_constraint = obj.default_proj.zero_constraint;
            end
            if ~isfield(proj_params,'proj_mask')
                obj.proj_params.proj_mask = obj.default_proj.proj_mask;
            end
        end
        
        function [opt_proj_obj,opt_recon_obj,obj] = run(obj)
            
            if obj.verbose
                Display.addPathsDisplay();
                fprintf('Beginning optimization of projections\n');

                display_ev = DisplayEvolving(obj.target_obj.dim);
                display = Display();

%                 autoArrangeFigures(2,3)  % automatically arrange figures on screen

                tic;
            end
            
            
            % Option to pick up where the last optimization left off
            persistent opt_b delta_b_prev
            if ~isempty(opt_b)
                end_prompt = 0;
                while ~end_prompt
                    prompt = 'Found optimized projection from the last optimization. Do you want to pick up where the last optimization left off?  Y/N [N]: ';
                    str = input(prompt,'s');
                    if isempty(str) || strcmpi(str,'N') % case insensitive
                        opt_b = [];
                        end_prompt = 1;
                    elseif strcmpi(str,'Y')
                        end_prompt = 1;
                    end
                end
            end
            if isempty(opt_b) % initialize opt_b and delta_b_prev
                b = obj.A.forward(obj.target_obj.target);
            
                if obj.opt_params.filter
                    b = filterProjections(b,'ram-lak');
                    b = max(b,0);
                end

                opt_b = b;
                delta_b_prev = zeros(size(b));
            end
            
            
            

            for curr_iter=1:obj.opt_params.max_iter
                
                if obj.proj_params.bit8
                    opt_b = obj.to8Bit(opt_b);
%                 end
%                 if obj.proj_params.equalize8bit
                    opt_b = obj.equalize8Bit(opt_b);
                end
                
                x = obj.A.backward(opt_b);
                
                x = x/max(x(:));
                
                if strcmp(obj.opt_params.threshfunc, 'sigmoid') || strcmp(obj.opt_params.threshfunc, 'tanh')
                    if ~isnan(obj.opt_params.threshold)
                        curr_threshold = obj.opt_params.threshold;
                    else
                        curr_threshold = findThreshold(x,obj.target_obj.target);
                    end

                    obj.thresholds(curr_iter) = curr_threshold; % store thresholds as a function of the iteration number

                    mu = curr_threshold;
                    mu_dilated = (1-obj.opt_params.Rho)*curr_threshold; 
                    mu_eroded = (1+obj.opt_params.Rho)*curr_threshold;

                    x_thresh = obj.threshmap(obj.opt_params.threshfunc,(x-mu), obj.opt_params.thresh_width);
                end
                
                if strcmp(obj.opt_params.threshfunc, 'sigmoid')
                    x_thresh_eroded = obj.threshmap(obj.opt_params.threshfunc,(x-mu_eroded), obj.opt_params.thresh_width);
                    x_thresh_dilated = obj.threshmap(obj.opt_params.threshfunc,(x-mu_dilated), obj.opt_params.thresh_width);

                    delta_x = (x_thresh - obj.target_obj.target).*obj.target_obj.target_care_area; % Target space error   
                    delta_x_eroded = (x_thresh_eroded - obj.target_obj.target).*obj.target_obj.target_care_area; % Eroded version
                    delta_x_dilated = (x_thresh_dilated - obj.target_obj.target).*obj.target_obj.target_care_area; % Dilated version

                    delta_x_feedback = (delta_x + delta_x_eroded + delta_x_dilated)/3;
               
                elseif strcmp(obj.opt_params.threshfunc, 'tanh')
                    delta_x_feedback = (x_thresh - obj.target_obj.target).*obj.target_obj.target_care_area; % Target space error                  
                else
                    x_thresh = obj.threshmap(obj.opt_params.threshfunc,x,obj.opt_params.threshfunc_params{:}); % unpack threshfunc_params and pass as arguments
                    delta_x_feedback = (x_thresh - obj.target_obj.target).*obj.target_obj.target_care_area; % Target space error 
                end
                
                obj.error(curr_iter) = CALMetrics.calcVER(obj.target_obj.target,x);
%                 obj.error(curr_iter) = CALMetrics.calcMSE(obj.target_obj.target,x);
                
                delta_b = obj.A.forward(delta_x_feedback);
                gradient_approx = ((1-obj.opt_params.Beta)*delta_b + obj.opt_params.Beta*delta_b_prev)/(1-obj.opt_params.Beta^curr_iter);
                opt_b = opt_b - obj.opt_params.learning_rate*gradient_approx; %Update involving a controlled step size and memory effect
                opt_b = opt_b.*(double(opt_b >= 0)+obj.opt_params.Theta*double(opt_b < 0)); %Impose positivity constraint using a relaxation parameter
                
                delta_b_prev = delta_b;

                
                
                if obj.verbose
                    % Plot evolving error
                    display.errorPlot(curr_iter,obj.opt_params.max_iter,obj.error)
                    
                    % Plot evolving reconstruction
                    % VolumeRendering/Isosurface in volshow depending on threshmap
                    if obj.target_obj.dim == 3
                        if strcmp(obj.opt_params.threshfunc,'sigmoid') || strcmp(obj.opt_params.threshfunc,'tanh')
                            display_ev.displayEvolvingReconstruction(x_thresh,curr_iter,curr_threshold);
                        else
                            display_ev.displayEvolvingReconstruction(x_thresh,curr_iter);
                        end
                    else
                        display_ev.displayEvolvingReconstruction(x,curr_iter);
                    end
                    
                    autoArrangeFigures(2,3)  % automatically arrange figures on screen

                    pause(0.1);            
                end
                
            end
            
            
            opt_proj_obj = ProjObj(opt_b,obj.proj_params,obj.opt_params);
            opt_recon_obj = ReconObj(x,obj.proj_params,obj.opt_params);
            if obj.verbose
                
                runtime = toc;
                fprintf('Finished optimization of projections in %.2f seconds\n',runtime);
                
                display.histogramProjRecon(obj.target_obj.target,opt_b,x)
                display.showProjections(opt_b,'Optimized Projections');
                display.showDose(x,'Optimized Reconstruction');
                autoArrangeFigures(2,3)  % automatically arrange figures on screen

            end
            
        end
        
    end
    
    methods (Static = true)      
        function y = threshmap(threshfunc, x, varargin)
            if strcmp(threshfunc,'sigmoid')
                narginchk(3,3)
                g = varargin{1};
                y = 1./(1+exp(-x*(1/g)));
            elseif strcmp(threshfunc,'tanh')
                narginchk(3,3)
                y = tanh(varargin{1}.*x);
            elseif strcmp(threshfunc,'relux')
                narginchk(2,4)
                % default lower and upper bounds of x
                bounds = [0 1];
                % replace defaults if exists
                if ~isempty(varargin)
                    bounds = cell2mat(varargin);
                end
                assert(bounds(2)>bounds(1), 'Upper bound of threshold function must be greater than its lower bound.')
                % linear function with bounds
                k=1/(bounds(2)-bounds(1));
                y = k.*(x-bounds(1));
                y(bounds(2)<x) = 1;
                y(x<bounds(1)) = 0;
                
            elseif isa(threshfunc,'function_handle') % Custom function by user, must be function handle
                y = threshfunc(x, varargin);
            else
                error('Invalid threshfunc. Must be ''sigmoid'',''tanh'',''relu'' or a function handle.')
            end
        end
        
        function out = to8Bit(in)
            out = double(uint8(in/max(in(:))*255))/255;
        end 
        
        function eqI = equalize8Bit(I)

            % 3D image
            eqI = imadjustn(I);

%             % 2D images
%             eqI = zeros(size(I),'like',I);
%             for i=1:size(I,2)
%                 in = squeeze(I(:,i,:));
%                 out = imadjust(in,stretchlim(in),[]);
%                 out = double(uint8(out/max(out(:))*255))/255;
%                 
% %                 out = adapthisteq(in,'ClipLimit',0.001,'NBins',256,'Range','full','Distribution','rayleigh');
% %                 figure(100)
% %                 subplot(2,2,1)
% %                 imagesc(out)
% %                 subplot(2,2,3)
% %                 histogram(out)
% %                 subplot(2,2,2)
% %                 imagesc(in)
% %                 subplot(2,2,4)
% %                 histogram(in)
% %                 pause(0.01)
%                 
%                 eqI(:,i,:) = out;
%             end
            
%             % Deprecated
%             [Values, Edges] = histcounts(I(:)); % bins the projections into 
%             Edges = Edges(1:end-1);
%             %This is somewhat empirical: trying to obtain a good way to scale
%             %Another option would be to attempt histogram equalization
%             %or any alternate form of light training
%             vMax = mean(Edges(Edges.*Values == max(Edges.*Values)));
%             scale = 100/vMax;
%             eqI = uint8(I*scale)+1;
%             eqI = double(eqI);
        end
    end
end

