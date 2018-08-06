load slices_Re1Ri012Pr1_sk01_1;

first.sim_info=sim_info
first.coords=coords

% dimensional parameters
layer.nu = 8e-4;
layer.kappa = layer.nu/first.sim_info.Pr;
% 2h* (m)
layer.width = 10;
% 2u* (m/s) velocity jump
layer.vjmp = 2 * first.sim_info.Re * layer.nu / (layer.width/2);
% 2B* buoyancy jump
layer.Bjmp = first.sim_info.Ri * (layer.vjmp/2)^2 / (layer.width/2);
layer.timescale = layer.width/layer.vjmp;
layer

% sampling parameters
samp.pump_z = 0.75/(layer.width/2); % (m) pumping *vertical amplitude*
samp.pump_period = 10/layer.timescale; % (s) pumping frequency
samp.uback = 0.25/(layer.vjmp/2); % (m/s) background flow that advects
                                  % the shear layer past the chipod
samp.t0 = first.coords.t(1); % save start of trajectory so that I can be
                             % at the right x-position when processing
                             % files in parallel
                         
