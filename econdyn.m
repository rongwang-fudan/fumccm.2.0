% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.7.10

function econo2  =  econdyn( t1, econo1, fracinv, cpc, deltaT, damagetip )
%   Finds the next state (t1+1) given the current state and actions at time t1
%   fracinv: Fraction of investment allocated to low-carbon energy
%   deltaT:  atm temperature
%   damagetip:  damage by tipping
%   ncap:  growth rate of installed nuclear power (0.027 TW per year according to IEA)
%   ncap2:  rate of installing nuclear power

global prtp dnpg rou7 fra7 dam7 gnul yyn1 yyn2 nlen nlife bhm ncss negcap efco20 econo0 alpha elas elasmu rlearning
global theta2 cesin dk_x dk_e dk_green iec L T miec fsav fcpc fmit ftip falab fainv
%   econo:  economic variables over time
%   iec:  rates of induced efficiency changes
%   1 EUE; 2 EPE; 3 ENE; 4 saving rate;
%   5 abatement cost as a percentage of GDP; 6 climate damage as a percentage of GDP; 7 net output
%   8 fraction of labor allocation to energy; 9 fraction of investment allocation to energy
%   10 capital (trill $); 11 energy capital (trill $); 12 energy (PJ); 13 output (t$); 14 energy price $/kWh; 15 omega
%   16 fraction of energy investment allocated to low-carbon energy; 17 energy capital low-carbon (trill $)
%   18 fraction to abate CO2 emission; 19 carbon price $/tCO2; 20 CO2 emissions Gt CO2; 21 green energy PJ; 22 backstop price $/tCO2
%   23 new nuclear power TW; 24 nuclear capacity factor; 25; nuclear power generation PWh; 26 nuclear-abated CO2 emissions Gt CO2; 27 accumulated nuclear power PWh
%   28 number of accident INES=7; 29 nuclear accident costs % to GDP; 30 nuclear installation costs % to GDP; 31 nuclear operation costs % to GDP
%   32 discounted population weighted utility of per capita consumption
%   efco20:  CO2 emission factors for fossil fuel only tCO2 / MJ
%   alpha:  elasticity of output to capital
%   elas:   elasticity of substitution between energy and non-energy in output
%   L:  population (millions)
%   cesin:  input variables 1ke, 2kx, 3eue, 4epe, 5ene, 6dk_x, 7dk_e

%Time step (year)
tstep = 1;
tyear = t1+2014;
tpop  = L(min(T,t1));
tpop2  = L(min(T,t1+1));

%Economic variables
econo2 = zeros(1,23);

%Impact of warming on the productivity: bhm 1-2 for ax+bx2; bhm 3 for preindustrial temperature 
dpwarm = (bhm(1)*deltaT+bhm(2)*((deltaT+bhm(3))^2-bhm(3)^2));

%Carbon price induces more CO2 emission abatements
fracinv2 = max(fracinv, (cpc/econo1(22))^(1/(theta2-1))); 

%Feedback of climate change to mitigation capacity
if (damagetip*fmit)>0.1
    fracinv=(0.01/(econo1(22) * (econo1(12) / econo0(12))^(theta2-1) / theta2  * econo1(12) * efco20 / 1000 / econo1(13)))^(1/theta2);
    fracinv2=fracinv;
end

%EUE rate with the inducing effects
euerate = iec(1,1)+iec(1,2)*log10(econo1(5)+econo1(15));

%ENE rate with the inducing effects
enerate = iec(3,1)+iec(3,2)*log10(1-econo1(5)-econo1(15));

%feedback of mitigation to efficiencies
if miec==0
    euerate = iec(1,1)+iec(1,2)*log10(econo1(15));
    enerate = iec(3,1)+iec(3,2)*log10(1-econo1(15));
elseif miec>=2 && miec<=3
    euerate = euerate + (5-miec*2)*(euerate-iec(1,1)-iec(1,2)*log10(econo1(15))) * (iec(1,4)-iec(1,2))/iec(1,2)/1.96;
    enerate = enerate + (5-miec*2)*(enerate-iec(3,1)-iec(3,2)*log10(1-econo1(15))) * (iec(3,4)-iec(3,2))/iec(3,2)/1.96;
