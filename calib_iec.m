% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.6.18

function [output_iec, iec] = calib_iec ( alpha, elas )
%   iec:  regresssion coefficients
%   output_iec: output of iec variables for model calibration
%   xy_iec: the rate of efficiency change agains omega

plots = 0;

%   inputs 45x6; 1 energy PWh; 2 capital trill $; 3 GDP trill $; 4 population mill; 5 energy price ($/kWh); 6 omega
%   alpha:  elasticity of output to capital
%   elas:   elasticity of substitution between energy and non-energy in output

inputs=[62.17742872	32.12154386	23.32359385	3758.456714	0.020205042	0.053872267	19.99870207
65.72953575	33.13073031	24.94313803	3835.803943	0.020743036	0.054690168	20.26185878
68.24960163	34.56299242	26.22267335	3912.177886	0.022506037	0.058512221	20.79517635
69.3658089	36.51983857	27.1021702	3987.821686	0.026346774	0.067360348	21.64404119
70.64836963	38.65745015	27.8713674	4061.833029	0.028947431	0.073413895	22.61074099
73.35446495	40.44104209	29.03206902	4134.779343	0.029301276	0.074035511	23.37830869
76.75718923	42.13139772	30.4548923	4207.601171	0.02922516	0.07366408	24.09300607
79.64526992	44.42691435	31.70763974	4281.448114	0.030351912	0.076286714	25.13702619
81.59750886	47.44311013	32.81179912	4357.157	0.034296883	0.085231304	26.5592131
81.86502109	50.72900655	33.65749738	4434.151429	0.040200051	0.097667869	28.10479952
81.25954574	53.41519166	34.12425517	4512.831943	0.043433786	0.10345728	29.28479226
81.22560163	55.20955975	34.63418765	4593.254943	0.042702681	0.100181818	29.94516754
82.71037932	55.69257023	35.55009451	4674.7152	0.040655961	0.094599339	29.88975867
85.26136717	55.69202388	36.90403469	4756.240371	0.03926042	0.090674446	29.5902763
87.74436802	55.68585521	38.2847686	4840.065229	0.036620701	0.083975087	29.28747675
89.99405275	57.09975478	39.54464012	4926.6436	0.033523	0.07629887	29.70741317
93.00704382	59.56640911	40.98901355	5015.032114	0.030816552	0.069905974	30.64005726
95.98604228	62.7120099	42.58743481	5103.797629	0.030300072	0.068308604	31.89420647
98.14139961	65.62480956	44.30227509	5191.5954	0.030821905	0.068255327	32.97698727
99.52511172	68.42726675	45.53922868	5278.090429	0.031636642	0.069133285	33.97248021
100.2267982	70.95122761	46.37372158	5364.9678	0.031184115	0.067410163	34.82486494
100.5825323	73.27401654	46.9704052	5451.749886	0.030125995	0.064510465	35.60607951
101.0124582	76.0343584	47.97228661	5536.265943	0.029581319	0.062286899	36.59849048
102.3723403	79.75588563	49.27529472	5618.6608	0.02906853	0.060405848	38.04339052
104.5812335	84.58987329	50.95595874	5700.923914	0.029124363	0.059760201	39.99586735
107.0275728	89.22866484	52.92957227	5783.269171	0.029785008	0.060206916	41.82728539
108.1700017	92.81599159	54.77109178	5865.418943	0.029159772	0.057631162	43.14708747
109.0757153	95.51119921	56.43907143	5947.035057	0.027421755	0.053025093	44.04906754
110.9877589	98.11136959	58.5029114	6027.872829	0.028349551	0.053736064	44.91175775
113.2461118	101.343128	60.78110797	6107.830314	0.031413356	0.058487751	46.06722033
115.0286447	104.7219331	62.67842663	6187.122829	0.031902764	0.058583637	47.28554243
117.3868387	107.6183046	64.32238782	6266.181257	0.031347937	0.057216914	48.28158471
121.6583363	110.4571881	66.90118606	6345.5068	0.032803106	0.059665287	49.24859346
126.4326109	115.7581556	70.12177204	6425.154229	0.037579662	0.067747656	51.30041776
130.6227186	124.5463493	73.78331389	6505.1326	0.042429439	0.07506518	54.86797073
134.2866441	136.4552067	77.82729142	6585.5138	0.045566768	0.078687211	59.76233741
137.7534487	149.8047327	81.81159969	6666.644771	0.05013576	0.084369034	65.22979263
138.6218894	162.4069456	83.64681441	6748.528771	0.049263148	0.081641136	70.32058303
140.9094669	171.4956107	85.19452021	6830.877229	0.046985236	0.077738864	73.85862977
144.6913683	178.24561	88.02408854	6913.443486	0.046852121	0.076957913	76.37947544
149.3127479	185.7765407	92.06831083	6996.219571	0.051967746	0.084244975	79.22005706
151.3051974	195.80611	95.14315183	7079.479857	0.053048469	0.08439159	83.10609342
153.4562456	207.1077508	98.18104554	7163.622914	0.052037329	0.081277632	87.48506143
155.2786201	217.6138537	101.5155219	7248.388057	0.047905426	0.073373809	91.49809037
156.7320234	227.8516403	105.05819	7333.865486	0.041280974	0.061577747	95.36760118];

