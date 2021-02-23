function filepath = loadExStlFilename(type)
    if strcmp(type,'bear')
        filepath = fullfile(pwd,'Examples','bear.stl');
    elseif strcmp(type,'thinker')
        filepath = fullfile(pwd,'Examples','thinker.stl');
    elseif strcmp(type,'octet')
        filepath = fullfile(pwd,'Examples','octet.stl');
    elseif strcmp(type,'octahedron')
        filepath = fullfile(pwd,'Examples','octahedron.stl');
    end
end