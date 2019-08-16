%%%
%%% addCustomPlugins
%%%

originalWorkingDirectory = pwd;

[pathstr,name,ext] = fileparts(which('eegplugin_erplab.m'));
cd(pathstr);
cd('..');

exist customNCLplugins dir;

if ~ans
    mkdir customNCLplugins;
else
    cd customNCLplugins;
    addpath(pwd);
end

cd(originalWorkingDirectory);