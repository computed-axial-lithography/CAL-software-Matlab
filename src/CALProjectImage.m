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

