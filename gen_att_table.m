function att_table = gen_att_table(params,domain_size,occlusion)
% INPUTS:  params        =  struct, contains all parameters specific to the
%                           process including vial radius, pentration depth,
%                           interpolation method
%          domain_size   =  vector, size of the reconstruction/target space
% 
% OUTPUTS: att_table     =  matrix, [N x N x N_theta] contribution of resin 
%                           attenuation at each angle in params.theta; 
%                           each contribution is used as a multiplier
%                           modifying the backprojected intensity in
%                           exp_iradon()


% Preallocate 3D matrix for lookup table
att_table = single(zeros([domain_size,length(params.theta)]));
N = domain_size(1);

% Generate trignometric tables
costheta = cosd(params.theta);
sintheta = sind(params.theta);

% Define the x & y axes for the reconstructed image so that the origin
% (center) is in the spot which RADON would choose.
center = floor((N + 1)/2);
xleft = -center + 1;
x = (1:N) - 1 + xleft;
x = repmat(x, N, 1);

ytop = center - 1;
y = (N:-1:1).' - N + ytop;
y = repmat(y, 1, N);

% Circle that bounds the 
radius_bound = (x.^2 + y.^2 < params.radius^2);


for i = 1:length(params.theta)
    

    
    t = x.*costheta(i) + y.*sintheta(i);
    t_perp = -x.*sintheta(i) + y.*costheta(i); 
    
    w = real(-sqrt(params.radius^2 - x.^2)) - y;
    w(:,[1:size(x,1)/2-params.radius,size(x,1)/2+params.radius:end]) =  0;
    exp_decay = exp(w./(params.D_p));
    
    expProjContrib = interp2(x,y,exp_decay,t,t_perp,params.interp_method);
    


    
    expProjContribNN = reshape(expProjContrib,N,N);
    
    if exist('occlusion','var')
        occlusion_line = ones(N,N).*((x == 0) & (y >= 0));
        occlusion_line = imrotate(occlusion_line,params.theta(i),'nearest','crop');
        shadow = conv2(occlusion_line,occlusion,'same');
        figure(100); imagesc(shadow);
        expProjContribNN = expProjContribNN.*radius_bound.*~shadow;
    else
        expProjContribNN = expProjContribNN.*radius_bound;
    end
    
    
    
    att_table(:,:,i) = expProjContribNN;
    

%     figure(1)
%     imagesc(att_table(:,:,i))
%     axis square
end