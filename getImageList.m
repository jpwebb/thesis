% Given a directory, this function returns an N x 1 cell array with a list
% of all image files within the directory. 

function imageFileNames = getImageList(directory)

% Get a list of all files/directories in the given directory.
files = dir(strcat(directory, filesep));

n = length(files);

index = 1;

% Remove all subfolders and any files which are not images.
for i = 1 : n
    if files(index).isdir
        files(index) = [];
    else
        try
            current_file = strcat(files(index).folder, filesep, files(index).name);
            imfinfo(current_file);
            index = index + 1;
        catch
            files(index) = [];
        end        
        if (index > length(files))
            break;
        end
    end
end

% Convert the structure into a cell.
files_cell = struct2cell(files);

% Generate a list of file names from the remaining files (images).
imageFileNames = strcat(files_cell(2,:)', filesep, files_cell(1,:)');

end