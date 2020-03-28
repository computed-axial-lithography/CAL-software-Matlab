%{
Function to simulate the printing process by 

INPUT:


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

initiator_conc_0        = 8e-3;         % mol/L
quantum_efficiency      = 0.5;
oxygen_conc_0           = 1e-3;        % mol/L

monomer_density         = 1.12;         % g/mol
monomer_MW              = 575;          % g/mol
monomer_conc_0          = monomer_density*1000/monomer_MW;
molar_abs               = 30;           % L/(mol*cm)
avagadro                = 6.022e23;     % mol^-1
planck                  = 6.626e-34;    % J*s
light_wavelength        = 405e-9;       % m
light_speed             = 3e8;          % m/s
light_freq              = light_speed/light_wavelength;



% Preallocate 3D matrices for tracking concentrations of radical, oxygen,
% monomer, and polymer

% Kelly (2016)
intensity_absorbed   = zeros(params.domain_size,'single');
initiator_conc       = initiator_conc_0*ones(params.domain_size,'single');
radical_conc         = zeros(params.domain_size,'single');
oxygen_conc          = oxygen_conc_0*ones(params.domain_size,'single');
P_0_conc             = monomer_conc_0*ones(params.domain_size,'single');
P_0_conc_t0          = monomer_conc_0*ones(params.domain_size,'single');
P_1_conc             = zeros(params.domain_size,'single');
P_2_conc             = zeros(params.domain_size,'single');
P_3_conc             = zeros(params.domain_size,'single');
DOC                  = zeros(params.domain_size,'single');

k_I = 4.8e-5;          % L/(mol*s)
k_T = 1e7;          % L/(mol*s)
k_T_oxy = 5e8;      % L/(mol*s)
k_P = 1e3;          % L/(mol*s)




% Dendukuri (2008)
% intensity_absorbed   = zeros(params.domain_size,'single');
% initiator_conc       = initiator_conc_0*ones(params.domain_size,'single');
% radical_conc         = zeros(params.domain_size,'single');
% oxygen_conc          = oxygen_conc_0*ones(params.domain_size,'single');
% radical_monomer_conc = zeros(params.domain_size,'single');
% initial_monomer_conc = monomer_conc_0*ones(params.domain_size,'single');
% monomer_conc         = monomer_conc_0*ones(params.domain_size,'single');
% unconv_bond_conc     = monomer_conc_0*ones(params.domain_size,'single');
% X_conc               = zeros(params.domain_size,'single');
% polymer_conc         = zeros(params.domain_size,'single');
% DOC         = zeros(params.domain_size,'single');
% 
% k_T = 2.52e6;          % L/(mol*s)
% k_T_oxy = 5e8;      % L/(mol*s)
% k_P = 25e3;          % L/(mol*s)
% 









% time step, right now just calculated as time between angles at the set
% rot. velocity; this seems too big because the simulation is going
% unstable quickly
dt = 12/length(params.angles); 
t = 0;

slice_layer = 30; % slice layer for viewing cross section of volume

projections = projections./max(projections,[],'all');

for i = 1:length(params.angles)
    for z = 1:size(intensity_absorbed,3)
        intensity_absorbed(:,:,z) = max_projector_intensity*exp_iradon(params,projections(:,:,z),i).^(molar_abs*initiator_conc(:,:,z));
    end

    
%     % Kelly (2016) Computationally efficient modeling of pattern dependences in the free-radical photopolymerization of hydrogel microstructures
%     % Easier to understand: Taki (2014) Effect of Oxygen Inhibition on the Kinetic Constants of the UV- Radical Photopolymerization of Diurethane Dimethacrylate/ Photoinitiator Systems
    initiator_conc = initiator_conc + dt*(-quantum_efficiency.*molar_abs.*initiator_conc.*(intensity_absorbed./(avagadro*planck*light_freq)));
    radical_conc = radical_conc + 2*dt*(quantum_efficiency.*molar_abs.*initiator_conc.*(intensity_absorbed./(avagadro*planck*light_freq)));
    P_0_conc = P_0_conc + dt*(-k_I.*P_0_conc.*radical_conc - k_P.*P_0_conc.*P_1_conc);
    P_1_conc = P_1_conc + dt*(k_I.*P_0_conc.*radical_conc - k_T.*P_1_conc.^2 - k_T_oxy.*P_1_conc.*oxygen_conc);
    P_2_conc = P_2_conc + dt*(k_P.*P_1_conc.*P_0_conc + k_T.*P_1_conc.^2);
%     P_3_conc = P_3_conc + dt*(k_T_oxy.*P_1_conc.*oxygen_conc);
    oxygen_conc = oxygen_conc + dt*(-k_T_oxy.*P_1_conc.*oxygen_conc);
    DOC = P_2_conc./monomer_conc_0;
    
    figure(11)
    subplot(2,2,1)
    imagesc(intensity_absorbed(:,:,slice_layer))
    colorbar
    colormap('hot')
%     caxis([0,1])
    axis off
    
    subplot(2,2,2)
    imagesc(radical_conc(:,:,slice_layer))
    colorbar
    colormap('hot')
    axis off
    
    subplot(2,2,3)
    imagesc(P_0_conc(:,:,slice_layer))
    colorbar
    colormap('hot')
    axis off

    subplot(2,2,4)
    imagesc(DOC(:,:,slice_layer))
    colorbar
    colormap('hot')
    caxis([0,1])
    axis off    


%     % Dendukuri (2008) Modeling of Oxygen-Inhibited Free Radical Photopolymerization in a PDMS Microfluidic Device
%     initiator_conc = initiator_conc + dt*(-quantum_efficiency.*molar_abs.*initiator_conc.*(intensity_absorbed./(avagadro*planck*light_freq)));
%     X_conc = (-k_T_oxy.*oxygen_conc + sqrt( (k_T_oxy.*oxygen_conc).^2 + 4*k_T.*(quantum_efficiency.*molar_abs.*initiator_conc.*intensity_absorbed./(avagadro*planck*light_freq)) ))/(2*k_T);
%     oxygen_conc = oxygen_conc + dt*(-k_T_oxy.*oxygen_conc.*X_conc);
%     unconv_bond_conc = unconv_bond_conc + dt*(-k_P*unconv_bond_conc.*X_conc);
%     
%     DOC = 1 - unconv_bond_conc./monomer_conc_0;
%     
%     figure(11)
%     subplot(2,1,1)
%     imagesc(initiator_conc(:,:,30))
%     colorbar
%     colormap(jet(256))
% %     caxis([0,1])
%     axis off
%     subplot(2,1,2)
%     plot(1-DOC(238/2,:,30))

%     figure(10)
%     h = volshow(1-DOC,'Renderer','MaximumIntensityProjection','Colormap',jet(256),'Alphamap',interp1([0 0.1 0.2 1],[0 0 0.5 1],linspace(0,1,256))','BackgroundColor','w');




%     R_i = quantum_efficiency.*molar_abs.*initiator_conc.*intensity_absorbed./(avagadro*planck*light_freq);
%     DOC = 1 - exp((-k_T_oxy.*oxygen_conc + sqrt( (k_T_oxy.*oxygen_conc).^2 + 4*k_T.*R_i ))/(2*k_T) * t);
% 
%     t = t + dt;
%     figure(11)
%     imagesc(DOC(:,:,30))
%     colorbar
%     colormap(jet(256))
%     caxis([0,1])



    
%     figure(10)
%     h = volshow(DOC,'Renderer','MaximumIntensityProjection','Colormap',jet(256),'Alphamap',interp1([0 0.1 0.2 1],[0 0 0.5 1],linspace(0,1,256))','BackgroundColor','w');



%     DOC = 1 - exp(-k_P/k_T^0.5*(quantum_efficiency*intensity).^0.5*t);
%     radical_conc = radical_conc + 2*dt*(molar_abs/(avagadro*planck*light_freq)).*initiator_conc.*intensity;
    
%     monomer_conc = monomer_conc - (k_P/k_T^0.5*(quantum_efficiency*intensity).^0.5);
%     polymer_conc = polymer_conc + dt*(k_P*radical_monomer_conc.*monomer_conc + k_T*radical_monomer_conc.^2);

%     radical_monomer_conc = radical_monomer_conc - dt*(k_I*radical_conc.*monomer_conc - k_T*radical_monomer_conc.^2 - k_T_oxy.*radical_monomer_conc.*oxygen_conc);

%     monomer_conc = monomer_conc + dt*(-k_P/k_T^0.5.*monomer_conc.*(quantum_efficiency.*molar_abs.*initiator_conc.*(intensity_absorbed./(avagadro*planck*light_freq))).^0.5);
%     DOC = monomer_conc./initial_monomer_conc;


    
    
    
    

    
%     figure(10)
%     volshow(radical_conc./max(radical_conc,[],'all'),'Renderer','VolumeRendering');
%     pause(0.1)
    
end    



end

    