% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;

Initialset_econ;
Initialset_clim;
scc=zeros(3,1);
for di=1:3
prtp=0.005*(di+1);
S=zeros(T,78,2);
for sce=1:2
    S(1,1:22,sce)=econo0;
    S(1,33:43,sce)=clim0;
end
for t=1:289 % 2015 to 2300
    tyear=t+2014;
    alen=100; % the characteristic time of transitioning investment from ff to renewables
    if tyear>=2025
        alen=40; % calibrated to achieve the reduction in global CO2 emissions during 2025–2050 under current policies
    end
    for sce=1:2
        addemission=0;
        if tyear==2025
            addemission=sce-1;
        end
        fracinv=(econo0(16)-1)*exp(-((max(0,tyear-2025))^2)/2/alen/alen)+1; % Investment allocation
        S(t+1,1:32,sce) = econdyn(t+1, S(t,1:32,sce), fracinv, 0, S(t,40,sce), S(t,78,sce));
        rff = (S(t+1,12,sce)-S(t+1,21,sce))/(S(1,12,sce)-S(1,21,sce)); % ratio of fossil fuel change
        S(t+1,33:78,sce) = climdyn(t+1, S(t,33:78,sce), clim0, S(t+1,20,sce)+addemission, rff ); % 1 Gt CO2
    end
end
ty=2025;
scaled1=(1+prtp)^(ty-2025)*(S(ty-2014,7) * (1-S(ty-2014,4))/L(ty-2014)*1000)^elasmu * 1000; % billion $
scc(di,1) = (sum(S(1:286,32,1),1)-sum(S(1:286,32,2),1)+(S(287,32,1)-S(287,32,2))/prtp) * scaled1 ; % billion $ / Gt CO2 -> $/tCO2
end

load('dat\cpri_para.dat','-mat');
% optimal carbon pricing maximizing CPRI
nf=15;
ns=21; 
cpri2025=zeros(nf+6,10);
for simu=1:(nf+1)
    if simu<=nf
        s1=simu*2-1; s2=simu*2;
    else
        s1=nf*2+8+1; s2=s1;
    end
    for j=1:4
        cpri2025(simu,(j-1)*2+1) = cpri(j*5+1,s1); % low case
        cpri2025(simu,(j-1)*2+2) = cpri(j*5+1,s2); % high case
    end
    [v, id]=sort(-cpri(:,s1)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2);
    cpri2025(simu,9)=-b2(2)/b2(1)/2;  % optimal carbon price
    [v, id]=sort(-cpri(:,s2)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2);
    cpri2025(simu,10)=-b2(2)/b2(1)/2; % optimal carbon price
end

load(strcat('dat\ucpri_monte',num2str(1),'.dat'),'-mat');
[N1,N2]=size(ucpri); ucpri1=zeros(N1,N2,4); ucpri2=zeros(N1,N2*4);
ucpri1(:,:,1)=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(2),'.dat'),'-mat');
ucpri1(:,:,2)=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(3),'.dat'),'-mat');
ucpri1(:,:,3)=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(4),'.dat'),'-mat');
ucpri1(:,:,4)=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(5),'.dat'),'-mat');
ucpri2(:,1:N2)=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(6),'.dat'),'-mat');
ucpri2(:,(N2+1):(N2*2))=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(7),'.dat'),'-mat');
ucpri2(:,(N2*2+1):(N2*3))=ucpri; clear ucpri;
load(strcat('dat\ucpri_monte',num2str(8),'.dat'),'-mat');
ucpri2(:,(N2*3+1):(N2*4))=ucpri; clear ucpri;

% percentiles of cpri
for j=1:4
    for i=1:4
        cpri2025(nf+1+i,j*2-1)=prctile(ucpri1(j*5+1,1:end,i),17);
        cpri2025(nf+1+i,j*2)=prctile(ucpri1(j*5+1,1:end,i),83);
    end
    cpri2025(nf+6,j*2-1)=prctile(ucpri2(j*5+1,1:end),17);
    cpri2025(nf+6,j*2)=prctile(ucpri2(j*5+1,1:end),83);
