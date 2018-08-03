% load ../simulation_slices_Re1000Ri012Pr1/bpe/bpe_Re1Ri012Pr1_sk01_01.mat
load ../slices/simulation_slices_Re1000Ri012Pr1/bpe.mat

b_total_domain=zeros(size(bpe.time));
b_total_slice=zeros(size(bpe.time));
b_mean_domain=zeros(size(bpe.time));
b_mean_slice=zeros(size(bpe.time));
b_mean_domain_pdf=zeros(size(bpe.time));
b_mean_slice_pdf=zeros(size(bpe.time));

% set value of lower buoyancy bound for integrals
int_lim_index=301;
int_lim_buoy=bpe.binval(int_lim_index);

% theoretical buoyancy between lower buoyancy bound and max buoyancy for
% initial hyperbolic tangent layer
z_lim_theor=atanh(int_lim_buoy);
if (isreal(z_lim_theor)==0)
    z_lim_theor=-sim_info.LZ/2; % if lower bound is complex, use -LZ/2
end
z_theor=linspace(z_lim_theor,sim_info.LZ/2,100);
b_theor_init=tanh(z_theor);
b_total_theor_init=trapz(z_theor,b_theor_init);

% now calculate buoyancy contained between lower buoyancy bound and max
% buoyancy from resorted buoyancy profile for whole domain
for i=1:length(bpe.time)
    b_total_domain(i)=...
        trapz(bpe.Z(int_lim_index:end,i),bpe.binval(int_lim_index:end));
end

% now calculate buoyancy contained between lower buoyancy bound and max
% buoyancy from resorted buoyancy profile for slice
for i=1:length(bpe.time)
    b_total_slice(i)=...
        trapz(bpe.Zslice(int_lim_index:end,i),bpe.binval(int_lim_index:end));
end

figure(1)
hold on
plot([bpe.time(1) bpe.time(end)],b_total_theor_init*[1 1],'k--',...
    'linewidth',1)
plot(bpe.time,b_total_domain,bpe.time,b_total_slice,'linewidth',1)
legend({'theoretical initial buoyancy from tanh profile',...
    'buoyancy from whole domain','buoyancy from slice'},'box','off')
xlabel('time'),ylabel('total buoyancy')

% mean buoyancies corresponding to the above
b_mean_theor_init=b_total_theor_init/(z_theor(end)-z_theor(1));
for i=1:length(bpe.time)
    b_mean_domain(i)=...
        trapz(bpe.Z(int_lim_index:end,i),bpe.binval(int_lim_index:end))...
        /(bpe.Z(end,i)-bpe.Z(int_lim_index,i));

    b_mean_slice(i)=...
        trapz(bpe.Zslice(int_lim_index:end,i),bpe.binval(int_lim_index:end))...
        /(bpe.Zslice(end,i)-bpe.Zslice(int_lim_index,i));
end

% alternately, can calculate mean buoyancies from buoyancy pdf
for i=1:length(bpe.time)
    b_mean_domain_pdf(i)=...
        trapz(bpe.binval(int_lim_index:end),...
        bpe.binval(int_lim_index:end).*bpe.buoypdf(int_lim_index:end,i))...
        /(trapz(bpe.binval(int_lim_index:end),bpe.buoypdf(int_lim_index:end,i)));
    
    b_mean_slice_pdf(i)=...
        trapz(bpe.binval(int_lim_index:end),...
        bpe.binval(int_lim_index:end).*bpe.buoypdfslice(int_lim_index:end,i))...
        /(trapz(bpe.binval(int_lim_index:end),bpe.buoypdfslice(int_lim_index:end,i)));
end

figure(2)
hold on
plot([bpe.time(1) bpe.time(end)],b_mean_theor_init*[1 1],'k--',...
    'linewidth',1)
plot(bpe.time,b_mean_domain,'-',bpe.time,b_mean_slice,'-',...
    bpe.time,b_mean_domain_pdf,':',bpe.time,b_mean_slice_pdf,':',...
    'linewidth',1)
legend({'theoretical initial buoyancy from tanh profile',...
    'buoyancy from whole domain','buoyancy from slice',...
    'buoyancy from whole domain (pdf)','buoyancy from slice (pdf)'},'box','off')
xlabel('time'),ylabel('mean buoyancy')