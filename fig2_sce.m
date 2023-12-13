% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;
clear global;

Initialset_econ;
Initialset_clim;
nsimu=8;
S2=zeros(T,29,3,nsimu);

bhm0=bhm; rlearning0=rlearning; tip_para0=tip_para;
for simu=1:nsimu
display(simu);
prtp=0.015; cpcyear=2025; miec=1; bhm=bhm0; rlearning=rlearning0; tip_para=tip_para0;
if simu==2
    miec=0; % mitigation-efficiency feedback (0, no; 1, yes; 2, lower; 3, higher)
elseif simu==3
    bhm=bhm0*0; % without the effect of warming on productivity (BHM=0)
elseif simu==4
    tip_para(:,6)=0; % without the feedback of tipping points to global carbon cycle
elseif simu==5
    cpcyear=2035; % delay of carbon pricing from 2025 to 2035
elseif simu==6
    rlearning=0; % no learning
elseif simu==7
    prtp=0.01; % with a high pure rate of time preference (ρ=0.02)
elseif simu==8
    prtp=0.01; % with a low pure rate of time preference (ρ=0.01)
    rlearning=0; % no learning
end

S=zeros(T,78,4);
for sce=1:3
    S(1,1:22,sce)=econo0;
    S(1,33:43,sce)=clim0;
end
for t=1:289 % 2015 to 2300
    tyear=t+2014;
    alen=100; % the characteristic time of transitioning investment from ff to renewables
    if tyear>=2025
        alen=40;
    end
    % carbon pricing
    for sce=1:3
        fracinv=(econo0(16)-1)*exp(-((max(0,tyear-2025))^2)/2/alen/alen)+1; % Investment allocation
        cpc=0;
        if tyear>=cpcyear
            cpc=(sce-1)*100;
        end
        S(t+1,1:32,sce) = econdyn(t+1, S(t,1:32,sce), fracinv, cpc, S(t,40,sce), S(t,78,sce));
        rff=(S(t+1,12,sce)-S(t+1,21,sce))/(S(1,12,sce)-S(1,21,sce)); % ratio of fossil fuel change
        S(t+1,33:78,sce) = climdyn(t+1, S(t,33:78,sce), clim0, S(t+1,20,sce), rff );
    end
end

for sce=1:3
    S2(1:286,1,sce,simu)=S(1:286,1,sce) * 3600; % EUE $/KJ -> $/kWh
    S2(1:286,2,sce,simu)=S(1:286,3,sce); % ENE (trillion $)^0.7 / (billion cap)^0.7 -> (1000 $/people)^0.7
    S2(1:286,3,sce,simu)=S(1:286,12,sce) / 3600 * 0.3263; % energy PJ -> PWh based on a heat rate of 32.63%
    S2(1:286,4,sce,simu)=S(1:286,8,sce); % fraction of labor to produce energy
    S2(1:286,5,sce,simu)=S(1:286,9,sce); % fraction of investment to produce energy
    S2(1:286,6,sce,simu)=S(1:286,21,sce) / 3600 * 0.3263; % low-carbon energy PJ -> PWh based on a heat rate of 32.63%
    S2(1:286,7,sce,simu)=S(1:286,20,sce); % global CO2 emissions from the energy sector Gt CO2
    S2(1:286,8,sce,simu)=S(1:286,40,sce); % global warming relative to 1850-1900
    S2(1:286,9,sce,simu)=S(1:286,4,sce); % saving rate
    for t=1:286
        S2(t,10,sce,simu)=log10((S(t+1,7,sce).*(1-S(t,4,sce)))./L(t).*1000); % per capita consumption k$ per cap
        S2(t,13:29,sce,simu)=ones(1,17)-calc_tip(S(t,44:59,sce)); % the probability of N tipping points (N>=1, 2, ... 16, 17)
    end
end

ty=2025;
scaled1=(1+prtp)^(ty-2025)*(S(ty-2014,7) * (1-S(ty-2014,4))/L(ty-2014)*1000)^elasmu; % trillion $

