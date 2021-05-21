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
        gel_inds
        void_inds
    end
    
    methods
        function obj = CALOptimize(target_obj,opt_params,proj_params,verbose)
            % set default values
            obj.default_opt.parallel = 0;
            obj.default_opt.max_iter = 10;
            obj.default_opt.learning_rate = 0.005;
            obj.default_opt.sigmoid = 0.01;
            obj.default_opt.threshold = NaN;
            obj.default_opt.Beta = 0;
            obj.default_opt.Theta = 0;           
            obj.default_opt.Rho = 0;
            
            obj.default_proj.angles = linspace(0,179,180);  
            obj.default_proj.bit8 = 0;  
            obj.default_proj.equalize8bit = 0;  
            
            obj = obj.parseParams(opt_params,proj_params);
            
            obj.target_obj = target_obj;
            
            
            
            obj.verbose = verbose;
            
            obj.A = CALProjectorConstructor(target_obj,obj.proj_params,obj.opt_params.parallel);
            
            obj.thresholds = zeros(1,opt_params.max_iter);
            obj.error = zeros(1,opt_params.max_iter);
%             [obj.gel_inds,obj.void_inds] = obj.getInds();
        end
        
        function [obj] = parseParams(obj,opt_params,proj_params)
            
            obj.opt_params = opt_params;
            obj.proj_params = proj_params;
            
            if ~isfield(opt_params,'parallel')
                obj.opt_params.parallel = obj.default_opt.parallel;
            end
            if ~isfield(opt_params,'max_iter')
                obj.opt_params.max_iter = obj.default_opt.max_iter;
            end
            if ~isfield(opt_params,'learning_rate')
                obj.opt_params.learning_rate = obj.default_opt.learning_rate;
            end
            if ~isfield(opt_params,'sigmoid')
                obj.opt_params.sigmoid = obj.default_opt.sigmoid;
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
        end
        
        function [opt_proj_obj,opt_recon_obj,obj] = run(obj)

            
            if obj.verbose
                Display.addPathsDisplay();
                fprintf('Beginning optimization of projections\n');

                display_ev = DisplayEvolving(obj.target_obj.dim);
                display = Display();

                autoArrangeFigures(2,3)  % automatically arrange figures on screen

                tic;
            end
            
            
            
            b = obj.A.forward(obj.target_obj.target);
            
            b = filterProjections(b,'ram-lak');
            b = max(b,0);
            
            opt_b = b;
            delta_b_prev = zeros(size(b));
            

            for curr_iter=1:obj.opt_params.max_iter
                
                if obj.proj_params.bit8
                    opt_b = obj.to8Bit(opt_b);
%                 end
%                 if obj.proj_params.equalize8bit
                    opt_b = obj.equalize8Bit(opt_b);
                end
                
                x = obj.A.backward(opt_b);
                
                x = x/max(x(:));
                
                if ~isnan(obj.opt_params.threshold)
                    curr_threshold = obj.opt_params.threshold;
                else
                    curr_threshold = findThreshold(x,obj.target_obj.target,obj.gel_inds,obj.void_inds);
                end
                
                obj.thresholds(curr_iter) = curr_threshold; % store thresholds as a function of the iteration number
                    

                mu = curr_threshold;
%                 mu_dilated = (1-obj.opt_params.Rho)*curr_threshold; 
%                 mu_eroded = (1+obj.opt_params.Rho)*curr_threshold;

                
                x_thresh = obj.sigmoid((x-mu), obj.opt_params.sigmoid);
%                 x_thresh_eroded = obj.sigmoid((x-mu_eroded), obj.opt_params.sigmoid);
%                 x_thresh_dilated = obj.sigmoid((x-mu_dilated), obj.opt_params.sigmoid);
                
                
                delta_x = (x_thresh - obj.target_obj.target);%.*obj.target_obj.target_care_area; % Target space error   
%                 delta_x_eroded = (x_thresh_eroded - obj.target_obj.target).*obj.target_obj.target_care_area; % Eroded version
%                 delta_x_dilated = (x_thresh_dilated - obj.target_obj.target).*obj.target_obj.target_care_area; % Dilated version
                
%                 delta_x_feedback = (delta_x + delta_x_eroded + delta_x_dilated)/3;
                delta_x_feedback = delta_x;

                obj.error(curr_iter) = CALMetrics.calcVER(obj.target_obj.target,x);
                
                delta_b = obj.A.forward(delta_x_feedback);
                gradient_approx = ((1-obj.opt_params.Beta)*delta_b + obj.opt_params.Beta*delta_b_prev)/(1-obj.opt_params.Beta^curr_iter);
                opt_b = opt_b - obj.opt_params.learning_rate*gradient_approx; %Update involving a controlled step size and memory effect
                opt_b = opt_b.*(double(opt_b >= 0)+obj.opt_params.Theta*double(opt_b < 0)); %Impose positivity constraint using a relaxation parameter
                
                delta_b_prev = delta_b;

                
                
                if obj.verbose
                    % Plot evolving error
                    display.errorPlot(curr_iter,obj.opt_params.max_iter,obj.error)
                    
                    % Plot evolving reconstruction
                    if obj.target_obj.dim == 3
                        display_ev.displayEvolvingReconstruction(x_thresh,curr_iter,curr_threshold);
                    else
                        display_ev.displayEvolvingReconstruction(x,curr_iter,curr_threshold);
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
                
                display.histogramProjRecon(opt_b,x,obj.gel_inds,obj.void_inds)
                display.showProjections(opt_b,'Optimized Projections');
                display.showDose(x,'Optimized Reconstruction');
                autoArrangeFigures(2,3)  % automatically arrange figures on screen

            end
            
        end
        
    end
    
    methods (Static = true)
        function y = sigmoid(x,g)
            y = 1./(1+exp(-x*(1/g)));
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

