occlusion = zeros(11,11);
occlusion(4:8,:) = 1;
occlusion(:,4:8) = 1;

domain = zeros(100,100);

domain(1:50,50) = 1;


% figure
% imagesc(shadow)

N = size(domain,1);
theta = 0:179;

% Generate trignometric tables
costheta = cosd(theta);
sintheta = sind(theta);

% Define the x & y axes for the reconstructed image so that the origin
% (center) is in the spot which RADON would choose.
center = floor((N + 1)/2);
xleft = -center + 1;
x = (1:N) - 1 + xleft;
x = repmat(x, N, 1);

ytop = center - 1;
y = (N:-1:1).' - N + ytop;
y = repmat(y, 1, N);

figure
for i = 1:length(theta)
    line = ones(size(domain)).*((y == 0) & (x <= 0));
    line = imrotate(line,theta(i),'nearest','crop');

    t = x.*costheta(i) + y.*sintheta(i);
    t_perp = -x.*sintheta(i) + y.*costheta(i); 
    
    shadow = conv2(line,occlusion,'same');

    imagesc(shadow>0)
    pause(0.1)
       
end