% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.5
tic
clear;
clear global;

Initialset_econ;
Initialset_clim;

ns=21;
Mont=1; % 1 physics of climate; 2 economic impact of climate change; 3 dynamics of technological changes; 4 discounting; 5-8 all
Nm=1000;
ucpri=zeros(ns*2+Ntip*4+15,Nm);

clim0sink=zeros(13+9,11);
for i=1:13
    clim0sink(i,1:11) = calib_csi ( clim0, 2.4+i/10, ocean_csink );
end
for i=1:9
    clim0sink(13+i,1:11) = calib_csi ( clim0, land_csink, 2.1+i/10 );
end
hazardrate=zeros(1,60); % from 1.1 to 7
for i=1:60
    hazardrate(i) = calib_tip(i/10+1);
end

Fex0=Fex; tip_para0=tip_para; bhm0=bhm;

for simu=1:Nm
display(simu);

% only for physics of climate
if simu>1 && Mont~=2 && Mont~=3 && Mont~=4
    FFlux(1)=(3+min(2,max(-2,randn))*0.5/1.96)/deltarf;
    clim0(4)=clim0sink(randi(13),4);
    clim0(5)=clim0sink(randi(9),5);
    Fex(:,1:4)=Fex0(:,1:4)*(1+min(2,max(-2,randn))*0.2/1.96);
    Fex(:,5)=Fex0(:,5)*(1+min(2,max(-2,randn))*0.5/1.96);
    for i=1:Ntip
        qi = (randi(2001)-1)/1000-1; % uniform distribution
        if qi<0
            qi2=tip_para0(i,1)+(tip_para0(i,1)-tip_para0(i,2))*qi;
        else
            qi2=tip_para0(i,1)+(tip_para0(i,3)-tip_para0(i,1))*qi;
        end
        tip_para(i,8) = hazardrate(1,min(60,max(1,floor((qi2-1.1)*10)+1)));
        tip_para(i,6) = tip_para0(i,6)*(1+min(2,max(-2,randn))*0.5/1.96);
        tip_para(i,5) = tip_para0(i,5)*(1+min(2,max(-2,randn))*0.5/1.96);
    end
    negcap=25+((randi(2001)-1)/1000-1)*10;
end
% economic impact of climate change
if simu>1 && Mont~=1 && Mont~=3 && Mont~=4
    bhm(1:2)=bhm0(1:2)*(1+min(2,max(-2,randn))*0.2/1.96);
    for i=1:Ntip
        tip_para(i,7)=tip_para0(i,7)*(1+min(2,max(-2,randn))*0.5/1.96);
    end
end
% dynamics of technological changes
if simu>1 && Mont~=1 && Mont~=2 && Mont~=4
    rlearning=0.2+min(2,max(-2,randn))*0.05/1.96;
    miec=2.5+0.5*min(2,max(-2,randn));
    econo0(22)=mac(1,1)+min(2,max(-2,randn))*(mac(1,1)-mac(1,2))/1.96;
end
% discounting rate
if simu>1 && Mont~=1 && Mont~=2 && Mont~=3
    prtp=0.015+min(2,max(-2,randn))*0.005/1.96;
end

ucpri((ns*2+1):(ns*2+10),simu)=[FFlux(1); clim0(4); clim0(5); negcap; bhm(1); bhm(2); rlearning; miec; econo0(22); prtp];
for i=1:5
    ucpri(ns*2+10+i,simu)=Fex(1,i)/Fex0(1,i);
end
for i=1:Ntip
    for j=1:4
        ucpri(ns*2+15+j+(i-1)*4,simu)=tip_para(i,j+4);
    end
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
    for sce=1:ns
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
    ucpri(sce,simu) = (sum(S(1:286,32,sce),1)-sum(S(1:286,32,1),1)+(S(287,32,sce)-S(287,32,1))/prtp) * scaled1;
    ucpri(sce+ns,simu) = max(S(:,40,sce),[],1);
end

end

save(strcat('dat\ucpri_monte',num2str(Mont),'.dat'),'ucpri');



