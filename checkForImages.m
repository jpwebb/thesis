% Given a directory, this function returns an N x 1 cell array with a list
% of all image files within the directory. 

function images_found = checkForImages(directory)

images_found = false;

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
            images_found = true;
            break;
        catch
            files(index) = [];
        end        
        if (index > length(files))
            break;
        end
    end
end

end