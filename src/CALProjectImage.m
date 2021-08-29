function CALProjectImage(image)
    image = uint8(image);
    A = PTB();
    
    A = A.prepareImages(image);
    
    A.show();
    
    fprintf('\nProjecting image...                           (press esc to stop)\n')
    
    while 1
        if PTB.isKeyName(PTB.checkKey(),'ESCAPE')
            fprintf('\nStopped projection.\n')
            break
        end
    end
    sca;
    
    
    
end

