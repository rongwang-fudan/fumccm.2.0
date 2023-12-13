% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2021.6.18

function mac = calib_mac ( plots )

% theta2: Coefficient in abatement cost curve
% bs0: Marginal abatement cost to abate 100% emissions in 2015 $/tCO2

inputs2=[1	500	1.066666667
1	450	1.058333333
1	400	1.05
1	350	1.033333333
1	300	1.016666667
1	250	0.991666667
1	200	0.908333333
1	150	0.825
1	100	0.7
1	50	0.458333333
1	0	0.075
1	-50	0.066666667
1	-100	0.016666667
2	500	1.0625
2	400	1.00625
2	300	0.99375
2	250	0.96875
2	200	0.9625
2	150	0.9375
2	100	0.8875
2	80	0.625
2	60	0.375
2	0	0.2875
2	-100	0.1
3	400	0.86
3	360	0.824
3	320	0.79
3	280	0.742
3	240	0.688
3	200	0.619
3	160	0.54
3	120	0.446
3	80	0.33
3	40	0.188
3	0	0
4	300	0.9375
4	180	0.875
4	120	0.8125
4	72	0.75
4	60	0.6875
4	48	0.625
4	36	0.5625
4	30	0.5
4	18	0.4375
4	12	0.375
4	6	0.3125
4	0	0.25
4	-10	0.1875

];

idx1=find(inputs2(:,1)==1);
idx2=find(inputs2(:,1)==2);
idx3=find(inputs2(:,1)==3);
idx4=find(inputs2(:,1)==4);

n=size(inputs2,1);

r2=zeros(5,5);
r2(1,1)=sum((inputs2(idx1,2)-mean(inputs2(idx1,2),1)).*(inputs2(idx1,2)-mean(inputs2(idx1,2),1)),1);
r2(2,1)=sum((inputs2(idx2,2)-mean(inputs2(idx2,2),1)).*(inputs2(idx2,2)-mean(inputs2(idx2,2),1)),1);
r2(3,1)=sum((inputs2(idx3,2)-mean(inputs2(idx3,2),1)).*(inputs2(idx3,2)-mean(inputs2(idx3,2),1)),1);
r2(4,1)=sum((inputs2(idx4,2)-mean(inputs2(idx4,2),1)).*(inputs2(idx4,2)-mean(inputs2(idx4,2),1)),1);
r2(5,1)=sum((inputs2(:,2)-mean(inputs2(:,2),1)).*(inputs2(:,2)-mean(inputs2(:,2),1)),1);
r2(:,2)=r2(:,1);

y=zeros(n,1);
for i=1:91
    for j=1:1000
        a=90+i*10;
        b=j/100;
        for k=1:n
            y(k,1)=(a*inputs2(k,3)^b-inputs2(k,2))^2;
        end
        if sum(y(idx1,1),1)<r2(1,2)
            r2(1,2)=sum(y(idx1,1),1);
            r2(1,3)=a;
            r2(1,4)=b;
        end
        if sum(y(idx2,1),1)<r2(2,2)
            r2(2,2)=sum(y(idx2,1),1);
            r2(2,3)=a;
            r2(2,4)=b;
        end
        if sum(y(idx3,1),1)<r2(3,2)
            r2(3,2)=sum(y(idx3,1),1);
            r2(3,3)=a;
            r2(3,4)=b;
        end
        if sum(y(idx4,1),1)<r2(4,2)
            r2(4,2)=sum(y(idx4,1),1);
            r2(4,3)=a;
            r2(4,4)=b;
        end
        if sum(y(:,1),1)<r2(5,2)
            r2(5,2)=sum(y(:,1),1);
            r2(5,3)=a;
            r2(5,4)=b;
        end
    end
end
r2(:,5)=1-r2(:,2)./r2(:,1);

idx5=find(inputs2(:,1)~=8); % 3 - excluding data from Nordhaus
fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[100,0],...
               'Upper',[1000,10],...
               'StartPoint',[r2(5,3) r2(5,4)]);
ft = fittype('a*x^b','options',fo);
[curve2,gof2] = fit(inputs2(idx5,3),inputs2(idx5,2),ft);
% plot(curve2,inputs2(:,3),inputs2(:,2));
ci = confint(curve2,0.95);
mac = [ (ci(1,1)+ci(2,1))/2 ci(1,1) ci(2,1); (ci(1,2)+ci(2,2))/2 ci(1,2) ci(2,2) ];

linecolor=[0 0 1; 0.2 0.6 1; 1 0.8 0; 1 0.4 0.6; 0 0 0];
if plots==1
    x=[0:0.01:1.2];
    for i=1:4
        y=r2(i,3)*x.^r2(i,4);
        plot(x,y,'LineStyle','--','LineWidth',1,'Color',linecolor(i,1:3)); hold on;
    end
    y=mac(1,1)*x.^mac(2,1);
    plot(x,y,'LineStyle','-','LineWidth',2,'Color',linecolor(5,1:3)); hold on;
    plot(inputs2(idx1,3),inputs2(idx1,2),'o','MarkerEdgeColor',linecolor(1,1:3),'MarkerFaceColor','none','MarkerSize',6); hold on;     
    plot(inputs2(idx2,3),inputs2(idx2,2),'o','MarkerEdgeColor',linecolor(2,1:3),'MarkerFaceColor','none','MarkerSize',6); hold on;    
    plot(inputs2(idx3,3),inputs2(idx3,2),'o','MarkerEdgeColor',linecolor(3,1:3),'MarkerFaceColor','none','MarkerSize',6); hold on;    
    plot(inputs2(idx4,3),inputs2(idx4,2),'o','MarkerEdgeColor',linecolor(4,1:3),'MarkerFaceColor','none','MarkerSize',6); hold on;  
    title(['r2: ',texlabel(num2str(gof2.rsquare))])
end

end



