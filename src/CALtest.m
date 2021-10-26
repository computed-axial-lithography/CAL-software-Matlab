%{ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Copyright (C) 2020-2021  Hayden Taylor Lab, University of California, Berkeley
Website https://github.com/computed-axial-lithography/CAL-software-Matlab

This file is part of the CAL-software-Matlab toolbox.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%} 
function CALtest()

    fprintf('\nCAL-software-Matlab Toolbox installed successfully!\n\n');
    
    try
        if astra_mex('use_cuda')
            astra_test_CUDA;
        else
            fprintf('No GPU support available. Non-parallel  projector geometries not usable.\n');
        end
    catch
        fprintf('Astra toolbox is not installed or is improperly installed. Refer to https://cal-software-matlab.readthedocs.io/en/latest/sec_setup.html for instructions to install Astra manually.\n');
    end
    
    try
        ver_str = PsychtoolboxVersion;
        if str2num(ver_str(1)) < 3
            warning('Pyschtoolbox version 3 is required. The installed version is %s. Go to the Pyschtoolbox website to install version 3 or greater [http://psychtoolbox.org/download].\n',ver_str);
        end
    catch
        warning('Pyschtoolbox is not installed or is improperly installed. Install Pyschtoolbox [http://psychtoolbox.org/download] to enable the image set projection functionality of the toolbox.\n');
    end
    



    
end