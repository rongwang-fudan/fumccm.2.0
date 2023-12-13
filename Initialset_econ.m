% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.6.16

global alpha prtp elas elasmu theta2 bs0 T L dnpg rou7 fra7 dam7 gnul yyn1 yyn2 nlen nlife iec
global bhm ncss dk_x dk_e dk_green efco20 egreen0 econo0 rlearning negcap miec fsav fcpc fmit ftip falab fainv

% Time horizon 2015-2300
T = 290;

% mitigation-efficiency feedback(0, no; 1, yes)
miec = 1;

% feedback of climate change to saving (0, no; 1, yes)
fsav = 1;

% fraction of emissions from countries involved in carbon pricing
fcpc = 1;

% feedback of climate change to mitigation
fmit = 1;

% feedback of climate tipping points to the economy
ftip = 1;

% feedback of mitigation to labor reallocation
falab = 1;

% feedback of mitigation to investment reallocation
fainv = 1;

% Elasticity of substitution
elas = 0.4;

% Elasticity of output to capital
alpha = 0.3;

% Elasticity of marginal utility of consumption 1.45 (default)
elasmu = 1.45; 

% the pure rate of time preference (0.02 by Rennert2022 and 0.03 by WGA2021 - 0.01)
prtp = 0.015;

% Calibration of the induced efficiency growth
[output_iec, iec] = calib_iec ( alpha, elas  );

% Calibration of the marginal abatement cost curve: 0 without plots; 1 plots
mac = calib_mac ( 0 );

% Coefficient in abatement cost curve
theta2 = mac(2,1);

% Marginal abatement cost to abate 100% emissions $/tCO2
bs0 = mac(1,1);

% rate of installing nuclear power (0.027 TW per year according to IEA)
gnul = 0.027;

% start year of installing nuclear power: use nuclear when yyn1<yyn2
yyn1 = 2100;

% end year of installing nuclear power
yyn2 = 2050;

% Duration to bring the nuclear power into generation
nlen = 10;

% Lifetime of nuclear power plants
nlife = 60;

% regression coefficient for delta_NPG that will have a new accident PWh
dnpg = [0.512 -1.816 0.855];

% fraction of nuclear accidents with INES=7
rou7 = [0.00137 0.00132 0.00131 0.00257 0.00139];

% damage by nuclear accidents with INES=7 in China, USA, Germany, French and Japan billion$
dam7 = [322 311 732 446 842];

% fraction of nuclear accidents with INES=7 to total costs in China, USA, Germany, French and Japan
fra7 = [0.9496 0.9171 0.9355 0.8449 0.8546];

% nuclear costs for power installtion and power generation: 2000 $/kW for construction and 0.0077 $/kWh for uranium cost (51% in operational costs)
ncss = [6.317 0.0158];

% coefficient of the climate economic impact function by Burke, Hsiang and Miguel 2015 + current temperature
bhm = [0.0127 -0.0005 13];

% maximal capacity of negative emissions Gt CO2
negcap = 25;

% rate of non-energy capital depreciation
dk_x = 0.1;

% rate of fossil energy capital depreciation
dk_e = 0.1;

% rate of green energy capital depreciation
dk_green = 0.1;

%Learning rate on the cost curve
rlearning = 0.2;

% fraction of renewable energy
egreen0 = 0.107;

% List of economic variables in 2015
%Total energy (PJ) 582030
e0 = 156 * 3600; % PWh -> PJ
%Energy cost share
se0 = 0.0616;
%saving rate https://databank.worldbank.org/indicator/NY.GDP.PCAP.CD/1ff4a498/Popular-Indicators
sav0 = 0.24;
%Fossil fuel emissions (Gt CO2 per year)
IE0 = 35; % 34.91 in DICE2013
% CO2 emission factors for fossil fuel only 6.9884e-5 tCO2 / MJ
efco20 = IE0 / e0 / (1-egreen0);
%Fraction of climate damage 0.00267*1^2
D0 = 0;
% population (millions)
L0 = 7334;
% total output (trill 2010 USD)
q0 = 105 / (1-D0);
%Initial capital stock ($ trillion 2010 USD) 210 in Wang2019
K0 = 220 ;
% K0 = q0 * 0.258 / dk_e;
%Initial level of total factor productivity
A0 = q0 / (K0^alpha) / (L0/1000)^(1-alpha);
%Energy price $/kWh
pe0 = 0.0413;
%Energy use efficiency $ / KJ
eue0 = se0^(elas/(elas-1)) / (e0/q0); 
%Energy production efficiency PJ / (trillion $)^0.3 / (billion cap)^0.7
epe0 = (A0^(elas-1) * se0)^(1/(elas-1)) / eue0; 
%Non-energy efficiency (trillion $)^0.7 / (billion cap)^0.7
ene0 = (A0^(elas-1) * (1-se0))^(1/(elas-1));
%Capital for Energy Production
Ke0 = K0 * se0;
%Labor allocation to energy
Le0 = se0;
%Investment allocation to energy
Ve0 = se0;
%Capital for carbon-emission-free energy
Kgreen0 = Ke0 * egreen0;
%Fraction of CO2 abatements
acta0 = egreen0;
%Carbon price $/tCO2
pc0 = bs0 * acta0^(theta2-1);
%Abatement cost as a percentage of GDP
abate0 = bs0 / theta2 * acta0^theta2  * e0 / q0 * efco20 / 1000;
%Net output
qnet0 = q0 * (1-D0);
%green energy PJ
egc0 = e0 * egreen0;

% Initital economic variables in 2015
% 1 EUE; 2 EPE; 3 ENE; 4 saving rate;
% 5 abatement cost as a percentage of GDP; 6 climate damage as a percentage of GDP; 7 net output
% 8 fraction of labor allocation to energy; 9 fraction of investment allocation to energy
% 10 capital (trill $); 11 energy capital (trill $); 12 energy (PJ); 13 output (t$); 14 energy price $/kWh; 15 omega
% 16 fraction of energy investment allocated to carbon-emission-free energy; 17 energy capital carbon-emission-free (trill $)
% 18 fraction to abate CO2 emission; 19 carbon price $/tCO2; 20 CO2 emissions Gt CO2; 21 green energy PJ; 22 backstop price $/tCO2
econo0 = [eue0, epe0, ene0, sav0, 0, D0, qnet0, Le0, Ve0, K0, Ke0, e0, q0, pe0, se0, egreen0, Kgreen0, acta0, pc0, IE0, egc0, bs0];

%Peak population
LA = 11500;

%Population (millions)
L = zeros(T,1);
L(1)=L0;

%calibrated to meet the rate of growth in 2015 using data observed by IEA
Lg0 = 0.0254;

for i=2:T
    L(i,1) = L(i-1,1) * (LA/L(i-1,1))^Lg0;
end