S2(1:286,12,2,simu)=(S(1:286,32,2)-S(1:286,32,1))*scaled1; % change in the discounted utility of consumption trillion $
S2(1:286,12,3,simu)=(S(1:286,32,3)-S(1:286,32,2))*scaled1; % change in the discounted utility of consumption trillion $

end

linecolor=[0.8 0 0; 1 0.8 0; 0 0.6 1];
for i=1:10
    if i<=8
        subplot(5,3,i+1);
    else
        subplot(5,3,i+3);
    end
    plot(smooth(S2(1:286,i,1,1)),'LineStyle','-','LineWidth',1,'Color',linecolor(1,1:3)); hold on;
    plot(smooth(S2(1:286,i,2,1)),'LineStyle','-','LineWidth',1,'Color',linecolor(2,1:3)); hold on;
    plot(smooth(S2(1:286,i,3,1)),'LineStyle','-','LineWidth',1,'Color',linecolor(3,1:3)); hold on;
end

% without the mitigation-efficiency feedback
for i=1:2
    subplot(5,3,i+1);
    for j=2:3
        plot(smooth(S2(1:286,i,j,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(j,1:3)); hold on;
    end
end

% no learning
subplot(5,3,4);
for i=2:3
    plot(smooth(S2(1:286,3,j,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(i,1:3)); hold on;
end

% no learning
subplot(5,3,7);
for i=2:3
    plot(smooth(S2(1:286,6,i,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(i,1:3)); hold on;
end

% no learning
subplot(5,3,8);
for i=2:3
    plot(smooth(S2(1:286,7,i,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(i,1:3)); hold on;
end

% no learning
subplot(5,3,9);
for i=2:3
    plot(smooth(S2(1:286,8,i,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(i,1:3)); hold on;
end

% no learning
subplot(5,3,13);
for i=2:3
    plot(smooth(S2(1:286,10,i,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(i,1:3)); hold on;
end

% change in the discounted utility of consumption: 0 to $200 and $200 to $300
subplot(5,3,14);
plot(smooth(S2(1:286,12,2,1)),'LineStyle','-','LineWidth',1,'Color',linecolor(2,1:3)); hold on;
plot(smooth(S2(1:286,12,3,1)),'LineStyle','-','LineWidth',1,'Color',linecolor(3,1:3)); hold on;
plot(smooth(S2(1:286,12,2,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(2,1:3)); hold on;
plot(smooth(S2(1:286,12,3,6)),'LineStyle','--','LineWidth',1,'Color',linecolor(3,1:3)); hold on;

% change in the discounted utility of consumption under a low pure rate of time preference (rou=0.01)
subplot(5,3,15);
plot(smooth(S2(1:286,12,2,7)),'LineStyle','-','LineWidth',1,'Color',linecolor(2,1:3)); hold on;
plot(smooth(S2(1:286,12,3,7)),'LineStyle','-','LineWidth',1,'Color',linecolor(3,1:3)); hold on;
plot(smooth(S2(1:286,12,2,8)),'LineStyle','--','LineWidth',1,'Color',linecolor(2,1:3)); hold on;
plot(smooth(S2(1:286,12,3,8)),'LineStyle','--','LineWidth',1,'Color',linecolor(3,1:3)); hold on;

% probability of N tipping points (N>=1, 2, ... 16, 17)
linecolor2=jet(15);
bb=[1:286];
for i=1:2
    subplot(5,3,i+9);
    idx=find(S2(286,13:29,i+1,1)>0.05)+12;
    aa=S2(1:286,idx,i+1,1);
    for j=1:(size(idx,2)-1)
        aa(:,j)=aa(:,j)-aa(:,j+1);
    end
    h = area(bb,aa(:,end:-1:1),'FaceColor','flat','LineStyle','none'); hold on; 
    for j=1:size(idx,2)
        h(j).FaceColor = linecolor2(size(idx,2)-j+1,1:3);
        plot(bb,S2(1:286,12+j,i+1,1),'LineStyle','--','LineWidth',0.1,'Color',[(0.3+j*0.03) (0.3+j*0.03) (0.3+j*0.03)]); hold on;
    end
end







