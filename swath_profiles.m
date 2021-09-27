clear all, close all, clc
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% PREREQUISITIES
% Image processing toolbox
% TopoToolBox 
% Mapping Toolbox 

% PARAMETERS
dem='DEM.tif'; % Input DEM /!\ DEM Must be in projected coordinates (in meters)
swathwidth=5000; % Swath profile with in meter 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%% SWATH PROFILE

DEM = GRIDobj(dem);

% ** Uncomment to manually choose coordinates in the map (in meters) ** 
% x = (xa,xb)
% y = (ya,yb)

figure(1)
imageschs(DEM,DEM,'colorbar',true);
box on
title('DEM')                % Change title text
xlabel('X - Longitude')     % Change x axis text
ylabel('Y - Latitude')      % Change y axis text
c = colorbar;               
c.Label
c.Label.String = 'Elevation';   % Change color bar text
[x,y]=ginput;
hold on
plot(x,y,'k-')
sw1 = SWATHobj(DEM,x,y,'width',swathwidth);
%% PLOT SWAHT PROFILE

z_min = min(sw1.Z,[],1);
z_max = max(sw1.Z,[],1);
z_mean = mean(sw1.Z,1)';
z_std = std(sw1.Z,0,1)';
dist = sw1.distx;
figure(2)
hold on
plot(dist,z_max,'r-');
plot(dist,z_mean,'k-','linewidth',2);
plot([dist;nan;dist],[z_mean-z_std;nan;z_mean+z_std],'k-');
plot(dist,z_min,'b-');
xlim([min(dist) max(dist)]);
legend('Max','Mean','+/- Std','Min')
box on
title('Swath profile')
ylabel('Elevation (m)')
xlabel('Distance along profile (km)')
%axis equal % Uncomment if not in 1:1 scale

%% PLOT REGULAR ELEVATION PROFILE

sw2 = SWATHobj(DEM,x,y,'width',0.1);
dz = mean(sw2.Z,1)';
dx = sw2.distx;

figure(3)
plot(dx,dz,'k-','linewidth',2);
xlim([min(dx) max(dx)]);
box on
title('Elevation profile')
ylabel('Elevation (m)')
xlabel('Distance along profile (km)')
axis equal

%% Output the profile in text file

fid = fopen('swath_profile.txt','w'); % Change output file name
MEAN =[dist z_mean];
fprintf(fid,'%f %f %f %f %f %f\n',dist, z_max, z_mean, z_mean-z_std, z_mean+z_std, z_min);
