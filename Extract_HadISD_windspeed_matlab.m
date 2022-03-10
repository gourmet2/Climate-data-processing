% This is a example to extract wind speed from the HadISD dataset.
% HadISD data link: https://www.metoffice.gov.uk/hadobs/hadisd/
% Data for each site belongs to a file ("nc" format); The version I used was V3.1.2.202105p, which consists of 9,277 stations. So there are 9,277 files to be processed.
% The aim is to get monthly data from 1931-2020 from the HadISD dataset.
------------------------------------------------------------------------------------------------------------------------


%%Codes begin here
% 1st Part
% The first step is to know the varibles and their storage format.
fn = "H:\Dataset\HadISD__decompressed_version_3.1.2.202105p\hadisd.3.1.2.202105p_19310101-20210601_010010-99999.nc"; %example here, % So we get the path of a file:
ncifo(fn) %show the information
ncdisp(fn)


% After knowing them, we can run the program
clc;clear;
fdir = "H:\Dataset\HadISD__decompressed_version_3.1.2.202105p\*.nc"; %The path of all the "nc" files
fdir = dir(fdir); fdir = struct2cell(fdir); f = (fdir(1:2,:))';

missing_value = -1e+30; flagged_value = -2e+30; % These wind speed values need to be flagged or changed into nan values. 


for ii = 1:size(f,1) %
    
    sta_name = split(f{ii,1},'.'); % get the ID of station in this file
    sta_name = split(sta_name{5,1},'_');
    sta_name = sta_name{3,1};
    
    fn = [char(f{ii,2}),'\',char(f{ii,1})]; % get the path of this file
    loc{ii,1} = ncread(fn,'longitude'); % read the location information
    loc{ii,2} = ncread(fn,'latitude'); % read the location information
    loc{ii,3} = ncread(fn,'elevation'); % read the location information
    loc{ii,4} = char(sta_name);
    time = ncread(fn,'time'); % read the time, because the wind speed data is is stored in chronological order
    
    fn_s = ['H:\Dataset\HadISD\processed_data\',char(sta_name),'.mat']; % set a mat file to save wind data after being processed.
    
    
    wsp = ncread(fn,'windspeeds'); % read the wind speed data
    wsp(wsp ==flagged_value) = nan; wsp(wsp ==missing_value) = nan; % Make wind speed  data which equals to a flagged_value or a missing_value to nan.

    wsp_m = nan(12*(2020-1931+1),2); % create a matrix to store monthly wind data
    
    for yr = 1931:2020 %
        for mm = 1:12
            wsp_d = nan(eomday(yr,mm),1); % create a matrix to store daily wind data
            for dy = 1:eomday(yr,mm)
                t_d = datenum(yr,mm,dy) - datenum(1931,1,1); % get the time of this day 
                t_b = 24*t_d; % Start time of the day
                t_e = 24*(t_d+1); % The end of the day
                j = find(t_b <= time & time <t_e); % Know the location of all wind speed data during the day
                if length(j) >= 3 % If there are no less than three observations in this day, we can get the daily wind speed by averaging all the observations.
                    wsp_h = wsp(j); %该日的小时风速
                    if length(find(~isnan(wsp_h))) >= 3 
                        wsp_d(dy,1) = nanmean(wsp_h);
                    end
                end           
            end
            if length(find(~isnan(wsp_d))) >= 15  % If there are no less than 15 daily wind in this month, we can get the monthly wind speed by averaging all the daily values.
                wsp_m(mm+12*(yr-1931),1) = nanmean(wsp_d);
                wsp_m(mm+12*(yr-1931),2) = length(find(~isnan(wsp_d))); 
            end 
        end
    end 

    save(fn_s,'wsp_m')
    xlswrite('H:\Dataset\HadISD\station_info_new.xls',loc)
    disp(ii)
end
