% This script plots a timeseries of the sampled buoyancy profiles

for i=31:45

slicefilename=['slices_Re1Ri012Pr1_sk01_' num2str(i)];
%load slices_Re1Ri012Pr1_sk01_14
load(slicefilename);
file.sim_info=sim_info;
file.coords=coords;
file.means=means;
file.slices=slices;

interpolate_eps_sampling;

trajectory=sample_along_trajectory_timeseries(file,layer,samp);

load plotcolours_highgradient

%%
nslices=length(coords.t);
profile=zeros(length(coords.z),nslices);
for k=1:nslices
    k
    
    profile(:,k)=interp1(coords.x,file.slices.b(:,:,k),trajectory.traj.x(k));
end

if exist('profile_total','var')
    profile_total.t=[profile_total.t trajectory.t];
    profile_total.b=[profile_total.b trajectory.b];
    profile_total.x=[profile_total.x trajectory.traj.x];
    profile_total.z=[profile_total.z trajectory.traj.z];
    profile_total.profile=[profile_total.profile profile];
else
    profile_total.t=trajectory.t;
    profile_total.b=trajectory.b;
    profile_total.x=trajectory.traj.x;
    profile_total.z=trajectory.traj.z;
    profile_total.profile=profile;
end

end

subplot(2,1,1)
pcolor(profile_total.t,coords.z,profile_total.profile),shading interp
colormap(plotcolours_SVG_Lindaa07)
hold on
plot(profile_total.t,profile_total.z,'w','linewidth',1)
contour(profile_total.t,coords.z,profile_total.profile,[-0.021 0.021],'r','linewidth',1)
xlabel('t'),ylabel('physical z')
ylim([-5 5])
subplot(2,1,2)
plot(profile_total.t,profile_total.b,'color',...
    plotcolours_SVG_Lindaa07(1,:),'linewidth',1)
axis tight
ylim([-1 1])
xlabel('t'),ylabel('sampled b')

