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
function target = createTarget(n_pixels,type,dim)


if strcmp(type,'phantom')
    target = phantom(n_pixels);
    target = double(target > 0.001);
elseif strcmp(type,'star')
    target = siemens_star(n_pixels,8,6);
    target = double(target);
    
elseif strcmp(type,'L')
    target = zeros(n_pixels,n_pixels);
    target(n_pixels/4:3/4*n_pixels,n_pixels/4:3/4*n_pixels) = 1;
    target(n_pixels/4:2*n_pixels/3,n_pixels/4:2*n_pixels/3) = 0;
    target(n_pixels/4:0.5827*n_pixels,n_pixels/4:0.5827*n_pixels) = 1;
    target(n_pixels/4:n_pixels/2,n_pixels/4:n_pixels/2) = 0;
    target(n_pixels/4:0.416*n_pixels,n_pixels/4:0.416*n_pixels) = 1;
    
elseif strcmp(type,'tube')
    target = zeros(n_pixels,n_pixels);
    [X,Y] = meshgrid(linspace(-1,1,n_pixels),linspace(-1,1,n_pixels));
    
    R = sqrt(Y.^2 + X.^2);

    target(R<=2/3) = 1;
    target(R<=1/3) = 0;

elseif strcmp(type,'channels')
    target = zeros(n_pixels,n_pixels);
    [X,Y] = meshgrid(linspace(-1,1,n_pixels),linspace(-1,1,n_pixels));
    
    R = sqrt(Y.^2 + X.^2);
    R1 = sqrt(Y.^2 + (X+1/3).^2);
    R2 = sqrt(Y.^2 + (X-1/3).^2);
    target(R<=2/3) = 1;
    target(R1<=1/6) = 0;
    target(R2<=1/6) = 0;

elseif strcmp(type,'dots')
    target = zeros(n_pixels,n_pixels);
    
    [columns, rows]= meshgrid(1:n_pixels, 1:n_pixels);
    
    
    centerX = [0,n_pixels/6,2*n_pixels/6,n_pixels/6,2*n_pixels/6,0                  ,0           ] + n_pixels/2;
    centerY = [0,0         ,0           ,n_pixels/6,2*n_pixels/6,n_pixels/6         ,2*n_pixels/6] + n_pixels/2;
    for ii = 1:length(centerX)
        center__X = centerX(ii);
        center__Y = centerY(ii);

        radius = 5;
        circlePixels = (rows - center__Y).^2 ...
            + (columns - center__X).^2 <= radius.^2;
        target = target + double(circlePixels);
    end
end

if dim == 3
    target = repmat(target,[1,1,50]);
end

end



function im = siemens_star(N, w, rings)
    % im_mire_radiale - Generates a radial stripe
    %
    %   SYNTAXE
    %   im = im_radial_stripe(N, w);
    %
    %   INPUTS
    %   'N' 	- size of the square image
    %   'w' 	- number of branches
    %
    %   OUTPUT
    %   'im'    - generated image 
    %
    % July 2018 - Olivier Lévêque <olivier.leveque@institutoptique.fr>
    
    li = linspace(-1,1,N);
    [X,Y] = meshgrid(li);
    [th,rad] = cart2pol(X,Y);
    I = 1+sin(w*th);
    I = double((I>1)&(rad<0.9));
    
    for ii = 1:rings
        radius = 0.9*ii*1/(rings);
        I(rad>(radius - 0.01) & rad<(radius + 0.01)) = 1;
    end
   
    im = I;

end
