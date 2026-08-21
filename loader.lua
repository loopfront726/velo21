local isfile: (file: string) -> boolean = isfile or function(file: string)
        local suc: boolean, res: string = pcall(function()
                return readfile(file);
        end);
        return suc and res ~= nil and res ~= '';
end;

local delfile: (file: string) -> nil = delfile or function(file: string)
        writefile(file, '');
end;

local downloadFile: (path: string, func: ((string) -> string)?) -> string = function(path: string, func: ((string) -> string)?)
        if not isfile(path) then
				local suc: boolean, res: string? = pcall(function()
					return game:HttpGet('https://raw.githubusercontent.com/loopfront726/velo21/'..readfile('skidrewrite/profiles/commit.txt')..'/'..select(1, path:gsub('skidrewrite/', '')), true);
				end);
                if not suc or res == '404: Not Found' then
                        error(res);
                end;
                if path:find('.lua') then
                        res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.\n' .. res;
                end;
                writefile(path, res);
        end;
        return (func or readfile)(path);
end;

local wipeFolder: (path: string) -> nil = function(path: string)
        if not isfolder(path) then return; end;
        for _, file: string in listfiles(path) do
                if file:find('loader') then continue; end;
                if isfile(file) and select(1, readfile(file):find(
                        '--This watermark is used to delete the file if its cached, remove it to make the file persist after velocity updates.'
                )) == 1 then
                        delfile(file);
                end;
        end;
end;

for _, folder: string in {'velo', 'skidrewrite/games', 'skidrewrite/profiles', 'skidrewrite/assets', 'skidrewrite/libraries', 'skidrewrite/guis'} do
        if not isfolder(folder) then
                makefolder(folder);
        end;
end;

if not shared.VeloDeveloper then
        local _, subbed: string = pcall(function()
                return game:HttpGet('https://github.com/loopfront726/velo21');
        end);
        local commit: string? = subbed:find('currentOid');
        commit = commit and subbed:sub(commit + 13, commit + 52) or nil;
        commit = commit and #commit == 40 and commit or 'main';
        if commit == 'main' or (isfile('skidrewrite/profiles/commit.txt') and readfile('skidrewrite/profiles/commit.txt') or '') ~= commit then
                wipeFolder('velo');
                wipeFolder('skidrewrite/games');
                wipeFolder('skidrewrite/guis');
                wipeFolder('skidrewrite/libraries');
        end;
        writefile('skidrewrite/profiles/commit.txt', commit);
end;

return loadstring(downloadFile('skidrewrite/main.lua'), 'main')();
