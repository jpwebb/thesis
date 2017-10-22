function square_size = getSquareSize(default_size)

prompt = {'Enter square size (in mm):'};
dlg_title = 'Target Square Size';
num_lines = [1 50];
defaultans = {char(string(default_size))};
square_size = inputdlg(prompt, dlg_title, num_lines, defaultans);

square_size = str2double(cell2mat(square_size));

if isnan(square_size)
    square_size = default_size;
    warning_message = ['No input or invalid input detected!\n',...
        'Default square size being used for this calibration (', num2str(default_size),...
        ' mm).\n'];
    my_warning(warning_message);
end

end