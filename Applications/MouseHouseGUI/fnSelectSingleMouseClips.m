function fnSelectSingleMouseClips(hFig)

% get userdata
u=get(hFig,'userdata');
expDirName=u.expDirName;

% Throw up a dialog box to get single-mouse file names
[acstrFileName, strDirName] = ...
  uigetfile({fullfile(expDirName,'*.avi;*.seq')}, ...
            'Select all single-mouse clips - one clip for each mouse',...
            'MultiSelect', 'on');
          
% if user hit Cancel, return without doing anything          
if strDirName == 0  % means user hit Cancel
  return;
end;

% make sure acstrFile is a cell array of strings (possibly a cell array of 
% length one)
if ~iscell(acstrFileName)
  acstrFileName = {acstrFileName};
end;

% Make file names absolute
iNumFile=length(acstrFileName);
acstrFileNameAbs=cell(iNumFile,1);
for i=1:iNumFile
  acstrFileNameAbs{i}=fullfile(strDirName,acstrFileName{i});
end

% set the single-mouse clips for the experiment to the newly-selected files
fnSetSingleMouseClips(hFig, acstrFileNameAbs)

end
