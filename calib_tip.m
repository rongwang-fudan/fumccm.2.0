% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2023.9.28

function hazard_rate = calib_tip ( ts )

global tip_threshold

tss=max(1.1,ts);

for hz=100:100000
    temp=1;
    starty=2020;
    endy=2300;
    prob=0;
    for t=starty:endy
        temp=temp+(tss-1)/(endy-starty+1);
        prob=1-(1-prob)*exp(-hz/100000*(temp-1)); 
    end
    
    if prob>tip_threshold
        hazard_rate=hz/100000;
        break;
    end
end



