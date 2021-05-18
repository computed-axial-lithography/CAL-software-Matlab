function flag = testAstra()
    try
        [~] = astra_create_proj_geom('parallel3d', 1, 1, 2, 2, [0,pi]);
        flag = 1;
    catch
        warning('Astra not working properly or CUDA GPU not present or enabled! To test Astra installation, use astra_test(). To test GPU in Matlab, use gpuDevice().');
        flag = 0;
    end
    
end