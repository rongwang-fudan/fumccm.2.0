% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;
clear global;

Initialset_econ;
Initialset_clim;

cndata=load('dat\countrydata.txt'); % rich (1), region (2), per capita GDP (3), emis Gt CO2 (4-19), pop million (20-35), gpd t$ (36-51)
ns=21;
ncn=size(cndata,1);
cpri2=zeros(ns+3,18*2);


prtp=0.01;

for simu=1:18
display(simu);

if simu<=8
    yycpc=2020+simu*5;
else
    yycpc=2025;
end

if simu<=8
    fcpc=1;
else
    fcpc=(simu-8)/10;
end

S=zeros(T,78,ns);
for sce=1:ns
    S(1,1:22,sce)=econo0;
    S(1,33:43,sce)=clim0;
end
for t=1:289 % 2015 to 2303
    tyear=t+2014;
    alen=100; % the characteristic time of transitioning investment from ff to renewables
    if tyear>=2025
        alen=40; % calibrated to achieve the reduction in global CO2 emissions during 2025–2050 under current policies
    end
    for sce=1:ns
        fracinv=(econo0(16)-1)*exp(-((max(0,tyear-2025))^2)/2/alen/alen)+1; % Investment allocation
        cpc = 0;
        if tyear>=yycpc
            cpc = (sce-1)*20; % carbon price since 2025
        end
        S(t+1,1:32,sce) = econdyn(t+1, S(t,1:32,sce), fracinv, cpc, S(t,40,sce), S(t,78,sce));
        rff = (S(t+1,12,sce)-S(t+1,21,sce))/(S(1,12,sce)-S(1,21,sce)); % ratio of fossil fuel change
        S(t+1,33:78,sce) = climdyn(t+1, S(t,33:78,sce), clim0, S(t+1,20,sce), rff );
    end
end

% CPRI and peak warming
scaled1=(S(yycpc-2014,7) * (1-S(yycpc-2014,4))/L(yycpc-2014)*1000)^elasmu / (S(yycpc-2014,7) * (1-S(yycpc-2014,4))); % trillion $ / trillion $
for sce=1:ns
    cpri2(sce,simu) = (sum(S(1:286,32,sce),1)-sum(S(1:286,32,1),1)+(S(287,32,sce)-S(287,32,1))/prtp) * scaled1;
    cpri2(sce,simu+18) = max(S(:,40,sce),[],1);
end

end

for simu=1:18
    [v, id]=sort(-cpri2(1:ns,simu)); x=id(1:5)*20-20; y=v(1:5); b2=polyfit(x,y,2);
    cpri2(ns+1,simu)=-b2(2)/b2(1)/2; % optimal carbon price
    if abs(cpri2(ns+1,simu)-x(1))>20
        cpri2(ns+1,simu)=x(1);
    end
    cpri2(ns+2,simu)=cpri2(id(1),simu); % CPRI
    cpri2(ns+3,simu)=cpri2(id(1),simu+18); % peak warming
end


