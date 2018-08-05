% This script shows how to load in 2D slices and make a movie of the simulation output
% Run after readmean.m

load slices_Re1Ri012Pr1_sk01_45
file.sim_info=sim_info;
file.coords=coords;
file.means=means;
file.slices=slices;

interpolate_eps_sampling;

trajectory=sample_along_trajectory(file,layer,samp);

if exist('trajectory_total','var')
    trajectory_total.t=[trajectory_total.t trajectory.t];
    trajectory_total.b=[trajectory_total.b trajectory.b];
    trajectory_total.x=[trajectory_total.x trajectory.traj.x];
    trajectory_total.z=[trajectory_total.z trajectory.traj.z];
else
    trajectory_total.t=trajectory.t;
    trajectory_total.b=trajectory.b;
    trajectory_total.x=trajectory.traj.x;
    trajectory_total.z=trajectory.traj.z;
end


%%
first_time=0;
nslices=length(file.coords.t);
load plotcolours_bluegreen;

for k=1:2:nslices
k
k_save=(k-1)/2+1;

subplot(3,1,[1 2])

A_th=file.slices.b(:,:,k);

hold on
pcolor(file.coords.x,file.coords.z,A_th'),shading interp
axis tight
ylim([-5 5])
colormap(plotcolours_bluegreen)
caxis([-1.25 1.25])

set(gcf,'color','white')
set(gcf,'position',[48 541 1000 700])
xlabel('x'); ylabel('z');
text(0.25,-4.5,['t=' num2str(round(file.coords.t(k)))],'color','white','fontsize',14);
set(gca,'layer','top')
box on
set(gca,'linewidth',2)
set(gca,'ticklength',[0 0])
set(gca,'fontsize',14)


scattersizevec=linspace(1,10,20);
if ((first_time)&&(k<100))
    scatter(trajectory_total.x(1:5:k-1),trajectory_total.z(1:5:k-1),...
        scattersizevec(end-length(trajectory_total.x(1:5:k-1))+1:end),'w','filled')
    plot(trajectory.traj.x(k),trajectory.traj.z(k),'wo','linewidth',3,...
        'markersize',5,'markerfacecolor','w')
else
    scatter(trajectory_total.x(end-nslices-100+k:5:end-nslices+k-1),...
        trajectory_total.z(end-nslices-100+k:5:end-nslices+k-1),...
        scattersizevec,'w','filled')
    plot(trajectory.traj.x(k),trajectory.traj.z(k),'wo','linewidth',2,...
        'markersize',5,'markerfacecolor','w')%,'color',[255 183 76]/255)
end


subplot(3,1,3)
plot(trajectory_total.t(1:end-nslices+k-1),...
    trajectory_total.b(1:end-nslices+k-1),'linewidth',1,...
    'color',[253 60 60]/255)
hold on
plot(trajectory_total.t(end-nslices+k),...
    trajectory_total.b(end-nslices+k),'o','linewidth',1,...
    'color',[253 60 60]/255,'markerfacecolor',[253 60 60]/255,...
    'markersize',4)

xlim([100 250])
ylim([-1 1])

set(gca,'linewidth',2)
box off
set(gca,'fontsize',14)
xlabel('t')
ylabel('B (sampled)')
set(gca,'ticklength',[0 0])

M(k_save)=getframe(gcf);
clf;

end