end

% percentiles of optimal carbon price
for i=1:4
    for simu=1:N2
        [v, id]=sort(-ucpri1(1:ns,simu,i)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2);
        ucpri1(end,simu,i)=-b2(2)/b2(1)/2;  % optimal carbon price
    end
    cpri2025(nf+1+i,9)=prctile(ucpri1(end,1:end,i),17);
    cpri2025(nf+1+i,10)=prctile(ucpri1(end,1:end,i),83);
end
for simu=1:size(ucpri2,2)
    [v, id]=sort(-ucpri2(1:ns,simu)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2);
    ucpri2(end,simu)=-b2(2)/b2(1)/2;  % optimal carbon price
end
cpri2025(nf+6,9)=prctile(ucpri2(end,1:end),17);
cpri2025(nf+6,10)=prctile(ucpri2(end,1:end),83);

linecolor=jet(nf); x=[0:20:400]; xcp=x'; linecolor(end,:)=[0.64 0 0];
mapcolor=load('dat\color\lightredblue.txt');
mapcolor2=load('dat\color\bluewhitered.txt');
ms=zeros(31,3);
for i=1:11
    ms(i,1:3)=mapcolor2(i*12-3,1:3);
end
for i=12:31
    ms(i,1:3)=mapcolor2(146+(i-11)*5,1:3);
end
ms2=jet(9);
ms2(2,1:3)=ms2(9,1:3); ms2(3,1:3)=ms2(7,1:3); ms2(7,1:3)=[1 0.6 0.6];

% sensitivity test for cpri
subplot(4,2,1);
for i=1:3
    s1=[xcp;xcp(end:-1:1)]; s2=[cpri(1:21,i+30);cpri(21:-1:1,39)]; pvi1 = fill(s1,s2,'red'); hold on;
    pvi1.FaceColor = ms2(i,1:3); pvi1.EdgeColor = 'none'; pvi1.FaceAlpha =0.3;
end
plot(xcp,cpri(1:21,39),'LineStyle','-','LineWidth',3,'Color',[0 0 0]); hold on;
for i=1:3
    plot(xcp,cpri(1:21,i+30),'LineStyle','-','LineWidth',2,'Color',ms2(i,1:3)); hold on;
end
for i=4:8
    plot(xcp,cpri(1:21,i+30),'LineStyle',':','LineWidth',2,'Color',ms2(i,1:3)); hold on;
end
for i=1:8
    f24=scatter(i*20,-7,'+','filled','MarkerEdgeColor',ms2(i,1:3),'MarkerFaceColor','none','SizeData',100); hold on;
end
axis([0 400 -10 8]);
set(gca,'xtick',0:400:400); set(gca,'ytick',-10:18:8); 

% sensitivity test for cpri
subplot(4,2,2);
for i=1:3
    s1=[xcp;xcp(end:-1:1)]; s2=[cpri(1:21,i+77);cpri(21:-1:1,86)]; pvi1 = fill(s1,s2,'red'); hold on;
    pvi1.FaceColor = ms2(i,1:3); pvi1.EdgeColor = 'none'; pvi1.FaceAlpha =0.3;
end
plot(xcp,cpri(1:21,86),'LineStyle','-','LineWidth',3,'Color',[0 0 0]); hold on;
for i=1:3
    plot(xcp,cpri(1:21,i+77),'LineStyle','-','LineWidth',2,'Color',ms2(i,1:3)); hold on;
end
for i=4:8
    plot(xcp,cpri(1:21,i+77),'LineStyle',':','LineWidth',2,'Color',ms2(i,1:3)); hold on;
end
for i=1:8
    f24=scatter(i*20+150,4.5,'+','filled','MarkerEdgeColor',ms2(i,1:3),'MarkerFaceColor','none','SizeData',100); hold on;
