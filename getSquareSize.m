function square_size = getSquareSize(default_size)

prompt = {'Enter square size (in mm):'};
dlg_title = 'Target Square Size';
num_lines = [1 50];
defaultans = {char(string(default_size))};
square_size = inputdlg(prompt, dlg_title, num_lines, defaultans);

square_size = str2double(cell2mat(square_size));

if isnan(square_size)
    square_size = default_size;
end

end