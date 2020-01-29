occlusion = zeros(21,21);
occlusion(4:18,:) = 1;
occlusion(:,4:18) = 1;



params.theta = 0:359;
params.interp_method = 'linear';
params.radius = 150;
params.D_p = inf;

domain_size = [300,300];

att_table = gen_att_table(params,domain_size,occlusion);


target = zeros(300,300);
target(50:250,[100:130,170:200]) = 1;
target(100:200,100:200) = 1;

% target = phantom(300); target = (target~=0).*(target>=0.1);
% target(120:180,120:180) = 0;

figure; imagesc(target);
proj = radon(target,params.theta);
filt_proj = filter_projections(proj,'ram-lak',1);
% filt_proj = filt_proj + abs(min(filt_proj));
filt_proj = filt_proj.*(filt_proj>=0);
figure; imagesc(filt_proj)

recon = exp_iradon(params,filt_proj,att_table,domain_size);
%%
figure; imagesc(recon./max(recon,[],'all')); colormap jet


