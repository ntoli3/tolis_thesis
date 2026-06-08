function [] = save_my_figure(~,~, fig, filename)

[file,path] = uiputfile('*.fig','Save Figure As',filename);
if ~isequal(file,0)
    savefig(fig, fullfile(path,file));
end

end