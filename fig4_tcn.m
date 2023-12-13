% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;
% https://zhuanlan.zhihu.com/p/522901129 contourf

cndata=load('dat\countrydata.txt');  % population (1), gdp (2), emis Gt CO2 (3)
load('dat\cpri_tcn.dat','-mat');
load('dat\cpri2d_tcn_learn16.dat','-mat');
ns=21; ncn=size(cndata,1);
x1=[1:1:36]; xcp1=x1'; x2=[1:1:ncn]; xcp2=x2'; x3=[1:1:40]; xcp3=x3';
[bcn, idcn]=sort(-cndata(:,3));
fcn=zeros(ncn,1); fcn(1)=cndata(1,3)/sum(cndata(:,3),1);
for i=2:ncn
    fcn(i)=fcn(i-1)+cndata(i,3)/sum(cndata(:,3),1);
end

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
for i=1:ncn
    for j=1:36
        [v, id]=sort(-cpri2d(1:ns,i,j)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2);
        cpc2d(i,j,1)=-b2(2)/b2(1)/2;
        if abs(cpc2d(i,j,1)-x(1))>20
            cpc2d(i,j,1)=x(1);
        end
        cpc2d(i,j,2)=cpri2d(id(1),i,j); % CPRI
        cpc2d(i,j,3)=cpri2d(id(1)+ns,i,j); % Peak Warming
    end
    for j=1:3
        idx=find(cpc2d(i,1:36,3)<=(j*0.4+1.6));
        if size(idx,2)>=1
            if idx(end)==36
                cpc2d(i,j,4)=36;
            else
                cpc2d(i,j,4)=idx(end)+((j*0.4+1.6)-cpc2d(i,idx(end),3))/(cpc2d(i,idx(end)+1,3)-cpc2d(i,idx(end),3));
            end
        else
            cpc2d(i,j,4)=0;
        end
    end
end

mapcolor=load('dat\color\lightredblue.txt');
mapcolor2=load('dat\color\bluewhitered.txt');
ms=zeros(31,3);
for i=1:11
    ms(i,1:3)=mapcolor2(i*12-3,1:3);
end
for i=12:31
    ms(i,1:3)=mapcolor2(146+(i-11)*5,1:3);
end
% ms=jet(31); ms(16:26,1:3)=ms(21:31,1:3); ms(27:31,1:3)=[0.8 0 0.8; 0.8 0 1; 0.6 0.2 1; 0.4 0 1; 0.4 0 0.8];
ms2=[0.8 0.8 0.8; 0.6 0.6 0.6; 0 0 0];
ms3=jet(8); ms4=jet(9);

% CPRI for timing
plot1a=subplot(3,6,1);
for i=1:8
    plot(cpri(1:21,i*5-4,2),xcp1(1:21),'LineStyle','-','LineWidth',1,'Color',ms3(i,1:3)); hold on; % rou=0.01
end
axis([-0.5 4.5 1 21]);
set(gca,'xtick',-0.5:5:4.5); set(gca,'ytick',1:20:21);

% CPRI for participation
plot1b=subplot(3,6,2);
for i=1:9
    plot(cpri(1:21,i*4+36,2),xcp1(1:21),'LineStyle','-','LineWidth',1,'Color',ms4(10-i,1:3)); hold on; % rou=0.01
end
axis([-7 3 1 21]);
set(gca,'xtick',-7:10:3); set(gca,'ytick',1:20:21);

% impact of starting year
plot2=subplot(3,6,[3 4]);
q2=cpri(1:ns,1:36,2); % CPRI for rou=0.015
contourf(q2,'LineWidth',0.1,'Color','none'); hold on;
set(plot2, 'Colormap', mapcolor); colorbar
plot(xcp1(1:5:36),cpc(1:5:36,1)/20+1,'LineStyle','-','LineWidth',1,'Color',ms2(1,1:3)); hold on; % rou=0.01
plot(xcp1(1:5:36),cpc(1:5:36,2)/20+1,'LineStyle','-','LineWidth',1,'Color',ms2(2,1:3)); hold on; % rou=0.015
plot(xcp1(1:5:36),cpc(1:5:36,3)/20+1,'LineStyle','-','LineWidth',1,'Color',ms2(3,1:3)); hold on; % rou=0.02
for i=1:5:36
    for j=1:3
        cj=(cpc(i,j+3)/cpc(1,j+3))*200; % CPRI determines the size
        ck=min(31,max(1,floor((cpc(i,j+6)-1.5)*20)+1)); % peak warming determines the color 1.5-3C
        f11=scatter(i,cpc(i,j)/20+1,'o','filled','MarkerEdgeColor',ms2(j,1:3),'MarkerFaceColor',ms(ck,1:3),'SizeData',cj); hold on;
        alpha(f11,0.7);
    end
