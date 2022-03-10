%%

clc;clear;
fdir = "H:\Dataset\HadISD__decompressed_version_3.1.2.202105p\*.nc";
fdir = dir(fdir); fdir = struct2cell(fdir); f = (fdir(1:2,:))';

missing_value = -1e+30;flagged_value = -2e+30;
zero_value = 0;

for ii = 1:size(f,1)
    
    sta_name = split(f{ii,1},'.');
    sta_name = split(sta_name{5,1},'_');
    sta_name = sta_name{3,1};
    
    fn = [char(f{ii,2}),'\',char(f{ii,1})];
    loc{ii,1} = ncread(fn,'longitude');
    loc{ii,2} = ncread(fn,'latitude');
    loc{ii,3} = ncread(fn,'elevation');
    loc{ii,4} = char(sta_name);
    time = ncread(fn,'time');
    
    fn_s = ['H:\Dataset\HadISD\processed_data_nozero\',char(sta_name),'.mat'];
    
    
    wsp = ncread(fn,'windspeeds');
    wsp(wsp ==flagged_value) = nan; wsp(wsp ==missing_value) = nan;
    wsp(wsp ==zero_value) = nan;
    wsp_m = nan(12*(2020-1931+1),2); %月风速序列
    
    for yr = 1931:2020
        for mm = 1:12
            wsp_d = nan(eomday(yr,mm),1);
            for dy = 1:eomday(yr,mm)
                t_d = datenum(yr,mm,dy) - datenum(1931,1,1); %距离1931.1.1的天数
                t_b = 24*t_d; %当日开始的时间
                t_e = 24*(t_d+1); %当日结束的时间
                j = find(t_b <= time & time <t_e);
                if length(j) >= 3
                    wsp_h = wsp(j); %该日的小时风速
                    if length(find(~isnan(wsp_h))) >= 3 
                        wsp_d(dy,1) = nanmean(wsp_h);
                    end
                end           
            end
            if length(find(~isnan(wsp_d))) >= 15
                wsp_m(mm+12*(yr-1931),1) = nanmean(wsp_d); %该月的风速
                wsp_m(mm+12*(yr-1931),2) = length(find(~isnan(wsp_d))); %该月的风速是由几天的风速组成的
            end 
        end
    end 
%     for k1 = 1:90
%         wsp_m(1+12*(k1-1):12+12*(k1-1),3) = 1930+k1;
%     end

   % save(fn_s,'wsp_m')
    %xlswrite('H:\Dataset\HadISD\station_info_new.xls',loc)
    disp(ii)
end
