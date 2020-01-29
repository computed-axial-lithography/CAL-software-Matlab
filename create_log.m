function logfile = create_log(params,save_path,dir_name,run_time)

addpath('struct2str_bin')



% Setup logfile directory with currentPath\save_path\dir_name\logfile.txt
f = sprintf('logfile.txt');
filename = fullfile(save_path,dir_name);
mkdir(filename)
filename = fullfile(save_path,dir_name,f);


% Convert parameters struct to strings for text file
params_str = struct2str(params);


% Create runtime string
run_time_str = sprintf('Runtime = %4.0d seconds\n',run_time);


% Print to logfile.txt
fileID = fopen(filename,'w');
fprintf(fileID, params_str);
fprintf(fileID,run_time_str);
fclose(fileID);