end
for i=1:7
    f12=scatter(39,i*2,'o','filled','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',ms(i*5-4,1:3),'SizeData',200); alpha(f12,0.7); hold on;
end
for i=1:6
    f13=scatter(42,i*2,'o','filled','MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none','SizeData',(i*0.1+0.4)^2*200); hold on;
end
axis([1 44 1 21]);
set(gca,'xtick',1:43:44); set(gca,'ytick',1:20:21);

% impact of the number of countries participation
plot3=subplot(3,6,[5 6]);
q2=cpri(1:ns,(36+40):-1:(36+1),2); % CPRI for rou=0.015
contourf(q2,'LineWidth',0.1,'Color','none'); hold on;
set(plot3, 'Colormap', mapcolor); colorbar
% optimal carbon prices
plot(xcp3(1:4:37),cpc((36+40):-4:(36+4),1)/20+1,'LineStyle','-','LineWidth',1,'Color',ms2(1,1:3)); hold on;
plot(xcp3(1:4:37),cpc((36+40):-4:(36+4),2)/20+1,'LineStyle','-','LineWidth',1,'Color',ms2(2,1:3)); hold on;
plot(xcp3(1:4:37),cpc((36+40):-4:(36+4),3)/20+1,'LineStyle','-','LineWidth',1,'Color',ms2(3,1:3)); hold on;
for i=1:4:37
    for j=1:3
        cj=(cpc(36+41-i,j+3)/cpc(36+40,j+3))*200; % CPRI determines the size
        ck=min(31,max(1,floor((cpc(36+41-i,j+6)-1.5)*20)+1)); % peak warming determines the color 1.5-3C
        f21=scatter(i,cpc(36+41-i,j)/20+1,'o','filled','MarkerEdgeColor',ms2(j,1:3),'MarkerFaceColor',ms(ck,1:3),'SizeData',cj); hold on;
        alpha(f21,0.7);
    end
end
for i=1:7
    f22=scatter(43,i*2,'o','filled','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',ms(i*5-4,1:3),'SizeData',200); alpha(f22,0.7); hold on;
end
for i=1:6
    f23=scatter(46,i*2,'o','filled','MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none','SizeData',(i*0.1+0.4)^2*200); hold on;
end
for i=1:10
    f24=scatter(41-fcn(idcn(i),1)*40,2,'+','filled','MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none','SizeData',50); hold on;
end
axis([1 49 1 21]);
set(gca,'xtick',1:48:49); set(gca,'ytick',1:20:21);