end

%EUE $ / KJ
econo2(1) = econo1(1)*(1+dpwarm+euerate);

%EPE PJ / (trillion $)^0.3 / (billion cap)^0.7
econo2(2) = econo1(2);

%ENE (trillion $)^0.7 / (billion people)^0.7
econo2(3) = econo1(3)*(1+dpwarm+enerate);

%Costs of renewables as a percentage to output
if fcpc<1
    econo2(5) = econo1(22) * (econo1(12) / econo0(12))^(theta2-1) / theta2 * (fcpc*fracinv2^theta2+(1-fcpc)*fracinv^theta2) * econo1(12) * efco20 / 1000 / econo1(13);
else
    econo2(5) = econo1(22) * (econo1(12) / econo0(12))^(theta2-1) / theta2 * econo1(18)^theta2 * econo1(12) * efco20 / 1000 / econo1(13);
end

%Impact of warming on the productivity: bhm 1-2 for ax+bx2; bhm 3 for preindustrial temperature
econo2(6) = damagetip;

%Economic net output minus damage and abatement
econo2(7) = (1-econo2(5))*(1-econo2(6)*ftip)*(1-econo1(29)-econo1(30)-econo1(31))*econo1(13);

%Investment trill $
I = econo2(7) * econo1(4);

%Equivalent energy price $/(kJ total energy)
carbonprice = efco20 * (econo1(19)-econo0(19)) / 1000  * max(0,1-econo1(18));

%Parameters for labor/investment allocation: 1ke, 2kx, 3eue, 4epe, 5ene, 6investment, 7labor, 8timestep, 9carbonprice
cesin = [econo1(11),econo1(10)-econo1(11),econo2(1),econo2(2),econo2(3),I, tpop/1000,tstep, carbonprice ];

%Optimal allocation of labor and investments
allo = ces_allocation(1/(1+(econo2(3)/econo2(1)/econo2(2))^(elas-1)), 1); % 0 for percentile decimal, 1 for thousand decimal

%Feedback of mitigation to labor reallocation
if falab==0
    allo(1)=econo0(8);
end

%Feedback of mitigation to investment reallocation
if fainv==0
    allo(2)=econo0(9);
end

%Allocation of labor to produce energy
econo2(8) = allo(1);

%Allocation of investment to produce energy
econo2(9) = allo(2); % initialization

%Capital trill $
econo2(10) = tstep * I + (1 - dk_x) ^ tstep * (econo1(10)-econo1(11)) + (1 - dk_e) ^ tstep * econo1(11);

%Energy capital trill $
econo2(11) = tstep * I * econo2(9) + (1 - dk_e) ^ tstep * econo1(11);

%Energy PJ/yr
econo2(12) = econo2(2) * econo2(11)^alpha * ( tpop*econo2(8)/1000)^(1-alpha);

%Non-Energy production
X = econo2(3) * (econo2(10) - econo2(11))^alpha * ( tpop*(1-econo2(8))/1000)^(1-alpha);

%Output trill$/yr
econo2(13) = ((econo2(1)*econo2(12))^((elas-1)/elas) + X^((elas-1)/elas))^(1/((elas-1)/elas));

%Energy price $/kWh
econo2(14) = econo2(1) * (1 + (X/econo2(12)/econo2(1))^(1-1/elas))^(1/(elas-1)) *3600;

%Share of energy expenditure in GDP
econo2(15) = econo2(14) / 3600 * econo2(12) / econo2(13);

%Fraction of energy investment allocated to low-carbon energy
econo2(16) = min(1, fracinv2);

%Capital low-carbon energy (trill$)
econo2(17) = tstep * I * econo2(9) * (econo2(16) * fcpc + fracinv * (1-fcpc)) + (1-dk_green)^tstep * econo1(17);

%Fraction of low-carbon energy
econo2(18) = econo2(17) / econo2(11);

%Ratio of negative emission with a limit
if fracinv2>1
    econo2(18) = econo2(18) * min((fracinv2-1) * fcpc + 1, 1+negcap*fcpc/efco20/econo2(12));