end
axis([0 400 1 5]);
set(gca,'xtick',0:400:400); set(gca,'ytick',1:4:5); 

% cpri in Monte Carlo simulations
subplot(4,2,3);
p1=[0 0 1]; p2=[0.72 0.72 1]; p3=p2-p1;
for i=1:4000
    q=max(ucpri2(1:ns,i),[],1);
    if q<35
        plot(xcp,ucpri2(1:ns,i),'LineStyle','-','LineWidth',0.1,'Color',(p1+p3*max(0,min(1,(q-0)/35)))); hold on;
    end
end
z1=prctile(ucpri2(1:ns,:),[1 99],2);
s1=[xcp;xcp(end:-1:1)]; s2=[z1(:,2);z1(end:-1:1,1)]; pvi1 = fill(s1,s2,'red'); hold on;
pvi1.FaceColor = [1 1 0.5]; pvi1.EdgeColor = 'none'; pvi1.FaceAlpha =0.5;
z2=prctile(ucpri2(1:ns,:),[17 83],2);
s1=[xcp;xcp(end:-1:1)]; s2=[z2(:,2);z2(end:-1:1,1)]; pvi2 = fill(s1,s2,'red'); hold on;
pvi2.FaceColor = [1 0.6 0.6]; pvi2.EdgeColor = 'none'; pvi2.FaceAlpha =0.5;
plot(xcp,mean(ucpri2(1:ns,:),2),'LineStyle','-','LineWidth',2,'Color',[0 0 0]); hold on;
plot(xcp,ucpri2(1:ns,1),'LineStyle','--','LineWidth',2,'Color',[0 0 0]); hold on;
axis([0 400 -10 35]);
set(gca,'xtick',0:400:400); set(gca,'ytick',-10:45:35);