lra=zeros(26,7);

for i=1:26
    x=[(1970+i):(1989+i)]; y=inputs(i:(i+19),5); [sR,lr_pe0,bb0] = regression(x,log(y'));
    y=inputs(i:(i+19),1)./inputs(i:(i+19),4); [sR,lr_e0,bb0] = regression(x,log(y')); % e=E/L
    y=inputs(i:(i+19),3)./inputs(i:(i+19),4); [sR,lr_y0,bb0] = regression(x,log(y')); % y=Y/L
    y=inputs(i:(i+19),6); avef0=mean(y,1); startf0=inputs(i,6); startpe0=inputs(i,5); % omega
    y=inputs(i:(i+19),7); [sR,lr_k0,bb0] = regression(x,log(y')); % k=K/L
    lr_se0 = lr_pe0 + lr_e0 - lr_y0;
    lr_B = lr_e0 - alpha*lr_k0;
    lr_A = lr_y0 - alpha*lr_k0;
    lr_taue0 = elas/(elas-1)*lr_se0 - lr_e0 + lr_y0;
    lr_we0 = lr_B - lr_se0;
    lr_b0 = (lr_A - avef0*(lr_we0 + lr_taue0))/(1-avef0);
    lra(i,1) = startf0;
    lra(i,2) = lr_taue0;
    lra(i,3) = lr_we0;
    lra(i,4) = lr_b0;
    lra(i,5) = 0; % damage of climate change
    lra(i,6) = lra(i,1);
    lra(i,7) = 1-lra(i,1);
    lra(i,8) = lr_se0;
end
xy_iec=zeros(26,10);
xy_iec(:,1)=lra(:,2); % eue rate
xy_iec(:,2)=lra(:,3); % epe rate
xy_iec(:,3)=lra(:,4); % ene rate
xy_iec(:,4)=lra(:,6); % omega
xy_iec(:,5)=lra(:,7); % 1 - omega
xy_iec(:,6)=lra(:,8); % omega rate

omegas=(-1.52:0.01:-0.82); sn=size(omegas,2);
omegas2=(-0.071:0.001:-0.013); sn2=size(omegas2,2);
iec=zeros(3,8); % 1:2 linear regression coefficient; 3-6 uncertainty in the linear regression coefficient; 7-8 min and max of x

% EUE
x=log10(lra(:,6)); y=lra(:,2);
[b22,bint22,r22,rint22,statseue] = regress(y,[ones(26,1) x]);
iec(1,1:2)=b22(1:2,1); iec(1,3:4)=bint22(1:2,1); iec(1,5:6)=bint22(1:2,2); iec(1,7)=min(x,[],1); iec(1,8)=max(x,[],1);
[b2eue, Seue]=polyfit(x,y,1);
xeue=[-1.28:0.002:-0.98]; [yfiteue, deltaeue]=polyconf(b2eue,xeue,Seue,'alpha',0.05,'predopt','curve');
xy_iec(:,7)=polyval(b2eue,x);

% EPE
y=lra(:,3);
[b22,bint22,r22,rint22,statsepe] = regress(y,[ones(26,1) x]);
iec(2,1:2)=b22(1:2,1); iec(2,3:4)=bint22(1:2,1); iec(2,5:6)=bint22(1:2,2); iec(2,7)=min(x,[],1); iec(2,8)=max(x,[],1);
[b2epe, Sepe]=polyfit(x,y,1);
xepe=[-1.28:0.002:-0.98]; [yfitepe, deltaepe]=polyconf(b2epe,xepe,Sepe,'alpha',0.05,'predopt','curve');
xy_iec(:,8)=polyval(b2epe,x);

% ENE
x=log10(lra(:,7)); y=lra(:,4);
[b22,bint22,r22,rint22,statsene] = regress(y,[ones(26,1) x]);
iec(3,1:2)=b22(1:2,1); iec(3,3:4)=bint22(1:2,1); iec(3,5:6)=bint22(1:2,2); iec(3,7)=min(x,[],1); iec(3,8)=max(x,[],1);
[b2ene, Sene]=polyfit(x,y,1);
xene=[-0.05:0.002:-0.02]; [yfitene, deltaene]=polyconf(b2ene,xene,Sene,'alpha',0.05,'predopt','curve');
xy_iec(:,9)=polyval(b2ene,x);

if plots==1
    subplot(1,3,1);
    x=log10(xy_iec(:,4));
    y=xy_iec(:,1); % EUE rates    
    xconf = [xeue xeue(end:-1:1)] ; 
    yconf = [yfiteue+deltaeue yfiteue(end:-1:1)-deltaeue];
    p = fill(xconf,yconf,'red'); hold on;
    p.FaceColor = [1 0.8 0.8];      
    p.EdgeColor = 'none'; 
    plot(xeue,yfiteue,'k-','LineWidth',3); hold on;
    plot(x,y,'o','MarkerEdgeColor',[0.8 0 0],'MarkerFaceColor','none','MarkerSize',3); hold on;
    title(['function: ',texlabel(strcat('function:',num2str(round(b2eue,4)),',r2=',num2str(round(statseue(1),4))))]);
    
    subplot(1,3,2);
    x=log10(xy_iec(:,4));
    y=xy_iec(:,2); % EPE rates
    xconf = [xepe xepe(end:-1:1)] ; 
    yconf = [yfitepe+deltaepe yfitepe(end:-1:1)-deltaepe];
    p = fill(xconf,yconf,'red'); hold on;
    p.FaceColor = [1 0.8 0.8];
    p.EdgeColor = 'none'; 
    plot(xepe,yfitepe,'k-','LineWidth',3); hold on;
    plot(x,y,'o','MarkerEdgeColor',[0.8 0 0],'MarkerFaceColor','none','MarkerSize',3); hold on;
    title(['function: ',texlabel(strcat('function:',num2str(round(b2epe,4)),',r2=',num2str(round(statsepe(1),4))))]);

    subplot(1,3,3);
    x=log10(xy_iec(:,5));
    y=xy_iec(:,3); % ENE rates
    xconf = [xene xene(end:-1:1)] ; 
    yconf = [yfitene+deltaene yfitene(end:-1:1)-deltaene];
    p = fill(xconf,yconf,'red'); hold on;
    p.FaceColor = [1 0.8 0.8];      
    p.EdgeColor = 'none'; 
    plot(xene,yfitene,'k-','LineWidth',3); hold on;
    plot(x,y,'o','MarkerEdgeColor',[0.8 0 0],'MarkerFaceColor','none','MarkerSize',3); hold on;
    title(['function: ',texlabel(strcat('function:',num2str(round(b2ene,4)),',r2=',num2str(round(statsene(1),4))))]);
end

% %Initial states
% pop = inputs(1,4);
% E = inputs(1,1)*3600; % energy PJ
% Y = inputs(1,3); % gross output (trill 2010 USD)
% K = inputs(1,2);
% A = Y / (K^alpha) / ( pop/1000 )^(1-alpha);
% se=inputs(1,6); %Share of energy expenditure in GDP
% eue=se^(elas/(elas-1)) / (E/Y); %Energy use efficiency $ / KJ
% epe=(A^(elas-1) * se)^(1/(elas-1)) / eue; 
% ene=(A^(elas-1) * (1-se))^(1/(elas-1));
% pe=inputs(1,5); %Energy price $/kWh
% 
% %Calibration of the model
output_iec=zeros(45,10); % 1-5 for model; 6-10 for observations
% output_iec(1,1:10) = [eue, epe, ene, se, pe, eue, epe, ene, se, pe];
% 
% for i=1:44
%     if i<=10
%         omega = inputs(1,6)+(inputs(2,6)-inputs(1,6))*(i-11);
%     else
%         omega = inputs(i-10,6);
%     end
%     output_iec(i+1,1)= output_iec(i,1)*(1+polyval(iec(1,1:3), min(max(log10(omega),iec(1,4)),iec(1,5))  ));
%     output_iec(i+1,2)= output_iec(i,2)*(1+polyval(iec(2,1:3), min(max(log10(omega),iec(2,4)),iec(2,5))  ));
%     output_iec(i+1,3)= output_iec(i,3)*(1+polyval(iec(3,1:3), min(max(log10(1-omega),iec(3,4)),iec(3,5))  ));
%     output_iec(i+1,4)= 1/(1+(output_iec(i+1,3)/output_iec(i+1,1)/output_iec(i+1,2))^(elas-1)); % omega
%     output_iec(i+1,5)= output_iec(i+1,1) / output_iec(i+1,4)^(1/(elas-1)) *3600; % energy price $/KJ -> $/kWh    
%     %
%     pe = inputs(i+1,5); % $/kWh
%     se = inputs(i+1,6);
%     K = inputs(i+1,2); % capital stock ($ trillion 2010 USD)
%     E = inputs(i+1,1)*3600; % energy PJ
%     Y = inputs(i+1,3); % gross output (trill 2010 USD)
%     pop = inputs(i+1,4);
%     A = Y / (K^alpha) / ( pop/1000 )^(1-alpha); %Initial level of total factor productivity
%     eue = se^(elas/(elas-1)) / (E/Y); %Energy use efficiency $ / KJ
%     epe = (A^(elas-1) * se)^(1/(elas-1)) / eue; %Energy production efficiency PJ / (trillion $)^0.3 / (billion cap)^0.7
%     ene = (A^(elas-1) * (1-se))^(1/(elas-1)); %Non-energy efficiency (t$)^0.7/(billion cap)^0.7        
%     %
%     output_iec(i+1,6)= eue;
%     output_iec(i+1,7)= epe;
%     output_iec(i+1,8)= ene;
%     output_iec(i+1,9)= se;
%     output_iec(i+1,10)= pe;    
%     i=i+1;
% end
% 
% output_iec(:,1) = output_iec(:,1) * 3600; % EUE $/KJ -> $/kWh
% output_iec(:,6) = output_iec(:,6) * 3600; % EUE $/KJ -> $/kWh
% output_iec(:,2) = output_iec(:,2) / 3600; % EPE PJ/(t$)^0.3 / (billion cap)^0.7 -> PWh/(t$)^0.3 / (billion cap)^0.7
% output_iec(:,7) = output_iec(:,7) / 3600; % EPE PJ/(t$)^0.3 / (billion cap)^0.7 -> PWh/(t$)^0.3 / (billion cap)^0.7

end