% optimal carbon price
plot4=subplot(3,6,[7 8]);
q2=cpc2d((ncn-1):-1:1,36:-1:1,1); image(q2','CDataMapping','scaled'); hold on; 
caxis([150 200]);
set(plot4, 'Colormap', parula); colorbar
for i=1:3
    q1=cpc2d(:,i,4); idx=find(q1>0); 
    if size(idx,1)>1
        if idx(1)>=2
            idx2=[idx(1)-1;idx(1:(size(idx,1)-1))];
        else
            idx2=[idx(1:(size(idx,1)-1))];
        end
        f31=plot(ncn+1-xcp2(idx2,1)-0.5,37-q1(idx2,1),'LineStyle','-','LineWidth',3,'Color',[1 (i*0.3-0.1) 1]); hold on;
    end
end
for i=1:10
    f31=scatter(ncn+1-idcn(i)-0.5,2,'+','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceColor','none','SizeData',50); hold on;
end

% maximal CPRI
plot5=subplot(3,6,[9 10]);
q2=cpc2d((ncn-1):-1:1,36:-1:1,2); image(q2','CDataMapping','scaled'); hold on; 
caxis([0 4]);
set(plot5, 'Colormap', mapcolor); colorbar
for i=1:3
    q1=cpc2d(:,i,4); idx=find(q1>0); 
    if size(idx,1)>1
        if idx(1)>=2
            idx2=[idx(1)-1;idx(1:(size(idx,1)-1))];
        else
            idx2=[idx(1:(size(idx,1)-1))];
        end
        f31=plot(ncn+1-xcp2(idx2,1)-0.5,37-q1(idx2,1),'LineStyle','-','LineWidth',3,'Color',[1 (i*0.3-0.1) 1]); hold on;
    end
end
for i=1:10
    f32=scatter(ncn+1-idcn(i)-0.5,2,'+','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceColor','none','SizeData',50); hold on;
end

% peak warming
plot6=subplot(3,6,[11 12]);
q2=cpc2d((ncn-1):-1:1,36:-1:1,3); image(q2','CDataMapping','scaled'); hold on; 
caxis([1.5 3]);
set(plot6, 'Colormap', jet); colorbar
for i=1:3
    q1=cpc2d(:,i,4); idx=find(q1>0); 
    if size(idx,1)>1
        if idx(1)>=2
            idx2=[idx(1)-1;idx(1:(size(idx,1)-1))];
        else
            idx2=[idx(1:(size(idx,1)-1))];
        end
        f31=plot(ncn+1-xcp2(idx2,1)-0.5,37-q1(idx2,1),'LineStyle','-','LineWidth',3,'Color',[1 (i*0.3-0.1) 1]); hold on;
    end
end
for i=1:10
    f33=scatter(ncn+1-idcn(i)-0.5,2,'+','filled','MarkerEdgeColor',[1 1 1],'MarkerFaceColor','none','SizeData',50); hold on;
end

% mapping optimal carbon price
load('dat\cnid_180x360.dat','-mat');
cpc1=ones(180,360); cpc1=cpc1.*(-999); cpc2=cpc1; cpc3=cpc1;
for cn=1:ncn
    idx=find(cnid==cndata(cn,4));
    if size(idx,1)>0
        cpc1(idx)=max(150,min(200,cpc(76+cn,2))); % optimal carbon price after including this country
        cpc2(idx)=max(0,min(4,cpc(76+cn,5))); % CPRI after including this country
        cpc3(idx)=max(1.5,min(3,cpc(76+cn,8))); % peak warming after including this country
    end
end

spacials=1; sinv=1/spacials; refvec = [sinv 90 -180];
land = shaperead('dat\worldline\country_Line.shp', 'UseGeoCoords', true);

plot7=subplot(3,6,[13 14]);
axesm('robinson','MapLatLimit',[-90 90], 'MapLonLimit', [-180 180],'grid','off','fram','on'); % eqacylin robinson
geoshow(cpc1,refvec,'DisplayType','texture');
geoshow(land,'Displaytype','line','color','white','LineWidth',0.01);
caxis([149 200]);
pa1=parula(52); pa1(1,1:3)=[1 1 1];
set(plot7, 'Colormap', pa1); colorbar

plot8=subplot(3,6,[15 16]);
axesm('robinson','MapLatLimit',[-90 90], 'MapLonLimit', [-180 180],'grid','off','fram','on'); % eqacylin robinson
geoshow(cpc2,refvec,'DisplayType','texture');
geoshow(land,'Displaytype','line','color','white','LineWidth',0.01);
pa2=zeros(41,3);
for i=1:20
    pa2(i*2-1,1:3)=mapcolor(i,1:3);
    pa2(i*2,1:3)=(mapcolor(i,1:3)+mapcolor(i+1,1:3))/2;
end
pa2(1,1:3)=[1 1 1]; pa2(41,1:3)=mapcolor(21,1:3);
caxis([-0.1 4]);
set(plot8, 'Colormap', pa2); colorbar

plot9=subplot(3,6,[17 18]);
axesm('robinson','MapLatLimit',[-90 90], 'MapLonLimit', [-180 180],'grid','off','fram','on'); % eqacylin robinson
geoshow(cpc3,refvec,'DisplayType','texture');
geoshow(land,'Displaytype','line','color','white','LineWidth',0.01);
caxis([1.4 3]);
pa3=jet(16); pa3(1,1:3)=[1 1 1];
set(plot9, 'Colormap', pa3); colorbar
