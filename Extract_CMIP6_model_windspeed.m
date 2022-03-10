% The CMIP6 climate model data can be downloaded here: https://cn.bing.com/search?q=cmip6+data+download&qs=LT&pq=cmip6+data&sk=MT1&sc=8-10&cvid=29873765882A49D69F92910CA4793F60&FORM=QBRE&sp=2
% In the most cases, we use a few to dozens of files from the climate models. These climate models can have differert resolutions, so we should convert them into the same resolutions.

clc;clear;
fdir = 'H:\Dataset\CMIP6\nearsurfacewindspeed\*.nc'; % The path of all the files
f = dir(fdir); f = struct2cell(f); f = (f(1:2,:))';

for ii = 1:size(f,1)

    fn =[char(f(ii,2)),'\',char(f(ii,1))];
    name = split(f(ii,1),'_'); 
    model_name = name{3,1}; ensemble_name = name{5,1};
    name_list{ii,1} = model_name;
    name_list{ii,2} = ensemble_name;
    lon = ncread(fn,'lon');
    lat = ncread(fn,'lat');
    wsp = ncread(fn,'sfcWind'); % obtain the wind speed data and save it in the "wsp" matrix

    x_n = size(wsp,1); % know the size of the 1st dimension of the wi matrix
    y_n = size(wsp,2); % know the size of the 2nd dimension of the matrix
    z_n = size(wsp,3); % know the size of the 3rd dimension of the matrix

    [xq1,yq1] = meshgrid(1:y_n,1:x_n);
    [xq2,yq2] = meshgrid(1:(y_n-1)/719:y_n,1:(x_n-1)/719:x_n); % we first change the wind speed to 720×720 grids

    wsp_25 = nan(144,144,z_n); % we want all the data to be converted to 1.25°×2.5° (i.e., 144×144 grids of the whole world)

    for k1 = 1:z_n  %将分辨率转为
        v2 = interp2(xq1,yq1,wsp(:,:,k1),xq2,yq2,'nearest'); % use the "nearest" interpolation to convert the wind speed data to 720×720 grids
        for k2 = 1:720/5
            for k3 = 1:720/5
                x = v2(1+5*(k2-1):5+5*(k2-1),1+5*(k3-1):5+5*(k3-1)); % By calculating the average of corrosponding grids, we get the value of each 144×144 grids
                wsp_25(k2,k3,k1) = mean(x(:));
            end
        end
    end
    str = [model_name,'_',ensemble_name];
    h5create(['H:\Dataset\AI-WIND-DATA\raw_data_144144_singlefile\',str,'.h5'],['/',str],[144 144 1980]);
    h5write(['H:\Dataset\AI-WIND-DATA\raw_data_144144_singlefile\',str,'.h5'],['/',str],wsp_25);
    
    disp(ii)
end
