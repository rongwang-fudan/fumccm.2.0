% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;
clear global;

Initialset_econ;
Initialset_clim;

% rlearning=0; % no learning
% fmit=0;
% tip_para(:,7)=tip_para(:,7)*0;

ns=21;
S=zeros(T,78,ns);
for sce=1:ns
    S(1,1:22,sce)=econo0;
    S(1,33:43,sce)=clim0;
end
for t=1:289 % 2015 to 2303
    tyear=t+2014; display(tyear);
    alen=100; % the characteristic time of transitioning investment from ff to renewables
    if tyear>=2025
        alen=40; % calibrated to achieve the reduction in global CO2 emissions during 2025–2050 under current policies
    end
    for sce=1:1:ns
        fracinv=(econo0(16)-1)*exp(-((max(0,tyear-2025))^2)/2/alen/alen)+1; % Investment allocation
        cpc = 0;
        if tyear>=2025
            cpc = (sce-1)*20; % carbon price since 2025
        end
        S(t+1,1:32,sce) = econdyn(t+1, S(t,1:32,sce), fracinv, cpc, S(t,40,sce), S(t,78,sce));
        rff = (S(t+1,12,sce)-S(t+1,21,sce))/(S(1,12,sce)-S(1,21,sce)); % ratio of fossil fuel change
        S(t+1,33:78,sce) = climdyn(t+1, S(t,33:78,sce), clim0, S(t+1,20,sce), rff );
    end
end

cpri=zeros(ns,9);
ty=2025;
for sce=1:ns
    for t=1:287 % 2015 to 2301
        tyear=t+2014;
        tp=floor((tyear-2001)/50)+1;
        uchange=(S(t,32,sce)-S(t,32,1))*(1+prtp)^(ty-2025)*(S(ty-2014,7)*(1-S(ty-2014,4))/L(ty-2014)*1000)^elasmu/(S(ty-2014,7)*(1-S(ty-2014,4)));
        cpri(sce,tp+1)=cpri(sce,tp+1)+uchange;
        cpri(sce,1)=cpri(sce,1)+uchange;
        if tyear==2301
            cpri(sce,tp+1)=uchange/prtp; % The utility difference is extrapolated after 2300 at constant value to be discounted.
            cpri(sce,1)=cpri(sce,1)+uchange*(1/prtp-1);
        end
    end
    cpri(sce,9)=max(S(:,40,sce),[],1);
end
[ID, B]=sort(-cpri(:,1)); optcp=B(1)+1;

S2=zeros(T,24*3);

ty=2025;
scaled1=(1+prtp)^(ty-2025)*(S(ty-2014,7) * (1-S(ty-2014,4))/L(ty-2014)*1000)^elasmu; % trillion $
for sce=1:3
    S1=S(:,:,sce*5-4);
    S1(:,1) = S1(:,1) * 3600; % EUE $/KJ -> $/kWh
    S1(:,2) = S1(:,2) / 3600; % EPE PJ/(t$)^0.3 / (billion cap)^0.7 -> PWh/(t$)^0.3 / (billion cap)^0.7
    S1(:,12) = S1(:,12) / 3600 * 0.3263; % energy PJ -> PWh based on a heat rate of 32.63%
    S1(:,21) = S1(:,21) / 3600 * 0.3263; % cumulative green energy PJ -> PWh based on a heat rate of 32.63%
    S2(:,(sce*24-23):(sce*24-2)) = S1(:,1:22);
    S2(:,sce*24-1) = S1(:,40);
    S2(:,sce*24) = S1(:,32)*scaled1;
end

