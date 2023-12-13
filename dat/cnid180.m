% Author: Rong Wang // contact rongwang@fudan.edu.cn //
% Date: 2023.9.28
tic
clear;

load('D:\Data\2023-FUDAMv2\fdumv2_nuclear 20221207 for Nature\fdum\files\country_ID.dat','-mat'); 

cnid=zeros(180,360);
cnx=zeros(222,2);
for i=5:10:1795
    for j=5:10:3595
        i2=floor((i-1)/10)+1;
        j2=floor((j-1)/10)+1;
        if j2>180
            j2=j2-180;
        else
            j2=j2+180;
        end
        cn=country_ID(i,j);
        cnid(i2,j2)=cn;
        if cn>=1 && cn<=222
            cnx(cn,1)=cnx(cn,1)+1;
        end
    end
end

for i=1:1800
    for j=1:3600
        i2=floor((i-1)/10)+1;
        j2=floor((j-1)/10)+1;
        if j2>180
            j2=j2-180;
        else
            j2=j2+180;
        end
        cn=country_ID(i,j);
        cn2=cnid(i2,j2);
        if cn==cn2
            continue;
        end
        if cn>=1 && cn<=222
            if cn2>=1 && cn2<=222
                if cnx(cn2,1)>1
                    cnid(i2,j2)=cn;
                    cnx(cn,1)=cnx(cn,1)+1;
                    cnx(cn2,1)=cnx(cn2,1)-1;
                end
            else
                cnid(i2,j2)=cn;
                cnx(cn,1)=cnx(cn,1)+1;
            end
        end
        
%         if cn==4
%             sss=1;
%         end
        if cn>=1 && cn<=222
            cnx(cn,2)=cnx(cn,2)+1;
        end
        
    end
end

image(cnid(180:-1:1,:),'cdatamapping','scaled');
caxis([1 222]);

save('cnid_180x360.dat','cnid');
