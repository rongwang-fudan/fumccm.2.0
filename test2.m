

tic
clear;

load('dat\cpri2d_tcn1.dat','-mat');
cpri=cpri2d;
load('dat\cpri2d_tcn2.dat','-mat');
cpri(:,:,10:18)=cpri2d(:,:,10:18);
load('dat\cpri2d_tcn3.dat','-mat');
cpri(:,:,19:27)=cpri2d(:,:,19:27);
load('dat\cpri2d_tcn3.dat','-mat');
cpri(:,:,28:36)=cpri2d(:,:,28:36);
cpri2d=cpri;
save('dat\cpri2d_tcn_learn24.dat','cpri2d');

% load('dat\cpri_tcn1.dat','-mat');
% cpri2=cpri;
% load('dat\cpri_tcn2.dat','-mat');
% cpri2(:,:,2)=cpri(:,:,2);
% load('dat\cpri_tcn3.dat','-mat');
% cpri2(:,:,3)=cpri(:,:,3);
% 
% cpri=cpri2;
% save('dat\cpri_tcn.dat','cpri');


% load('dat\cpri_tcn.dat','-mat');
% cpri2=cpri;
% load('dat\cpri_tcn3.dat','-mat');
% cpri2(:,(36+40),1:3)=cpri(:,(36+40),1:3);
% 
% cpri=cpri2;
% save('dat\cpri_tcn.dat','cpri');