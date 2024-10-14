classdef figCapture < handle
% Class for saving a figure as an image file. (including GUI support).
%
% <usage>
%       >> figCamera;    % Launch GUI to manage figCamera
%
% <static method>
%       >> figCamera.capture(filename)  % Add bookmark data with the name specified in "name"
%       >> figCamera.setExtension(ext)  % Update list of extensions to save.(Without argument, GUI is launched)
%       >> figCamera.setPath(folder)    % Update save path. (Without argument, GUI is launched)
%

    properties(Dependent)
        FileName
        Extension
        SavePath
        Position
    end

    properties(Access=protected)
        uifig
        uigrid
        uiCapture

        uiTextFolder
        uiFolderIcon

        uiExtensionIcon
        uiTextExtension
        uiFileName
    end

    methods
        function obj = figCapture()
            obj.createComponent;
            obj.refresh
        end

        % Refresh Item in uifigure 
        function refresh(obj)
            data = getconfig;
            
            if strcmp(data.SavePath,'pwd')
                Path = pwd;
            elseif isfolder(data.SavePath)
                Path = data.SavePath;
            else
                warning(data.SavePath+" : Not a valid path")
                Path = pwd;
            end
            
            ext = data.Extension;
            txt = [ext(:)' ; [repmat(", ",1,numel(ext)-1),""]];
        
            obj.uiTextFolder.Text        = Path;
            obj.uiTextExtension.UserData = ext;
            obj.uiTextExtension.Text     = horzcat(txt{:});
        end
        
        % Set/Get Method
        function val = get.Position(obj);  val = obj.uifig.Position;           end
        function val = get.FileName(obj);  val = obj.uiFileName.Value;         end
        function val = get.SavePath(obj);  val = obj.uiTextFolder.Text;        end
        function val = get.Extension(obj); val = obj.uiTextExtension.UserData; end
        function set.Position(obj,val);    obj.uifig.Position = val;           end
    end

    % Build component
    methods(Access=protected)
        createComponent(obj)
    end

    % static method
    methods(Static)

        function setPath(val,cls)
            arguments
                val = [];
                cls = struct('refresh',[]); % Dammy class which has "refresh" method.
            end
            if isempty(val)
                val = uigetdir;
                if ~val; return; end
            end
            assert(isfolder(val),'It is not Folder')
            setconfig('SavePath',val);
            cls.refresh;
        end


        function setExtension(ext,cls)
            arguments
                ext = [];
                cls = struct('refresh',[]); % Dammy class which has "refresh" method.
            end
        
            if isempty(ext)
                selectUI_forExtension(@Callback)
            else
                Callback(ext)
            end
        
            % Define Callback Function
            function Callback(ext)
                if isstring(ext)
                    ext = cellfun(@(c) c, ext, 'UniformOutput',false);
                elseif ischar(ext)
                    ext = {ext};
                end
                assert(iscell(ext),'Format is wrong')
        
                idx = ismember(ext, {'jpeg','png','tiff','tiffn','meta','pdf','eps','epsc','eps2','epsc2','meta','svg','fig'});
                cellfun(@(c) disp(['  >> removed:',c]), ext(~idx));
                ext = ext(idx);
                
                if sum(ismember(ext,{'tiff','tiffn'}))>1
                    warning('Both "tiff" and "tiffn" are saved with a .tif extension.')
                end
        
                idx = ismember(ext,{'eps','epsc','eps2','epsc2'});
                if sum(idx)>1
                    exts = cellfun(@(c) ['"',c,'" '],ext(idx),'UniformOutput',false);
                    warning([horzcat(exts{:}),'are all saved with .eps extension.'])
                end
        
                setconfig('Extension',string(ext));
                cls.refresh;
            end
        end


        function capture(filename)
            arguments
                filename = 'date'
            end
            disp('Saving...')
            data = getconfig;
            
            % Format filename
            switch string(filename)
                case "date";    filename = ['Fig',char(datetime("now","Format","yyMMddHHmmss"))];
                case "cmd";     filename = input('File Name : ','s');
                case "dlg";     filename = inputdlg("Input file name");
            end
        
            % Check for overlapping file names in the selected folder
            if strcmp(data.SavePath,'pwd')
                data.SavePath = pwd; 
            end
            Tab  = struct2table(dir(data.SavePath));
            [~,ExistFile(:),~] = cellfun(@(n) fileparts(n), Tab.name(~Tab.isdir), 'UniformOutput',false);
            cnt = 1;
            tempname = filename;
            while ismember(tempname,ExistFile)
                tempname = filename{1}+"("+cnt+")";
                cnt = cnt+1;
            end
        
            % Save figure
            filepath = fullfile(char(data.SavePath),char(tempname));
            cellfun(@(e) saveas(gcf,filepath,e), data.Extension)
        
            disp("Save Figure at "+filepath)
        end
    end
end


function setconfig(field,val)
    [str,cpath] = getconfig();
    new  = setfield(str,field,val);
    text = jsonencode(new, PrettyPrint=true);
    writelines(text,cpath)
end

function [str,cpath] = getconfig()
    [path,~,~] = fileparts( mfilename("fullpath") );
    cpath = fullfile(path,'config.json');
    str = readstruct(cpath);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% UI APP for set extension %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function selectUI_forExtension(Callback)
    [path,~,~] = fileparts( mfilename("fullpath") );
    cpath = fullfile(path,'config.json');
    data = readstruct(cpath);

    % build uifigure
    fig = uifigure('Name','Extension Setting');
    fig.Position([3,4]) = [500,350];
    grd = uigridlayout(fig,[2 2]);

    % load Exttension Table
        [path,~,~] = fileparts( mfilename("fullpath") );
        extTab     = readtable(fullfile(path,'FigExtension_en.csv'));
        extTab.Discription = cellfun(@(c) replace(c,{'_','(',')'},{' ',' (', ') '}),extTab.Discription,'UniformOutput',false);
        if ~isempty(data.Extension)
            extTab.set = ismember(extTab.val,data.Extension);
        else  
            extTab.set = logical(extTab.set);
        end

    % Set uitable
        tab = uitable(grd,"Data",extTab,'ColumnWidth',{'fit',40,55,'1x'});
        tab.ColumnEditable = [true,false,false,false];

    % Set uibutton
        bot = uibutton(grd,'Text','Save','BackgroundColor',[0.8,0.8,0.8],...
                          "ButtonPushedFcn", @(src,enent) SaveFcn(src));

    % Set uiswitch
        swi = uiswitch(grd,"ValueChangedFcn",@(src,event) setTab(tab,src.Value));
        swi.Items = ["ENG","JPN"];

    grd.RowHeight   = {'1x',35};
    grd.ColumnWidth = {100,'1x',100};

    tab.Layout.Row      = 1;
    tab.Layout.Column   = [1,3];

    bot.Layout.Row      = 2;
    bot.Layout.Column   = 3;

    swi.Layout.Row      = 2;
    swi.Layout.Column   = 1;

    function SaveFcn(src)
        Tab = src.Parent.Children(1).Data;
        Callback(Tab.val(Tab.set));
        delete(src.Parent.Parent)
    end

    function setTab(tab,lang)
        [p,~,~] = fileparts( mfilename("fullpath") );
        switch lang
            case 'JPN'
                newTab     = readtable(fullfile(p,'FigExtension_jp.csv'));
            case 'ENG'
                newTab     = readtable(fullfile(p,'FigExtension_en.csv'));
                newTab.Discription = cellfun(@(c) replace(c,{'_','(',')'},{' ',' (', ') '}),newTab.Discription,'UniformOutput',false);
        end
        tab.Data.Discription = newTab.Discription;
    end
end
