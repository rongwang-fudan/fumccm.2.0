% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;

cndata=load('dat\countrydata.txt');  % population (1), gdp (2), emis Gt CO2 (3)
load('dat\cpri_tcn.dat','-mat');
ns=21; ncn=size(cndata,1);
% optimal carbon price
cpc=zeros(36+40+ncn,3*3); % optimal carbon price, CPRI, peak warming under rou=0.01, 0.015, 0.02
cpc2d=zeros(ncn,36,4); % optimal carbon price, CPRI, peak warming, and latest year for mitigation under rou=0.02
for i=1:(ncn+36+40)
    for j=1:3
        [v, id]=sort(-cpri(1:ns,i,j)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2); % CPRI for rou=0.015
        cpc(i,j)=-b2(2)/b2(1)/2; % optimal carbon price
        if abs(cpc(i,j)-x(1))>20
            cpc(i,j)=x(1);
        end
        cpc(i,j+3)=cpri(id(1),i,j); % CPRI
        cpc(i,j+6)=cpri(id(1)+ns,i,j); % Peak Warming
    end
end

% mapping optimal carbon price
load('dat\cnid_180x360.dat','-mat');
cpc1=ones(180,360); cpc1=cpc1.*(-999); cpc3=cpc1;
for i=1:180
    for j=1:360
        cn=cnid(i,j);
        if cn>=1 && cn<=222
            idx=find(cndata(:,4)==cn);
            if size(idx,1)>0
                cpc3(i,j)=max(1.5,min(3,cpc(76+idx(1),8))); % peak warming after including this country
            end
        end
    end
end

spacials=1; sinv=1/spacials; refvec = [sinv 90 -180];
land = shaperead('dat\worldline\country_Line.shp', 'UseGeoCoords', true);
axesm('robinson','MapLatLimit',[-90 90], 'MapLonLimit', [-180 180],'grid','off','fram','on'); % eqacylin robinson
geoshow(cpc3,refvec,'DisplayType','texture');
geoshow(land,'Displaytype','line','color','white','LineWidth',0.01);
caxis([1.4 3]);
pa3=jet(16); pa3(1,1:3)=[1 1 1];
colormap(pa3); colorbar
