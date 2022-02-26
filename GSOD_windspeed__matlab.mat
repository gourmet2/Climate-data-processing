% This is a example to extract wind speed from the GSOD data in excel files.
% GSOD data link: https://www.ncei.noaa.gov/data/global-summary-of-the-day/access/
% The data I processed were from 1979-2020, and the number of stations in each year ranged from 8000+ - 12000+. 
% Data for each site for each year belongs to an excel file (csv format); all sites for each year are placed in one folder.

% Codes begin here

clc;clear
f_f = "H:\Dataset\GSOD\decompress"; 
f_f = dir(f_f); f_f = f_f(3:end,:);
f_f = struct2cell(f_f);

for k1 = 1:size(f_f,2)
    tic
    f_s = [char(f_f(2,k1)),'\',char(f_f(1,k1)),'\*.csv'];
    f_s = dir(f_s); f_s = struct2cell(f_s);
    id = split(f_s(1,:),'.');
    if k1 == 1
        id_1979(:,1) =(id(:,:,1))'; %提取1979年所有站点的编号，接下来了解每一年这些站点是否出现
        id_all = nan(size(f_s,2),size(f_f,2)); %设置一个矩阵，保存该站点是否每年出现的情况
        id_all(:,1) = str2num(cell2mat(id_1979)); %将该矩阵的第一列设为所有的站点编号       
    else
        id_2 = (id(:,:,1))'; %提取其他年份矩阵的信息
        for k2 = 1:size(id_1979,1)
            j = find(strcmp(id_1979(k2,1),id_2)); %看每年该站点是否出现
            if length(j)>0
                id_all(k2,k1) = 1;
            end
            %disp(k2)
        end
    end
    t = toc;
    disp(uint32([k1,t]))
end
% 了解有多少个站点有大于等于38年的数据，并将这些站点的位置及风速提取出来
id_name = str2num(cell2mat(id_1979));
for k1 = 1:size(id_all,1)
    id_name(k1,2) = length(find(~isnan(id_all(k1,:))));
end
j = find(id_name(:,2)>=38); %共有3000+个
