function filepath = loadExStlFilename(type)
    filepath = fullfile(mfilename('fullpath'));
    filepath = erase(filepath,'loadExStlFilename');    
    if strcmp(type,'bear')
        filepath = fullfile(filepath,'bear.stl');
    elseif strcmp(type,'thinker')
        filepath = fullfile(filepath,'thinker.stl');
    elseif strcmp(type,'octet')
        filepath = fullfile(filepath,'octet.stl');
    elseif strcmp(type,'octahedron')
        filepath = fullfile(filepath,'octahedron.stl');
    end
end