% cpri for 100, 200, 300 and 400 $/tCO2 in sensitivity tests
subplot(4,2,4);
for j=1:4
    for i=1:nf
        q1=j*10+6/nf*i;
        plot(q1,cpri2025(i,j*2-1),'^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(i,1:3),'MarkerSize',5); hold on;
        plot(q1,cpri2025(i,j*2),'v','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(i,1:3),'MarkerSize',5); hold on;
    end
    plot(j*10+6/nf*(nf+1)/2,cpri2025(16,j*2-1),'+','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none','MarkerSize',25); hold on;
    % ranges in three monte carlo
    for i=1:3
        plot(j*10+6/nf*(nf+1)/2+i*2-4,cpri2025(i+16,j*2-1),'+','LineWidth',2,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none','MarkerSize',15); hold on;
        plot(j*10+6/nf*(nf+1)/2+i*2-4,cpri2025(i+16,j*2),'+','LineWidth',2,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none','MarkerSize',15); hold on;
    end
end
axis([5 50 -5 20]);
set(gca,'xtick',5:45:50); set(gca,'ytick',-5:25:20); 

% peak warming in Monte Carlo simulations
subplot(4,2,5);
p1=[0.6 0 0.8]; p2=[0.92 0.74 1]; p3=p2-p1;
for i=1:4000
    q=max(ucpri2((ns+1):(ns*2),i),[],1);
    if q<6
        plot(xcp,ucpri2((ns+1):(ns*2),i),'LineStyle','-','LineWidth',0.1,'Color',(p1+p3*max(0,min(1,(q-1)/5)))); hold on;
    end
end
z1=prctile(ucpri2((ns+1):(ns*2),:),[1 99],2);
s1=[xcp;xcp(end:-1:1)]; s2=[z1(:,2);z1(end:-1:1,1)]; pvi1 = fill(s1,s2,'red'); hold on;
pvi1.FaceColor = [1 1 0.5]; pvi1.EdgeColor = 'none'; pvi1.FaceAlpha =0.5;
z2=prctile(ucpri2((ns+1):(ns*2),:),[17 83],2);
s1=[xcp;xcp(end:-1:1)]; s2=[z2(:,2);z2(end:-1:1,1)]; pvi2 = fill(s1,s2,'red'); hold on;
pvi2.FaceColor = [1 0.6 0.6]; pvi2.EdgeColor = 'none'; pvi2.FaceAlpha =0.5;
plot(xcp,mean(ucpri2((ns+1):(ns*2),:),2),'LineStyle','-','LineWidth',2,'Color',[0 0 0]); hold on;
plot(xcp,ucpri2((ns+1):(ns*2),1),'LineStyle','--','LineWidth',2,'Color',[0 0 0]); hold on;
axis([0 400 1 6]);
set(gca,'xtick',0:400:400); set(gca,'ytick',1:5:6);

% peak warming for 40, 80, 120, 160 and 200 $/tCO2 in sensitivity tests
subplot(4,2,6);
for j=1:4
    for i=1:nf
        q1=j*10+6/nf*i;
        plot(q1,cpri(j*2+3,i*2+46),'^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(i,1:3),'MarkerSize',5); hold on;
        plot(q1,cpri(j*2+3,i*2+47),'v','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(i,1:3),'MarkerSize',5); hold on;
    end
    plot(j*10+6/nf*(nf+1)/2,cpri(j*2+3,47),'+','LineWidth',2,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor','none','MarkerSize',25); hold on;
    % ranges in three monte carlo
    for i=1:3
        z1=prctile(ucpri1(ns+j*2+3,:,i),[17 83],2);
        plot(j*10+6/nf*(nf+1)/2+i*2-4,z1(1),'+','LineWidth',2,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none','MarkerSize',15); hold on;
        plot(j*10+6/nf*(nf+1)/2+i*2-4,z1(2),'+','LineWidth',2,'MarkerEdgeColor',[1 0 0],'MarkerFaceColor','none','MarkerSize',15); hold on;
    end
end
axis([5 50 1 4.5]);
set(gca,'xtick',5:45:50); set(gca,'ytick',1:3.5:4.5); 

% cpri change in Monte Carlo simulations
subplot(4,2,7);
fcpri_rise=zeros(3,2);
for i=1:3
    q1=ucpri2(i*2+4,1:end)-ucpri2(i*2+3,1:end); [y1,y2,u] = ksdensity(q1,'kernel','normal'); % from 80 to 100 $/tCO2
    y3=max(y1,[],2)/20;
    s1=[y2 y2(end:-1:1)]; s2=[(i*50-20+y1/y3*0) (i*50-20-y1(end:-1:1)/y3)]; pvi = fill(s2,s1,'red'); hold on;
    pvi.FaceColor = [0.44 0.72 0.6]; pvi.EdgeColor = 'none';    
    idy=find(y2<0); fcpri_rise(i,1)=sum(y1(idy),2)/sum(y1,2);    
    q2=ucpri2(i*2+5,1:end)-ucpri2(i*2+4,1:end); [y1,y2,u] = ksdensity(q2,'kernel','normal'); % from 100 to 120 $/tCO2
    y3=max(y1,[],2)/20;
    s1=[y2 y2(end:-1:1)]; s2=[(i*50-20+y1/y3) (i*50-20-y1(end:-1:1)/y3*0)]; pvi = fill(s2,s1,'red'); hold on;
    pvi.FaceColor = [0.92 0.6 0.44]; pvi.EdgeColor = 'none';
    idy=find(y2<0); fcpri_rise(i,2)=sum(y1(idy),2)/sum(y1,2);
    for j=1:nf
        plot(i*50-20-(nf+1-j),cpri(i*2+4,j*2-1)-cpri(i*2+3,j*2-1),'^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(j,1:3),'MarkerSize',3); hold on;
        plot(i*50-20-(nf+1-j),cpri(i*2+4,j*2)-cpri(i*2+3,j*2),'v','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(j,1:3),'MarkerSize',3); hold on;
        plot(i*50-20+(nf+1-j),cpri(i*2+5,j*2-1)-cpri(i*2+4,j*2-1),'^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(j,1:3),'MarkerSize',3); hold on;
        plot(i*50-20+(nf+1-j),cpri(i*2+5,j*2)-cpri(i*2+4,j*2),'v','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(j,1:3),'MarkerSize',3); hold on;
    end
    for j=1:3
        plot(i*50-30,prctile(q1,33*j-16),'+','LineWidth',2,'MarkerSize',9,'MarkerEdgeColor',[0 0 0]); hold on;
        plot(i*50-10,prctile(q2,33*j-16),'+','LineWidth',2,'MarkerSize',9,'MarkerEdgeColor',[0 0 0]); hold on;
    end
end
axis([0 160 -1 3]);
set(gca,'xtick',0:160:160); set(gca,'ytick',-1:4:3); 

subplot(4,2,8);
idx1=find(ucpri2(end,1:end)>=50); q1=ucpri2(:,idx1); idx2=find(q1(end,1:end)<=300); q1=q1(:,idx2);
[y1,y2,u] = ksdensity(q1(end,1:end),'kernel','normal'); % optimal carbon price
y3=max(y1,[],2)/20;
s1=[y2 y2(end:-1:1)]; s2=[(20+y1/y3) (20-y1(end:-1:1)/y3)]; pvi = fill(s2,s1,'red'); hold on;
pvi.FaceColor = [0.8 0.8 0.8]; pvi.EdgeColor = 'none';
for i=1:15
    plot(20-(nf+1-i),cpri2025(i,9),'^','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(i,1:3),'MarkerSize',5); hold on;
    plot(20+(nf+1-i),cpri2025(i,10),'v','MarkerEdgeColor',[0 0 0],'MarkerFaceColor',linecolor(i,1:3),'MarkerSize',5); hold on;
end
for j=1:3
    plot(20,prctile(q1(end,1:end),33*j-16),'+','LineWidth',2,'MarkerSize',9,'MarkerEdgeColor',[0 0 0]); hold on;
end
id=[1 5 7 8 10]; ucpri2(ns*2+8,1)=2.5;
for i=1:5
    idx3=find(q1(ns*2+id(i),1:end)<ucpri2(ns*2+id(i),1)); q2=q1(:,idx3);
    [y1,y2,u] = ksdensity(q2(end,1:end),'kernel','normal'); % optimal carbon price
    y3=max(y1,[],2)/5;
    s1=[y2 y2(end:-1:1)]; s2=[(20*i+40+y1/y3*0) (20*i+40-y1(end:-1:1)/y3)]; pvi = fill(s2,s1,'red'); hold on;
    pvi.FaceColor = [0.44 0.72 0.6]; pvi.EdgeColor = 'none';
    idx3=find(q1(ns*2+id(i),1:end)>=ucpri2(ns*2+id(i),1)); q3=q1(:,idx3);
    [y1,y2,u] = ksdensity(q3(end,1:end),'kernel','normal'); % optimal carbon price
    y3=max(y1,[],2)/5;
    s1=[y2 y2(end:-1:1)]; s2=[(20*i+40+y1/y3) (20*i+40-y1(end:-1:1)/y3*0)]; pvi = fill(s2,s1,'red'); hold on;
    pvi.FaceColor = [0.92 0.6 0.44]; pvi.EdgeColor = 'none';
    for j=1:3
        plot(20*i+35,prctile(q2(end,1:end),33*j-16),'+','LineWidth',0.1,'MarkerSize',9,'MarkerEdgeColor',[0 0 0]); hold on;
        plot(20*i+45,prctile(q3(end,1:end),33*j-16),'+','LineWidth',0.1,'MarkerSize',9,'MarkerEdgeColor',[0 0 0]); hold on;
    end
end
for i=1:3
    plot(45,scc(i,1),'+','LineWidth',0.1,'MarkerSize',9,'MarkerEdgeColor',[1 0 0]); hold on;
end
axis([0 150 0 800]);
set(gca,'xtick',0:150:150); set(gca,'ytick',0:800:800); 
