%{
Function to find the optimal value that scales the input projections to produce power
distribution that maximizes the total output power, so that print time can
be reduced

INPUT:
    projections     =   matrix, for 2D target projections size is nR x nTheta; 
                        for 3D target projections size is nR x nTheta x nZ

OUTPUT:
    projPower       =   matrix, projections mapped to the calibration curve of real
                        intensities of the projector
    scale           =   scalar, value of the scaling factor used

Created by: Indrasen 2017-06-13
Modified by: Joseph Toombs 08/2019

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

function [projections_power,scale] = find_scale(projections)
   
[Values, Edges] = histcounts(projections(:)); % bins the projections into 
Edges = Edges(1:end-1);

%This is somewhat empirical: trying to obtain a good way to scale
%Another option would be to attempt histogram equalization
%or any alternate form of light training
vMax = mean(Edges(Edges.*Values == max(Edges.*Values)));
scale = 100/vMax;

proj_actual = uint8(projections*scale)+1; % changes data type to 8-bit values with range of 1-256 for projection
projections_power = projectorMap(proj_actual); % maps projActual to the calibration curve of the projector


% Linear interpolation of projection intensities into projector intensity
% calibration curve 'intensity_sorted.mat' for Wintech LC4500 projector
function y = projectorMap(x)
    load('intensity_sorted.mat','intensity_sorted');  
    maxInt = max(intensity_sorted);
    y = 255*(intensity_sorted(x)-min(intensity_sorted))/maxInt;
end
end
