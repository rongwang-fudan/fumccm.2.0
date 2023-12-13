function allo = ces_allocation( omega , level )
%   Author:  Rong Wang // contact rongwang@fudan.edu.cn //
%   Date:  2021.6.18
%   allo:  optimal allocation of labor and investment
%   omega: omega

allo = [omega, omega]; % allocation of labor and investment
ymax = - ces_output( allo );

y = -ces_output( [min(1,allo(1)+0.01),allo(2)] );
while y>ymax
    allo(1) = allo(1)+0.01;
    ymax = y;
    y = -ces_output( [min(1,allo(1)+0.01),allo(2)] );
end

y = -ces_output( [max(0,allo(1)-0.01),allo(2)] );
while y>ymax
    allo(1) = allo(1)-0.01;
    ymax = y;
    y = -ces_output( [max(0,allo(1)-0.01),allo(2)] );
end

y = -ces_output( [allo(1),min(1,allo(2)+0.01)] );
while y>ymax
    allo(2) = allo(2)+0.01;
    ymax = y;
    y = -ces_output( [allo(1),min(1,allo(2)+0.01)] );
end

y = -ces_output( [allo(1),max(0,allo(2)-0.01)] );
while y>ymax
    allo(2) = allo(2)-0.01;
    ymax = y;
    y = -ces_output( [allo(1),max(0,allo(2)-0.01)] );
end

% refining the optimized variables
if level==1
y = -ces_output( [min(1,allo(1)+0.001),allo(2)] );
while y>ymax
    allo(1) = allo(1)+0.001;
    ymax = y;
    y = -ces_output( [min(1,allo(1)+0.001),allo(2)] );
end

y = -ces_output( [max(0,allo(1)-0.001),allo(2)] );
while y>ymax
    allo(1) = allo(1)-0.001;
    ymax = y;
    y = -ces_output( [max(0,allo(1)-0.001),allo(2)] );
end

y = -ces_output( [allo(1),min(1,allo(2)+0.001)] );
while y>ymax
    allo(2) = allo(2)+0.001;
    ymax = y;
    y = -ces_output( [allo(1),min(1,allo(2)+0.001)] );
end

y = -ces_output( [allo(1),max(0,allo(2)-0.001)] );
while y>ymax
    allo(2) = allo(2)-0.001;
    ymax = y;
    y = -ces_output( [allo(1),max(0,allo(2)-0.001)] );
end

end

allo(1) = min(0.999,max(0.001,allo(1)));
allo(2) = min(0.999,max(0.001,allo(2)));

end

