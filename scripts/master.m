addpath(genpath('./'))

simdir = '../simulation_slices_Re1000Ri012Pr1/';

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
samp.name = '01'; % unique name for particular subsample
samp.pump_z = 0.75/(layer.width/2); % (m) pumping *vertical amplitude*
samp.pump_period = 10/layer.timescale; % (s) pumping frequency
samp.uback = 0.25/(layer.vjmp/2); % (m/s) background flow that advects
                                  % the shear layer past the chipod

% actually process
process_output(simdir, layer, samp);