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
function filepath = loadExStlFilename(type)
    filepath = fullfile(mfilename('fullpath'));
    filepath = erase(filepath,'loadExStlFilename');  
    filepath = fullfile(filepath,'Examples');
    if strcmp(type,'bear')
        filepath = fullfile(filepath,'bear.stl');
    elseif strcmp(type,'thinker')
        filepath = fullfile(filepath,'thinker.stl');
    elseif strcmp(type,'octet')
        filepath = fullfile(filepath,'octet.stl');
    elseif strcmp(type,'octahedron')
        filepath = fullfile(filepath,'octahedron.stl');
    end
end
