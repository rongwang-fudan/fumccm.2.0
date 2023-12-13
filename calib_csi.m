% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2023.10.22

function clim2 = calib_csi ( clim0, land_csink, ocean_csink )

% calibration of the air-land and air-sea carbon flux
clim0(10)=land_csink;
clim0(11)=ocean_csink;
climfix=clim0; sqemin=10000;
for ci=10:100
    clim0(4)=climfix(4)*ci/100;
    for cj=10:100
        clim0(5)=climfix(5)*cj/100;
        clim1 = zeros(1,46);
        clim1(1,1:11) = clim0;
        for t=1:10
            clim1 = climdyn(t+1, clim1, clim0, 36, 1 );
        end
        sqe=(clim1(10)-land_csink)^2+(clim1(11)-ocean_csink)^2;
        if sqe<sqemin
            sqemin=sqe;
            clim2=clim0;
            if sqemin<0.01
                break; % error below 0.1
            end
        end
    end
end

end



