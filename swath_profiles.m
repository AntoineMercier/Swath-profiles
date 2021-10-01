clear all, close all, clc

%%%%%%%%%%%%%%%%%% REQUIREMENTS %%%%%%%%%%%%%%%%%%%
% * TopoToolBox
% * Image Processing Toolbox
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%~~~~~~~~~~~~~~~ PARAMETERS ~~~~~~~~~~~~~~~~~~~~~~
in_dem = 'gebco_2020_n0.0_s-90.0_w-90.0_e0.0.tif'; % Input DEM
res = 686;                     % Resolution in meter of the input DEM
proj = 0 ;                    % Set 1 if dem is formated in projected coordinates (in meters) ; 0 if dem is lat/lon 
cell = 2000 ;                  % Cell size for resampling (in meter) ; if 0 no resampling needed         
swathwidth = 50000 ;           % Swath profile width in meter 
nprofiles = 2 ;                 % How many profiles do you need
ToScale = 0 ;                   % Set 1 if you want the plots to be at 1:1 scale, 0 if not
SaveProfile = 0 ;                % Set 1 if you want to save the profiles in a text file, 0 if not
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% PROJECTION IN METERS
DEM = GRIDobj(in_dem);
if proj == 0
    DEM = reproject2utm(DEM,res);
end

%% RESAMPLE DEM TO LOWER RESOLUTION
if cell ~= 0
    DEM = resample(DEM,cell);
end
info(DEM)

%% DEFINE SWATH PROFILE
close all
figure(1)
imageschs(DEM,DEM,'colorbar',true);
box on
title('DEM')
xlabel('X - Easting (in m)')
ylabel('Y - Northing (in m)')      
c = colorbar;               
c.Label
c.Label.String = 'Elevation (in m)';
x = [];
y = [];
for i = 1:nprofiles
    [x(i,:),y(i,:)]= ginput;
    hold on 
    plot(x(i,:),y(i,:),'w-','linewidth',2)
end


%% PLOT SWAHT PROFILE 

for i = 1:nprofiles
sw1 = SWATHobj(DEM,x(i,:),y(i,:),'width',swathwidth);
z_min = min(sw1.Z,[],1)'*10^-3;
z_max = max(sw1.Z,[],1)'*10^-3;
z_mean = mean(sw1.Z,1)'*10^-3;
z_std = std(sw1.Z,0,1)'*10^-3;
dist = sw1.distx*10^-3;

figure(2)
hold on
plot(dist,z_max,'r-');
plot(dist,z_mean,'k-','linewidth',2);
plot([dist;nan;dist],[z_mean-z_std;nan;z_mean+z_std],'k-');
plot(dist,z_min,'b-');
xlim([min(dist) max(dist)]);
legend('Max','Mean','+/- Std','Min')
box on
title(['Swath profile n° ' num2str(nprofiles)])
ylabel('Elevation (m)')
xlabel('Distance along profile (m)')
if ToScale == 1, axis equal, end 

fid = fopen(char(strcat('swath_profile_n',num2str(nprofiles),'.txt')),'w'); % Change output file name
fprintf(fid,'%f %f %f %f %f %f\n',dist, z_max, z_mean, z_mean-z_std, z_mean+z_std, z_min);
end

%% PLOT REGULAR ELEVATION PROFILE
for i = 1:nprofiles
sw2 = SWATHobj(DEM,x(i,:),y(i,:),'width',0.1);
dz = mean(sw2.Z,1)';
dx = sw2.distx;

figure(3)
plot(dx,dz,'k-','linewidth',2);
xlim([min(dx) max(dx)]);
box on
title(['Elevation profile n° ' num2str(nprofiles)])
ylabel('Elevation (m)')
xlabel('Distance along profile (km)')
if ToScale == 1, axis equal, end 
end
