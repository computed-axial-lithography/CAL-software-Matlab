function CALtest()

    fprintf('\nCAL-software-Matlab Toolbox installed successfully!\n\n');
    
    try
        ver_str = PsychtoolboxVersion;
        if str2num(ver_str(1)) < 3
            warning('Pyschtoolbox version 3 is required. The installed version is %s. Go to the Pyschtoolbox website to install version 3 or greater [http://psychtoolbox.org/download].',ver_str);
        end
    catch
        warning('Pyschtoolbox is not installed or is improperly installed. Install Pyschtoolbox [http://psychtoolbox.org/download] to enable the image set projection functionality of the toolbox.');
    end


    
end