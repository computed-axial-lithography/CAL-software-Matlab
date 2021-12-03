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