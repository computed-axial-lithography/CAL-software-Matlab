function logfile = create_log(params,path,run_time)

addpath('struct2str_bin')

params_str = struct2str(params);


fileID = fopen('logfile.txt','w');
fmt = '%s: %5d\n';
fprintf(fileID,fmt, );
fclose(fileID);

