theta = 0:1:179;
target = zeros(300,300);
target(50:250,[100:130,170:200]) = 1;
% target = phantom(300);
proj = radon(target,theta);



[filt_proj,h] = filter_projections(proj,'hamming',1);
filt_proj = filt_proj + abs(min(filt_proj)); %(filt_proj>=0);
recon = iradon(filt_proj,theta,'linear','none',size(target,1));

figure(1)
plot(h)

figure(2)
imagesc(filt_proj)
colorbar

figure(3)
imagesc(recon)
caxis([0, max(recon,[],'all')])
colorbar


avg_target = mean(recon(logical(target)),'all');
avg_background = mean(recon(~target),'all');
contrast = (avg_target-avg_background)/(avg_target+avg_background)