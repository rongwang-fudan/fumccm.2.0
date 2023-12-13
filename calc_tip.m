function f2 = calc_tip( p )
%   Author: Rong Wang // contact rongwang@fudan.edu.cn //
%   Date: 2023.10.8

f=zeros(14,17);

% only 3 tipping elements
f(1,1)=(1-p(1))*(1-p(2))*(1-p(3)); % 0 tipping
f(1,2)=p(1)*(1-p(2))*(1-p(3))+p(2)*(1-p(1))*(1-p(3))+p(3)*(1-p(1))*(1-p(2)); % 1 tipping
f(1,3)=p(1)*p(2)*(1-p(3))+p(1)*p(3)*(1-p(2))+p(2)*p(3)*(1-p(1)); % 2 tipping
f(1,4)=p(1)*p(2)*p(3); % 3 tipping

for i=1:13 % adding the (i+3) tipping element
    f(i+1,1)=f(i,1)*(1-p(i+3)); % 0 tipping
    for j=1:(i+2)
        f(i+1,j+1)=f(i,j)*p(i+3)+f(i,j+1)*(1-p(i+3)); % j tipping
    end
    f(i+1,i+4)=f(i,i+3)*p(i+3); % (i+3) tipping
end

f2 = f(14,1:17);

for i=1:16
    f2(i+1)=f2(i)+f2(i+1);
end

end

