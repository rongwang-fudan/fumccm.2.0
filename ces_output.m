function F = ces_output( var )
%   Author: Rong Wang // contact rongwang@fudan.edu.cn //
%   Date: 2021.6.18
%   Return the output under an allocation of investment and labor
%   var: 1 for labor allocation; 2 for investment allocation

global alpha elas cesin dk_x dk_e
%   cesin:  input variables 1ke, 2kx, 3eue, 4epe, 5ene, 6dk_x, 7dk_e
%   alpha:  elasticity of output to capital
%   elas:   elasticity of substitution between energy and non-energy in output

i=var(1); % labor allocation
j=var(2); % investment allocation
ro=(elas-1)/elas;
tstep=cesin(8);

ke=cesin(1) * (1-dk_e)^ tstep + tstep * j * cesin(6);
kx=cesin(2) * (1-dk_x)^ tstep + tstep * (1-j) * cesin(6);
e=cesin(4)*ke^alpha*(cesin(7)*i)^(1-alpha);
x=cesin(5)*kx^alpha*(cesin(7)*(1-i))^(1-alpha);
y=((cesin(3)*e)^ro+x^ro)^(1/ro) - e * cesin(9);
F = -y;

end

