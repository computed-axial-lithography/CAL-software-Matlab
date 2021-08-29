function [fills,fill_inds] = getFills(target)

    figure(100);
    imagesc(target);
    colormap('gray')
    title('Select fill locations, then press enter')
    axis('off')
    daspect([1,1,1]);
    
    [x,y] = getpts;
    close(figure(100));
    
    x = round(x);
    y = round(y);
    fill_inds = [y,x];
    
    filled_target = imfill(logical(target),fill_inds);

    fills = xor(logical(target),filled_target);

end