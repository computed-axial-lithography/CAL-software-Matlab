function att_table = gen_att_table(params,domain_size)

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


radius_bound = (x.^2 + y.^2 < params.radius^2);

for i = 1:length(params.theta)
    t = x.*costheta(i) + y.*sintheta(i);
    t_perp = -x.*sintheta(i) + y.*costheta(i);
    
    w = real(-sqrt(params.radius^2 - x.^2)) - y;
    w(:,[1:size(x,1)/2-params.radius,size(x,1)/2+params.radius:end]) =  0;
    exp_decay = exp(w./(params.D_p));
    
    
    expProjContrib = interp2(x,y,exp_decay,t,t_perp,params.interp_method);
%     expProjContrib(isnan(expProjContrib)) = 0;
%     expProjContrib(expProjContrib >1) = 0;

    expProjContribNN = reshape(expProjContrib,N,N);
    expProjContribNN = expProjContribNN.*radius_bound;
    
    att_table(:,:,i) = expProjContribNN;
end