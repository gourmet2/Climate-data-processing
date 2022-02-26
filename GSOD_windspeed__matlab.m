% This is a example to extract wind speed from the GSOD data in excel files.
% GSOD data link: https://www.ncei.noaa.gov/data/global-summary-of-the-day/access/
% The data I processed were from 1979-2020, and the number of stations in each year ranged from 8000+ - 12000+. 
% Data for each site for each year belongs to an excel file (csv format); all sites for each year are placed in one folder.
% The aim is to g
------------------------------------------------------------------------------------------------------------------------

% Codes begin here
%%%%
%% ----  1st step: to know which stations have continuous observations in each year.
clc;clear
f_f = "H:\Dataset\GSOD\decompress";  %The path of all the folder
f_f = dir(f_f); f_f = f_f(3:end,:);
f_f = struct2cell(f_f); % get the path of each folder

for k1 = 1:size(f_f,2)
    tic % count the time of each step
    f_s = [char(f_f(2,k1)),'\',char(f_f(1,k1)),'\*.csv']; % get the path of each subfolder
    f_s = dir(f_s); f_s = struct2cell(f_s);
    id = split(f_s(1,:),'.'); % extract the ID of all the stations in this subfolder
    
    if k1 == 1 
        id_1979(:,1) =(id(:,:,1))'; % In the 1st year (1979), we selected ID of all the stations 
        id_all = nan(size(f_s,2),size(f_f,2)); %build a nan matrix to save 
        id_all(:,1) = str2num(cell2mat(id_1979)); %Set the first column of this matrix to all site numbers     
    else
        id_2 = (id(:,:,1))'; 
        for k2 = 1:size(id_1979,1)
            j = find(strcmp(id_1979(k2,1),id_2)); %to check if the station occured in this each
            if length(j)>0
                id_all(k2,k1) = 1;
            end
            %disp(k2)
        end
    end
    t = toc; % end the counting the time of each step
    disp(uint32([k1,t]))  % show the time and which file is processed
end

% Find out how many stations have data greater than or equal to 38 years (satisfying 90% of years), and extract the location and wind speed of these stations
id_name = str2num(cell2mat(id_1979));
for k1 = 1:size(id_all,1)
    id_name(k1,2) = length(find(~isnan(id_all(k1,:))));
end
j = find(id_name(:,2)>=38); 


%%%%
%% ----  2nd step: to get various data from raw files from the GSOD (Quality control process of the data)

sta_con = id_name(j,:); sta_con(:,3) = j;

for k1 = 1:size(f_f,2)

    tic
    f_s = [char(f_f(2,k1)),'\',char(f_f(1,k1)),'\*.csv'];
    f_s = dir(f_s); f_s = struct2cell(f_s);
    id = split(f_s(1,:),'.'); %读取每年中需要的站点
    id =(id(:,:,1))';
    
    mondata = nan(length(j),12); % a matrix for storing wind speed data
    mondata_daynum = nan(length(j),12); % a matrix for storing observation days of each month
    mondata_0num = nan(length(j),12); % a matrix for storing zero observed value
    mondata_obnum = nan(length(j),12); % a matrix for storing observation times of wind speed data
    lat_info = nan(length(j),12); % store latitude
    lon_info = nan(length(j),12); % store latitude
    ele_info = nan(length(j),12); % store latitude
    
    for k2 = 1:size(j,1)
        id_sta = id_1979(j(k2));
        j1 = find(strcmp(id,id_sta)); %to check if this stations occurred since 1979
        if length(j1) > 0
            ft = [char(f_s(2,j1)),'\',char(f_s(1,j1))]; %Extract the path of the site
            [meta,info] = xlsread(ft); % read this file
            info(1,:) = [];
            date = split(info(:,2),'/'); %split the date
            if size(date,1) >= 15*12 %only observation times meet the requirement that there are more than 15*12 observations in a year can be calculated
                if find(meta(:,17)==999.9)
                    meta(meta(:,17)==999.9,17) = nan; %Convert the value of no observation/observation with error, i.e. 999.9, to nan
                end
                meta(:,17) = meta(:,17)*0.5144444; %Converting the unit knots to m/s
                for k3 = 1:12
                    j2 = find(strcmp(date(:,2),num2str(k3)));
                    mondata_daynum(k2,k3) = length(j2);
                    mondata(k2,k3) = nanmean(meta(j2,17));
                    mondata_0num(k2,k3) = length(find(meta(j2,17)==0));
                    mondata_obnum(k2,k3) = nanmean(meta(j2,18));
                    lat_info(k2,k3) = mode(meta(j2,3)); %Get the mode of all the latitude data for that month
                    lon_info(k2,k3) = mode(meta(j2,4)); %得到该月份经纬度的众数
                    ele_info(k2,k3) = mode(meta(j2,5)); %得到该月份高度的众数
                end
            end
        end
        disp(uint32([k1,k2]))
    end
    t = toc;
    disp(uint32([k1,t]))
    f_save = [char("E:\wind-qualitycontrol\data\GSOD_19792022_"),num2str(k1+1978),char('.mat')];
    save(f_save,'lat_info','lon_info','ele_info','mondata_daynum','mondata','mondata_0num','mondata_obnum') %save the results
end