end

%Reduce negative emissions when warming falls below 0.8C
if deltaT<1
    econo2(18)=econo1(18)^0.8;
end

%Marginal abatement cost $ per tCO2
econo2(19) = econo1(22) * (econo2(18) * econo2(12) / econo0(12))^(theta2-1);

%Industrial emission GtCO2/yr
econo2(20) = efco20 * econo2(12) * (1-econo2(18));

%Low-carbon energy PJ
econo2(21) = econo2(12) * econo2(17) / econo2(11);

%Marginal cost to abate CO2 emissions with learning ($/tCO2): Moore's learning for coal energy from 1900 to 1940 by Way 2021 (0.25^(1/40))
if tyear>=2020
    econo2(22) = econo1(22) * min(1,(econo2(21) / econo1(21))^(log2(1-rlearning)));
else
    econo2(22) = econo1(22);
end

%Use nuclear when yyn1<yyn2
ncapuse=0; ncapcost=0; ncapretire=0;
if (tyear-nlen)>=yyn1 && (tyear-nlen)<=yyn2
    ncapuse=gnul; % growth rate of using nuclear power
end
if tyear>=yyn1 && tyear<=yyn2
    ncapcost=gnul; % rate of installing nuclear power
end
if (tyear-nlife-nlen)>=yyn1 && (tyear-nlife-nlen)<=yyn2
    ncapretire=gnul; % growth rate of retiring nuclear power
end

%New nuclear power TW
econo2(23) = max(0,econo1(23)+ncapuse-ncapretire);

%Capacity factor based on 365*24/1000=8.76 and FF CO2 emission factor of 0.8433 t CO2 / MWh  based on a capacity factor of 85% for the future (Koomey,2007)
econo2(24) = max(0,min(0.85, econo2(20) / max(0.000001, econo2(23) * 8.76 * 0.8433)));

%Nuclear power generation PWh
econo2(25) = econo2(23) * 8.76 * econo2(24);

%Abated CO2 emissions by new nuclear GtCO2/yr based on FF CO2 emission factor of 0.8433 t CO2 / MWh
econo2(26) = econo2(25) * 0.8433;

%Industrial emission after using nuclear power GtCO2/yr
econo2(20) = econo2(20) - econo2(26);

%Accumulation of nuclear power PWh after 2025
econo2(27) = econo1(27) + econo2(25);

%Delta_NPG that will have a new accident PWh (84 PWh by 2020 for 7 countries)
delta_NPG = 10^(dnpg(1) * log10(econo1(27)/7+12) + dnpg(2));

%Numbers of nuclear accident with INES=7 based on rou7
econo2(28) = econo1(28)+econo2(25)/delta_NPG*mean(rou7,2);

%Damage of all nuclear accidents as a percentage to GDP
econo2(29) = (floor(econo2(28))-floor(econo1(28))) * mean(dam7,2) / 1000 / mean(fra7,2) / econo2(13);

%Costs of nuclear power installation as a percentage to GDP
econo2(30) = ncapcost * ncss(1) / econo2(13);

%Costs of nuclear power generation as a percentage to GDP
econo2(31) = econo2(25) * ncss(2) / econo2(13);

%Discounted population-weighted utility of per capita consumption
econo2(32) =  ((econo2(7)*(1-econo1(4))/tpop*1000)^(1-elasmu))/(1-elasmu) * tpop/1000/(1+prtp)^max(0,(tyear-2025)); % utility discounted to 2025

%Growth of per capita output
dlny_dt=(econo2(13)/tpop2)/(econo1(13)/tpop)-1;

%Change rate of investment based on the rate of per capita consumption: dlnc/dt
dln1s_dt = (alpha*econo1(13)/econo1(10)-dk_x-prtp)/elasmu * 0.8253 - 0.0097 - dlny_dt;

%saving rate
if fsav==1
    econo2(4) = max(0.1,min(0.4,1-(1-econo1(4))*(1-dln1s_dt)));
else
    econo2(4) = econo1(4);
end

end



