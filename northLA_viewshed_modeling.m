%% NOTE TO USER: FOR BEST RESULTS, CODE SHOULD BE RUN ...
%%  SECTION-BY-SECTION INSTEAD OF ALL AT ONCE
[alt,refvec] = usgsdem('los_angeles_e.dem',1); % reads in altitude data
alt(alt==0)=-1;
alt=alt([1:601],[601:end]);
lat=zeros(601); % same size matrix as alt
lon=zeros(601);
qlat=linspace(34,34.5,601); % corresponding latitude for los_angeles_e
qlon=linspace(-118.5,-118,601); % corresponding longitude for los_angeles_e
for n=1:601
    lat(n,:)=qlat(n); % creates latitude matrix
    lon(:,n)=qlon(n); % creates longitude matrix
end
latlim=[34 34.5];
lonlim=[-118.5 -118];
%% creates a 2-D representaion of the elevation data
figure=usamap(latlim,lonlim);
geoshow(lat,lon,alt,'DisplayType','surface');
demcmap(alt);

daspectm('m',1);
title('North Los Angeles');
plabel off
mlabel off
%% 3-D representation
% find image data via server
ortho = wmsfind('/USGSImageryTopo/','SearchField','serverurl'); 
layers = wmsfind('data.worldwind', 'SearchField', 'serverurl');
us_ned = layers.refine('usgs ned 30');
% read in image data and crop data accordingly
imageHeight=size(alt,1);
imageWidth=size(alt,2);
A = wmsread(ortho, 'Latlim', latlim, 'Lonlim', lonlim, ...
   'ImageHeight', imageHeight, 'ImageWidth', imageWidth);
[Z, R] = wmsread(us_ned, 'ImageFormat', 'image/bil', ...
    'Latlim', latlim, 'Lonlim', lonlim, ...
    'ImageHeight', imageHeight, 'ImageWidth', imageWidth);
% create a 3-D model of elevation data and drape image data on top
figure;clf;
usamap(latlim, lonlim);
framem off; mlabel off; plabel off; gridm off;
geoshow(double(Z), R, 'DisplayType', 'surface', 'CData', A);
daspectm('m',1)
title({'Northeast LA County', 'USGS NED and Ortho Image'}, ...
   'FontSize',8);

% camera set to very high viewpoint so entire map is visible
cameraPosition=[33.5 -118.25 5000000];
cameraTarget=[34.25 -118.25];
cameraAngle=5;
set(gca,'CameraPosition',cameraPosition,'CameraTarget', ... 
    cameraTarget,'CameraViewAngle',cameraAngle);
%% creating a viewshed based on 100m tower at point (273,522) (Mt. Wilson)
[VS,Rs]=viewshed(double(Z),R,lat(273,522),lon(273,522),100);
%% displaying the viewshed
% all points outside of the viewshed are darkened by 0.5
Red=A(:,:,1);
Gre=A(:,:,2);
Blu=A(:,:,3);
Red(~logical(VS))=Red(~logical(VS))*(0.5);
Gre(~logical(VS))=Gre(~logical(VS))*(0.5);
Blu(~logical(VS))=Blu(~logical(VS))*(0.5);
% the new image data is created
alt_VS=cat(3,Red,Gre,Blu);
% a new 3-D model is created using the new image data
figure;clf;
usamap(latlim, lonlim);
framem off; mlabel off; plabel off; gridm off;
geoshow(double(Z), R, 'DisplayType', 'surface', 'CData', alt_VS);
daspectm('m',1)
title({'North Los Angeles', 'USGS NED and Ortho Image'}, ...
   'FontSize',8);
hold on;plot(273,522,'g.');

% the same very high camera angle is used
cameraPosition=[33.5 -118.5 5000000];
cameraTarget=[34.25 -118.5];
cameraAngle=5;
set(gca,'CameraPosition',cameraPosition,'CameraTarget', ...
    cameraTarget,'CameraViewAngle',cameraAngle);

