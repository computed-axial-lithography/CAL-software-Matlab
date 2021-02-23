clear all

T = load('thinker_slice.mat');
T = T.target(:,:,61);

angles = 0:179;
proj = radon(double(T),angles);


% Ramp filter
recon_ramp = iradon(proj,angles,'ram-lak',size(T,1));
recon_ramp = recon_ramp./max(recon_ramp,[],'all');

threshold = find_threshold(recon_ramp,T,sum(T(:)));
[dist_vec,C_ramp] = evalcontrast(T,recon_ramp,threshold);

% no filter
recon_none = iradon(proj,angles,'none',size(T,1));
recon_none = recon_none./max(recon_none,[],'all');

threshold = find_threshold(recon_none,T,sum(T(:)));
[~,C_none] = evalcontrast(T,recon_none,threshold);

% optimized
Z = load('opt_recon');
recon_opt = Z.optimized_reconstruction(:,:,61);
recon_opt = recon_opt./max(recon_opt,[],'all');
threshold = [0.2560]/max(recon_opt,[],'all');
% figure
% imagesc(recon_opt./max(recon_opt,[],'all'))
colorbar
[~,C_opt] = evalcontrast(T,recon_opt,threshold);


figure(2)
hold on
plot(dist_vec,C_none,'r',dist_vec,C_opt,'b','Linewidth',2)
plot(dist_vec,C_ramp,'k--')
ylim([0,1])
legend('No filter','Optimized','Ramp filtered')
hold off
pause(0.1)


function [dist_vec, vals_vec] = evalcontrast(T,recon,threshold)
    T = logical(T);
    T_boundary = edge(T);
    T_dist = bwdist(T_boundary);
    T_dist(T) = T_dist(T)*-1;

    
    dist_vec = min(T_dist,[],'all'):max(T_dist,[],'all');
    vals_vec = zeros(size(dist_vec));

    j=1;
    for i = dist_vec
        % find all pixels at curr dist
        [~,~, v] = find(T_dist == i);
        total = numel(v);

%         figure(3)
%         imagesc(T_dist == i)
%         
%         figure(4)
%         imagesc(recon.*(T_dist==i))

        % find pixels at curr dist above threshold
%         A = recon(T_dist == i) >= threshold;
%         val = sum(A)/total;
% %         
        A = recon(T_dist == i);
%         val = mean(A.^2);
        val = mean((recon(T_dist == i)-T(T_dist == i)).^2);

        % place val in vals
        vals_vec(j) = val;
        j = j + 1;
    end
%     vals_vec = vals_vec./max(T_dist,[],'all');
%     vals_vec = vals_vec./max(vals_vec,[],'all');
end

% [X,Y] = meshgrid(linspace(-size(T,1)/2,size(T,1)/2,size(T,1)),...
%     linspace(-size(T,2)/2,size(T,2)/2,size(T,2)));
% R = sqrt(X.^2 + Y.^2);
% 
% circleMask = logical(R.*(R<=size(T,1)/2));
% gelInds = find(circleMask & T==1);
% voidInds = find(circleMask & ~T);
% 
% smallestGelDose = min(recon(gelInds),[],'all');
% maxVoidDose = max(recon(voidInds),[],'all');
% voidDoses = recon(voidInds);
% nPixOverlap = sum(voidDoses>=smallestGelDose);
% PER = nPixOverlap/(length(gelInds)+length(voidInds))
%
% figure(10)
% hold on
% histogram(recon(voidInds)./max(recon(:)),linspace(0,1,100),'facecolor','r','facealpha',0.4)
% histogram(recon(gelInds)./max(recon(:)),linspace(0,1,100),'facecolor','b','facealpha',0.4)
% xlim([0,1])
% title('Dose distribution')
% xlabel('Normalized dose')
% ylabel('Frequency')
% legend('Void doses','Gel doses')



