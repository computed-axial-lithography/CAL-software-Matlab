%{
Function that displays cumulative dose in slices

INPUTS:
    cumulative_dose =   matrix, if 3D (nR x nTheta x nZ) the display will be
                        sequential; if 2D (nR x nTheta) the display will be in sinogram form
    intensity_range =   vector, [LOW HIGH] brightness values of dose profile images

OUTPUTS:
  none

Created by: Joseph Toombs 09/2019

----------------------------------------------------------------------------
Copyright © 2017-2020. The Regents of the University of California, Berkeley. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in
   the documentation and/or other materials provided with the distribution.
3. Neither the name of the University of California, Berkeley nor the names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ''AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS 
BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.
%}

function show_dose_slices(cumulative_dose,intensity_range,figure_number,title_string)

if ~exist('intensity_range','var') || isempty(intensity_range)
  	intensity_range = NaN;
end

if ~exist('figure_number','var') || isempty(figure_number)
  	figure_number = NaN;
end

if ~exist('title_string','var') || isempty(title_string)
  	title_string = NaN;
end

% add path containing files for inferno colormap
addpath('colormaps_bin');
addpath('imshow_3D_bin');

pause(0.5)


if numel(size(cumulative_dose)) == 2
    if ~isnan(figure_number)
        figure(figure_number)
    else
        figure
    end
    cumulative_dose = clip_to_circle(cumulative_dose);
    imagesc(cumulative_dose)
    colormap(CMRmap())
    daspect([1 1 1])
    colorbar
    caxis(intensity_range)
    title(title_string)
    pause(0.02);
else
    
    if isnan(intensity_range)
      
        if ~isnan(figure_number)
            figure(figure_number)
        else
            figure
        end
        colormap(CMRmap())
        if isnan(title_string)
            imshow3D(cumulative_dose,[],1);
        else
            imshow3D(cumulative_dose,[],1,title_string);
        end 
    else
        
        if ~isnan(figure_number)
            figure(figure_number)
        else
            figure
        end
        colormap(CMRmap())
        
        if isnan(title_string)
            imshow3D(cumulative_dose,intensity_range,1);
        else
            imshow3D(cumulative_dose,intensity_range,1,title_string);
        end        
        
    end

end