function params_out = checkParams(params_in, info_file)

params_out = params_in;

ids = [info_file.ID];

for i = ids
    params_serial = params_in([params_in.deviceID] == ids(i)).deviceSerialNumber;
    info_serial = info_file([info_file.ID] == ids(i)).Serial;
    if ~strcmp(params_serial, info_serial)
        idx = find([params_out.deviceID] == i);
        for k = 1 : length(idx)
            params_out(idx(k)).intrinsicParams = [];
            params_out(idx(k)).extrinsicParams = [];
        end
    end
end

end