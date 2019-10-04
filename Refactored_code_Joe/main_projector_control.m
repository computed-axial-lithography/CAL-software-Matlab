
%% Options
params.f = 5;            % XY scaling factor
params.invert_vertical = 0;
params.invert_horizontal = 0;
params.ht_offset = 0;
params.wd_offset = 0;
params.I_f = 1;          % intensity scaling factor
params.verbose = 1;

%% input parameters
params.wd_screen = 2716;
params.ht_screen = 1528;

params.rot_velocity = 3; %degrees/s
params.max_angle = 360; %deg
params.delay_start = 10;
params.delay_end = 30;
params.n_rotations = 100000;

projector_control(params,optimized_projections)

