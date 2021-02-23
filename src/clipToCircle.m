function clipped = clipToCircle(reconstruction)

[Y,X] = meshgrid(linspace(-1,1,size(reconstruction,1)),linspace(-1,1,size(reconstruction,2)));
R = sqrt(X.^2 + Y.^2);
if numel(size(reconstruction)) == 2
  
    clipped = reconstruction.*(R<=1);
    
else
    R = repmat(R,[1,1,size(reconstruction,3)]);
    clipped = reconstruction.*(R<=1);
end