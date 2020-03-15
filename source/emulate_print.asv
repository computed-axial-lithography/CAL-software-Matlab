%{
Function to simulate the printing process by 

INPUT:
  projections = matrix, 2D or 3D matrix of the optimized projection matrix 
    2D (nR x nTheta) or 3D (nR x nTheta x nZ)
  num_thresholds = scalar, # of threshold values to simulate; this is
    analgous to the number of time steps to take in the simulation

OUTPUT:
  none


Created by: Indrasen Bhattacharya 2017-05-07
Modified by: Joseph Toombs 08/2019

----------------------------------------------------------------------------
Copyright © 2017-2019. The Regents of the University of California, Berkeley. All rights reserved.

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
function emulate_print(params,projections)


max_projector_intensity = 10;           % mW/cm^2

initiator_conc_0        = 4e-3;         % mol/L
quantum_efficiency      = 0.5;
oxygen_conc_0           = 10e-3;        % mol/L

monomer_density         = 1.12;         % g/mol
monomer_MW              = 575;          % g/mol
monomer_conc_0          = monomer_density*1000/monomer_MW;
molar_abs               = 30;           % m^2/mol    NOTE: if in L/(mol*cm) multiply by 0.1
avagadro                = 6.022e23;     % mol^-1
planck                  = 6.626e-34;    % J*s
light_wavelength        = 405e-9;       % m
light_speed             = 3e8;          % m/s
light_freq              = light_speed/light_wavelength;



% Preallocate 3D matrices for tracking concentrations of radical, oxygen,
% monomer, and polymer
intensity            = zeros(params.domain_size,'single');
initiator_conc       = initiator_conc_0*ones(params.domain_size,'single');
radical_conc         = zeros(params.domain_size,'single');
oxygen_conc          = oxygen_conc_0*ones(params.domain_size,'single');
radial_monomer_conc  = zeros(params.domain_size,'single');
monomer_conc         = monomer_conc_0*ones(params.domain_size,'single');
polymer_conc         = zeros(params.domain_size,'single');


% k_I = 
k_T = 1e7;          % L/(mol*s)
k_T_oxy = 5e8;      % L/(mol*s)
k_P = 1e3;          % L/(mol*s)

dt = 12/length(params.angles);

projections = projections./max(projections,[],'all');

for i = 1:length(params.angles)
    for z = 1:size(intensity,3)
        intensity(:,:,z) = max_projector_intensity*exp_iradon(params,projections(:,:,z),i);
    end
 
%     DOC = 1 - exp(-k_P/k_T^0.5*(quantum_efficiency*intensity).^0.5*t);
%     radical_conc = radical_conc + 2*dt*(molar_abs/(avagadro*planck*light_freq)).*initiator_conc.*intensity;
    
%     monomer_conc = monomer_conc - (k_P/k_T^0.5*(quantum_efficiency*intensity).^0.5);
%     polymer_conc = polymer_conc + dt*(k_P*radical_monomer_conc.*monomer_conc + k_T*radical_monomer_conc.^2);

%     radical_monomer_conc = radical_monomer_conc - dt*(k_I*radical_conc.*monomer_conc - k_T*radical_monomer_conc.^2 - k_T_oxy.*radical_monomer_conc.*oxygen_conc);
%     oxygen_conc = oxygen_conc - dt*(k_T_oxy*radical_monomer_conc.*oxygen_conc);
  



    initiator_conc = initiator_conc - dt*(molar_abs*quantum_efficiency.*(intensity./(avagadro*planck*light_freq)).*initiator_conc);        % (1) G. Miller Modeling of photobleaching for the photoinitiation of thick polymerization systems 2001
    radical_conc = radical_conc + dt*(molar_abs*quantum_efficiency.*(intensity./(avagadro*planck*light_freq)).*initiator_conc);            % (2) G. Miller Modeling of photobleaching for the photoinitiation of thick polymerization systems 2001

    
    DOC = polymer_conc/monomer_conc_0*ones(params.domain_size,'single');
    
    
    figure(11)
    subplot(2,2,1)
    imagesc(intensity(:,:,40))
    colorbar
    axis off
    subplot(2,2,3)
    imagesc(initiator_conc(:,:,40))
    colorbar
    axis off
    subplot(2,2,4)
    imagesc(radical_conc(:,:,40))
    colorbar
    axis off
    
%     figure(10)
%     volshow(radical_conc./max(radical_conc,[],'all'),'Renderer','VolumeRendering');
%     pause(0.1)
    
end    












% if length(size(projections)) == 3
%     for z=1:size(cumulative_dose,3)
%         cumulative_dose(:,:,z) = exp_iradon(params,projections(:,:,z));
%     end
% 
%     volumeViewer(cumulative_dose)
%     
% elseif length(size(projections)) == 2
%     cumulative_dose = exp_iradon(params,projections);
% end




















% 
% if length(size(projections)) == 3
%     thresholds = linspace(max(max(max(cumulative_dose))),min(min(min(cumulative_dose))),num_thresholds);
%     
%     dummy_space = ones(nR,nR,nZ);
%     dummy_space(1:round(nR/2),1:round(nR/2),:) = 0;
%     cross_section_mask = repmat(dummy_space(:),[1,3]);
%     
%     colors = jet;
%     colors_threshold = interp1(linspace(0,1,length(colors)),colors,linspace(0,1,num_thresholds));
%     colors_matrix = zeros([nR*nR*nZ,3],'single');
%     figure
%     for threshold_i = 1:num_thresholds
%         [num_voxels,coordinates] = get_voxel_count(cumulative_dose,thresholds(threshold_i));
%         curr_coordinates = any(coordinates,2);
% 
%         if threshold_i == 1
% 
%             colors_matrix(curr_coordinates,:) = repmat(colors_threshold(threshold_i,:),[num_voxels,1]);
%             pcshow(coordinates.*cross_section_mask,colors_matrix);
%             prev_coordinates = curr_coordinates;
%             prev_num_voxels = num_voxels;
% 
%         else     
%             curr_num_voxels = num_voxels - prev_num_voxels;
%             curr_coordinates(curr_coordinates&prev_coordinates) = 0;
%             colors_matrix(curr_coordinates,:) = repmat(colors_threshold(threshold_i,:),[curr_num_voxels,1]);
%             pcshow(coordinates.*cross_section_mask,colors_matrix);
%             prev_coordinates = coordinates;       
%             prev_num_voxels = num_voxels;
%         end
% 
%         title(sprintf('Dose (a.u.) = %d',threshold_i));
%         axis equal tight;
%         xlim([0 nR])
%         ylim([0 nR])
%         zlim([0 nZ])
%         colormap jet;
%         pause(0.02);
%     end
% end

end

    