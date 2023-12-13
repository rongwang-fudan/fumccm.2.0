% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.6.16

global INT deltarf clim0 FFlux Fex tip_para tip_threshold

% CO2 Forcings of equilibrium CO2 doubling (Wm-2)
deltarf = 3.8;
% Equilibrium sensitivity of climate Sherwood SC, et al.. An Assessment of Earth's Climate Sensitivity Using Multiple Lines of Evidence. Rev Geophys. 2020 Dec;58(4):e2019RG000678.
ESC = 3/deltarf;
% Time inertia of climate system to reach equilibirum (year)
INT = 53; % 53 in OSCAR; 38 in DICE

% threshold of the probability to cross a tipping point
tip_threshold = 0.66;

% Climate data in 2015
%Atmospheric carbon (GtC)
Mat0 = 860;
%Land surface soil carbon (GtC), 100 for active carbon pool from Crowther et al., Nature 2016
Mss0 = 100;
%Land deep soil carbon (GtC), Friedlingstein, et al., Global Carbon Budget 2020
Msd0 = 3600;
%Terrestrial biosphere carbon (GtC)
Mbp0 = 500;
%Shallow ocean carbon (GtC)
Mocs0 = 500 ;
%Deep ocean carbon (GtC)
Mocd0 = 1750;
%Ocean biota carbon (GtC)
Mocb0 = 3;
%Initial atmospheric temperature above 1900
Tat0 = 1;
%Initial temperature of deep oceans
Tlo0 = 0;
% land carbon sink in 2020 GtC/yr
land_csink = 3.1;
% ocean carbon sink in 2020 GtC/yr
ocean_csink = 2.6;
% Carbon: 1 air, 2 surface soil, 3 deep soil, 4 terrestrial biosphere, 5 shallow ocean, 6 deep ocean, 7 ocean biota 
% Temperature: 8 surface air, 9 ocean temperature, 10 land carbon sink, 11, ocean carbon sink
clim0 = [ Mat0, Mss0, Msd0, Mbp0, Mocs0, Mocd0, Mocb0, Tat0, Tlo0, land_csink, ocean_csink ];

% air to surface soil GtC/yr Friedlingstein, GCB 2020
Flux12 = 0; 
% air to land biosphere GtC/yr = NPP from Ciais, NSR, 2020
Flux14 = 50.3; 
% air to surface ocean GtC/yr = NPP from Wang, GRL, 2015
Flux15 = 48.5;
% land biosphere to soil GtC/yr = soil heteo respiration from Ciais, NSR, 2020
Flux42 = 39.1;
% surface soil to deep soil GtC/yr
Flux23 = Flux14*0.05;
% surface ocean to deep ocean GtC/yr
Flux56 = Flux15*0.05;
% deep soil to surface soil GtC/yr
Flux32 = Flux23;
% deep ocean to surface ocean GtC/yr
Flux65 = Flux56;
%Carbon flux between pools
FFlux = [ESC, INT, Flux12, Flux14, Flux15, Flux42, Flux23, Flux56, Flux32, Flux65];

% 1-4: Radiative forcing (W/m2) by 1 CH4, 2 N2O, 3 CFCs, 4 aerosol+O3
% 5: carbon emissions (Gt C/y) from land use change
Fex = zeros(T,5);
for i=1:T
    Fex(i,1) = 0.5*(1.01-min(i,90)/100); % CH4 0.5 W/m2 Table AIII.1a from IPCC-AR6
    Fex(i,2) = 0.2*(1.01-min(i,90)/100); % N2O 0.2 W/m2 Table AIII.1a from IPCC-AR6
    Fex(i,3) = 0.2*(1.01-min(i,90)/100); % CFC 0.2 W/m2 Table AIII.1e from IPCC-AR6
    Fex(i,4) = -0.6*(1.01-min(i,90)/100); % Aerosol -0.6 W/m2 Table AIII.3 from IPCC-AR6
    Fex(i,5) = 1.8*exp(-i*0.023); % Carbon emissions from land use change 1.8 Gt C from Friedlingstein, GCB 2020; decline at 2.3% yr-1
end

% tipping parameters: 1-3 temperature threshold; 4 transition time; 5 temperature feedback; 6 additional CO2 emissions Gt total; 7 damage to the economy; 8 hazard rate
tip_para=[1.5	0.8	3	10000	0.13	0	0.1	0.02372
1.5	1	3	2000	0.05	0	0.05	0.02372
1.8	1.1	3.8	10	-0.5	0	0.1	0.01482
3	2	6	2000	0.05	0	0	0.00593
3.5	2	6	100	0.2	75	0.05	0.00475
4	3	6	50	0.3	250	0	0.00396
3	1.4	8	50	-0.5	0	0.15	0.00396
6.3	4.5	8.7	20	0.6	0	0	0.00224
7.5	5	10	10000	0.6	0	0	0.00183
1.5	1	2	10	0	0	0	0.02372
1.5	1	2.3	200	0.07	341	0	0.02372
1.6	1.5	1.7	25	0	0	0	0.01976
2	1.5	3	200	0.08	0	0	0.01186
2.8	2	3.5	50	0	0	0	0.00659
4	1.4	5	100	-0.18	52	0	0.00396
4	1.5	7.2	100	0.14	-6	0	0.00396];
Ntip=size(tip_para,1);
for i=1:Ntip
    tip_para(i,8) = calib_tip(tip_para(i,1));
end

% calibration of the air-land and air-sea carbon flux
clim0 = calib_csi ( clim0, land_csink, ocean_csink );
