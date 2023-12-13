% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;
clear global;

Initialset_econ;
Initialset_clim;

clim0sink=zeros(13+9,11);
for i=1:13
    clim0sink(i,1:11) = calib_csi ( clim0, 2.4+i/10, ocean_csink );
end
for i=1:9
    clim0sink(13+i,1:11) = calib_csi ( clim0, land_csink, 2.1+i/10 );
end

nf=15;
ns=21;
cpri=zeros(ns,nf*2+8+9+nf*2+8+1);

FFlux0=FFlux; clim00=clim0; Fex0=Fex; tip_para0=tip_para; econo00=econo0; rlearning0=rlearning; negcap0=negcap; bhm0=bhm;

for simu=1:(nf*2+8+1)

display(simu);

FFlux=FFlux0; clim0=clim00; Fex=Fex0; tip_para=tip_para0; econo0=econo00; bhm=bhm0; rlearning=rlearning0; negcap=negcap0;
miec=1; prtp=0.015; fmit=1; falab=1; fainv=1; ftip=1; fsav=1;

if simu==1
    FFlux(1)=2.5/deltarf;
elseif simu==2
    FFlux(1)=3.5/deltarf;
elseif simu==3
    land_csink=2.5;clim0 = clim0sink(min(13,max(1,floor(land_csink*10-25)+1)),1:11);
elseif simu==4
    land_csink=3.7;clim0 = clim0sink(min(13,max(1,floor(land_csink*10-25)+1)),1:11);
elseif simu==5
    ocean_csink=2.2;clim0 = clim0sink(13+min(9,max(1,floor(ocean_csink*10-22)+1)),1:11);
elseif simu==6
    ocean_csink=3;clim0 = clim0sink(13+min(9,max(1,floor(ocean_csink*10-22)+1)),1:11);
elseif simu==7
    Fex(:,1:4)=Fex(:,1:4)*0.8;
elseif simu==8
    Fex(:,1:4)=Fex(:,1:4)*1.2;
elseif simu==9
    Fex(:,5)=Fex(:,5)*0.5;
elseif simu==10
    Fex(:,5)=Fex(:,5)*1.5;
elseif simu==11
    for i=1:size(tip_para,1)
        tip_para(i,8) = calib_tip(tip_para(i,2));
    end
elseif simu==12
    for i=1:size(tip_para,1)
        tip_para(i,8) = calib_tip(tip_para(i,3));
    end
elseif simu==13
    tip_para(:,6)=tip_para(:,6)*0.5;
elseif simu==14
    tip_para(:,6)=tip_para(:,6)*1.5;
elseif simu==15
    tip_para(:,5)=tip_para(:,5)*0.5;
elseif simu==16
    tip_para(:,5)=tip_para(:,5)*1.5;
elseif simu==17
    negcap=15;
elseif simu==18
    negcap=35;
elseif simu==19
    bhm(1:2)=bhm0(1:2)*0.8;
elseif simu==20
    bhm(1:2)=bhm0(1:2)*1.2;
elseif simu==21
    tip_para(:,7)=tip_para(:,7)*0.5;
elseif simu==22
    tip_para(:,7)=tip_para(:,7)*1.5;
elseif simu==23
    rlearning=0.15;
elseif simu==24
    rlearning=0.25;
elseif simu==25
    miec=2;
elseif simu==26
    miec=3;
elseif simu==27
    econo0(22)=mac(1,2);
elseif simu==28
    econo0(22)=mac(1,3);
elseif simu==29
    prtp=0.01;
elseif simu==30
    prtp=0.02;
elseif simu==31
    miec=0; % no feedback of mitigation to efficiency growth
    negcap=100;
elseif simu==32
    bhm=bhm0*0; % no feedback of warming to efficiency growth
elseif simu==33
    rlearning=0; % no feedback of mitigation to reduce low-carbon energy costs
elseif simu==34
    fmit=0; % no feedback of climate damage to reduce use of low-carbon energy 
elseif simu==35
    falab=0; % no feedback of mitigation to labor reallocation
elseif simu==36
    fainv=0; % no feedback of mitigation to investment reallocation
elseif simu==37
    ftip=0; % no feedback of climate tipping points to the economy
elseif simu==38
    tip_para(:,5)=tip_para(:,5)*0; % no impact of climate tipping points to temperature
end

S=zeros(T,78,ns);
for sce=1:ns
    S(1,1:22,sce)=econo0;
    S(1,33:43,sce)=clim0;
end
for t=1:289 % 2015 to 2300
    tyear=t+2014;
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

ty=2025;
scaled1=(1+prtp)^(ty-2025)*(S(ty-2014,7) * (1-S(ty-2014,4))/L(ty-2014)*1000)^elasmu / (S(ty-2014,7) * (1-S(ty-2014,4))); % trillion $ / trillion $
for sce=1:ns
    cpri(sce,simu) = (sum(S(1:286,32,sce),1)-sum(S(1:286,32,1),1)+(S(287,32,sce)-S(287,32,1))/prtp) * scaled1;    
    cpri(sce,nf*2+8+9+simu) = max(S(:,40,sce),[],1); % peak warming
end

if simu==(nf*2+8+1)
    for sce=1:ns
        for t=1:287 % 2015 to 2301
            tyear=t+2014;
            uchange=(S(t,32,sce)-S(t,32,1))*scaled1;
            if tyear<=2300
                cpri(sce,simu+floor((tyear-2001)/50)+1)=cpri(sce,simu+floor((tyear-2001)/50)+1)+uchange;
            elseif tyear==2301
                cpri(sce,simu+7)=uchange/prtp; % The utility difference is extrapolated after 2300 at constant value to be discounted.
            end
        end
        cpri(sce,simu+8)=max(S(:,40,sce),[],1); % peak warming
    end
end

end

save('dat\cpri_para.dat','cpri');




