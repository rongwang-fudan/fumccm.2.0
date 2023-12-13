% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.2.10

function clim2  =  climdyn( t1, clim1, clim0, IE, rff )
%   Finds the next state (t1+1) given the current state and actions at time t1
%   IE:  fossil fuel CO2 emissions Gt CO2
%   rff:  ratio of fossil fuel change
%   clim1:  climate variables at time t1
%   clim2:  climate variables at time t1+1
%   Carbon: 1 air, 2 surface soil, 3 deep soil, 4 terrestrial biosphere, 5 shallow ocean, 6 deep ocean, 7 ocean biota 
%   Temperature: 8 atmospheric temperature, 9 ocean temperature
%   Flux: 10 land sink GtC/yr; 11 ocean sink GtC/yr
%   Tipping: 12-27 probability for 16 tipping points; 28-43 crossing year; 44 CO2 emissions Gt C; 45 temperature feedback; 46 damage as a % to GDP

global  Fex deltarf FFlux tip_para tip_threshold
%   realtime:  time
%   Eland: land use change emissions Gt C
%   Fex: Radiative forcing by 1 CH4, 2 N2O, 3 CFCs, 4 aerosol

tstep = 1;

%Economic variables
clim2 = zeros(1,46);

%ESC: Climate Sensitivity
ESC = FFlux(1);
% time to achieve climatic equilibrium
INT = FFlux(2);
% air to surface soil GtC/yr Friedlingstein, GCB 2020
Flux12 = FFlux(3);
% air to land biosphere GtC/yr = NPP from Ciais, NSR, 2020
Flux14 = FFlux(4);
% air to surface ocean GtC/yr = NPP from Wang, GRL, 2015
Flux15 = FFlux(5);
% land biosphere to soil GtC/yr = soil heteo respiration from Ciais, NSR, 2020
Flux42 = FFlux(6);
% surface soil to deep soil GtC/yr
Flux23 = FFlux(7);
% surface ocean to deep ocean GtC/yr
Flux56 = FFlux(8);
% deep soil to surface soil GtC/yr
Flux32 = FFlux(9);
% deep ocean to surface ocean GtC/yr
Flux65 = FFlux(10);

%Parameterizations by Ken Calderia (Estimating the Contribution of Sea Ice Response to Climate Sensitivity, 2014)
%Coefficient of heat loss from atmosphere to oceans
etha3 = 0.088 * ESC;
%Coefficient of heat gain by deep oceans (year-1)
etha4 = 0.005;

% Preindustrial atmospheric CO2 = 860 (Friedlingstein, GCB 2020) - 240 (IPCC-AR5-Table 6.1)
CO2pre = clim0(1) - 240;

%Rate of carbon exchange between pools (% of carbon year-1)
%Carbon: 1 air, 2 surface soil, 3 deep soil, 4 terrestrial biosphere, 5 shallow ocean, 6 deep ocean, 7 ocean biota
b12=Flux12/clim0(1); b14=(Flux14+clim0(10))/clim0(1); b15=(Flux15+clim0(11))/clim0(1); b21=(Flux12+Flux42)/clim0(2); b23=Flux23/clim0(2); b24=0; b32=Flux32/clim0(3);
b41=(Flux14-Flux42)/clim0(4); b42=Flux42/clim0(4); b51=Flux15/clim0(5); b56=Flux56/clim0(5); b65=Flux65/clim0(6);

Fex0=Fex(1,1:5)*rff;

%Total emission to atmosphere = industrial emission Gt C + land use change emissions Gt C
E = (IE/3.666+Fex0(1,5))*tstep;  % Gt C

%Atmospheric carbon Gt C
clim2(1) = clim1(1)+(E+clim1(44)+b21*clim1(2)+b41*clim1(4)+b51*clim1(5)-(b12+b14+b15)*clim1(1))*tstep;

%Surface soil carbon Gt C
clim2(2) = clim1(2)+(b12*clim1(1)+b32*clim1(3)+b42*clim1(4)-(b21+b23+b24)*clim1(2))*tstep;

%Deep soil carbon Gt C
clim2(3) = clim1(3)+(b23*clim1(2)-b32*clim1(3)-Fex0(1,5)-clim1(44))*tstep;

%Terrestrial biosphere carbon Gt C
clim2(4) = clim1(4)+(b14*clim1(1)-(b41+b42)*clim1(4))*tstep;

%Shallow ocean carbon Gt C
clim2(5) = clim1(5)+(b15*clim1(1)+b65*clim1(6)-(b51+b56)*clim1(5))*tstep;

%Deep ocean carbon Gt C
clim2(6) = clim1(6)+(b56*clim1(5)-b65*clim1(6))*tstep;

%Ocean biota carbon Gt C
clim2(7) = clim1(7) * clim2(5) / clim1(5);

%Biota-ocean carbon exchange Gt C
clim2(5) = clim2(5) + (clim1(7)-clim2(7));

%Radiative forcing
F = deltarf * log(clim2(1)/CO2pre)/log(2) + sum(Fex0(1,1:4),2);

%Atmospheric temperature
clim2(8) = max(0.005,clim1(8)+(ESC*F-clim1(8)-etha3*(clim1(8)-clim1(9)))/INT*tstep) + clim1(45);

%Deep ocean temperature
clim2(9) = max(0.00001,clim1(9)+etha4*(clim1(8)-clim1(9))*tstep);

%Land carbon sink GtC/year
clim2(10) = (b12+b14)*clim1(1)-b21*clim1(2)-b41*clim1(4);

%Ocean carbon sink GtC/year
clim2(11) = b15*clim1(1)-b51*clim1(5);

%Tipping: 12-27 probability for 16 tipping points; 28-43 crossing year
%44 additional CO2 emissions; 45 temperature feedback; 46 economic damage as a % to GDP
for tip_i=1:size(tip_para,1)
    % Accumulating the impact of tipping
    if clim1(1,tip_i+11)>tip_threshold
%     if clim2(8)>tip_para(tip_i,1) || clim1(1,tip_i+27)>0
        % the first year to cross this tipping point
        if clim1(1,tip_i+27)==0
            clim2(1,tip_i+27)=t1;
        else
            clim2(1,tip_i+27)=clim1(1,tip_i+27);
        end
        % Emissions Gt CO2 and temperature feedback  after crossing a tipping point
        if (t1-clim2(1,tip_i+27))<=tip_para(tip_i,4)
            clim2(44) = clim2(44) + tip_para(tip_i,6)/tip_para(tip_i,4); % emission Gt C
            clim2(45) = clim2(45) + tip_para(tip_i,5)/tip_para(tip_i,4); % temperature feedback
        end
        %Accumulating the damage by each tipping point
        clim2(46) = 1 - (1-clim2(46)) * (1-tip_para(tip_i,7) * min(1,(t1-clim2(1,tip_i+27))/tip_para(tip_i,4)));
    end
    % Accumulating the probability of tipping
    clim2(1,tip_i+11)=1-(1-clim1(1,tip_i+11))*exp(-tip_para(tip_i,8)*max(0,clim2(8)-1));  
end

end
