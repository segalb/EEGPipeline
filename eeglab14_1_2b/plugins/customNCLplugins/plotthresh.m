classdef plotthresh < handle
    %--------------------------------------------------------------------%
    %A custom class that is called to create a figure that is optimized in
    %displaying tabulated filter thresholds for a given epoch.
    %
    %An arf.m file should call this class via the 'addFilter' function,
    %which will update the global 'thresholds' struct containing filter
    %value data for this class's figure's table.
    %The arf.m file also shares its global 'chanlabels' array which
    %labels the table's channels.
    %
    %Once the figure has been created, the eegplot.m file will call this
    %class's 'update' function pointing to the specified epoch.
    %Within eegplot.m, plotthresh will be called to update when the user
    %scrolls to the prior or next window (5 epochs) or when an epoch is
    %hovered over via the mouse pointer.
    %
    %Added 11/1/16 by David DiStefano
    %Tuft's University Integrative Cognitive Neuroscience Lab
    %--------------------------------------------------------------------%
    
    properties
        fig; epochText; tableData; t; panelColor; filts; numFilts;
    end
    
    methods (Static)
        %Create figure with tabulated filter values for a specified epoch
        function obj = plotthresh()
            global chanlabels thresholds figThresh;
            figThresh.fig = findobj('tag','figThresh');
            if ~isempty(thresholds) && isempty(figThresh.fig)
                figThresh = obj;
                obj.filts = fieldnames(thresholds);
                filtWidth = 60; %custom width of filter columns in table
                obj.numFilts = length(obj.filts);
                
                %Set table column names and column widths
                colnames = {'Channel'};
                colWidths = {125};
                for n = 1:obj.numFilts
                    colnames{n+1} = strcat('<HTML><center>',...
                        thresholds.(obj.filts{n}).name,'<br>',...
                        num2str(thresholds.(obj.filts{n}).threshVal));
                    colWidths{n+1} = filtWidth;
                end
                
                %Create new figure with optimized dimensions based on
                %number of filters
                defaultFigHeight = 850;
                tableHeight = (length(chanlabels)+2)*18;
                if tableHeight > defaultFigHeight-50
                    figWidth = 32 + sum(cell2mat(colWidths));
                else
                    figWidth = 15 + sum(cell2mat(colWidths));
                end
                obj.fig = figure('Name','Filter Thresholds',...
                    'Tag','figThresh','Position',[50 100 figWidth defaultFigHeight],...
                    'Resize','on','SizeChangedFcn',@plotthresh.Resize_clbk);
                panelColor = [0.93 0.96 1];
                p1 = uipanel('Parent',obj.fig,'tag','p1',...
                    'Position',[0 0 1 1],'BackgroundColor',panelColor);
                
                %Create text panel to display current epoch number
                obj.epochText = uicontrol('Style','text',...
                    'Parent',p1,...
                    'String','Epoch: 0',...
                    'tag','epochText',...
                    'Position',[5 obj.fig.Position(4)-35 100 20],...
                    'FontSize',11,'BackgroundColor',panelColor);
                
                %Create button for displaying window to change thresholds
                uicontrol('Style', 'pushbutton',...
                    'String', '<HTML><center>Change<br>Thresholds',...
                    'Position', [figWidth-85 obj.fig.Position(4)-40 80 35],...
                    'Callback', 'changethresh.surface;');
                
                %Create empty table with channel labels
                obj.tableData = chanlabels(:);
                data = zeros(length(chanlabels),obj.numFilts);
                obj.tableData(:,2:(obj.numFilts+1)) = num2cell(data);
                
                %Create data table
                obj.t = uitable(p1,'Data',obj.tableData,'ColumnName',colnames,...
                    'Position',[5 5 obj.fig.Position(3)-13 (obj.fig.Position(4)-50)],...
                    'ColumnWidth',colWidths,'RowName','','tag','tableData');
                figThresh = obj;
            end
        end
        
        %Update existing figure's table data
        function obj = updateFig(obj,epochtime)
            global thresholds figThresh;
            if ~isempty(findobj('type','figure','tag','figThresh'))
                %Load figure property handles into figThresh
                obj.fig = findobj('type','figure','tag','figThresh');
                p1 = obj.fig.Children.findobj('tag','p1');
                obj.t = p1.Children.findobj('tag','tableData');
                obj.epochText = p1.Children.findobj('tag','epochText');
                obj.tableData = p1.Children.findobj('tag','tableData');
                obj.filts = fieldnames(thresholds);
                obj.numFilts = length(obj.filts);
                
                %Update displayed epoch number
                if epochtime==0; epochtime=1; end
                set(obj.epochText,'String',strcat('Epoch: ',{' '},num2str(epochtime)));
                
                %Add threshold values for specific epoch to empty 'data' matrix
                data = zeros(length(obj.tableData),obj.numFilts);
                for n = 1:obj.numFilts
                    if isempty(thresholds.(obj.filts{n}).thresh)
                        disp(['   ERROR(plotthresh.m) - ''thresholds.',(obj.filts{n}),'.thresh'' is empty']);
                    else
                        if strcmp(thresholds.(obj.filts{n}).type,'flatline')
                            data(thresholds.(obj.filts{n}).chan,n)  = thresholds.(obj.filts{n}).thresh(:,epochtime);
                        else
                            data(thresholds.(obj.filts{n}).chan,n)  = ceil(thresholds.(obj.filts{n}).thresh(:,epochtime));
                        end
                    end
                end
                
                %Customize table color scheme and highlight cells with
                %values above threshold
                colergen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD><b>',text,'</b></TD></TR></table></html>'];
                tableHighlight = false;
                aboveThreshColor = '#FF7777';  %cell color for values above filter threshold
                rangeThreshColor = '#FFC04C';
                threshPercent    =  10;
                for n = 1:figThresh.numFilts
                    for j = 1:length(thresholds.(obj.filts{n}).chan)
                        i = thresholds.(obj.filts{n}).chan(j);
                        if strcmp(thresholds.(obj.filts{n}).type,'flatline')
                            if numel(thresholds.(obj.filts{n}).threshVal)==1
                                thresholds.(obj.filts{n}).threshVal(1) = -abs(thresholds.(obj.filts{n}).threshVal);
                                thresholds.(obj.filts{n}).threshVal(2) = abs(thresholds.(obj.filts{n}).threshVal);
                            end
                            if data(i,n) >= thresholds.(obj.filts{n}).threshVal(1) && data(i,n) <= thresholds.(obj.filts{n}).threshVal(2)
                                obj.tableData.Data{i,n+1} = colergen(aboveThreshColor,num2str(data(i,n)));
                                tableHighlight = true;
%                             elseif data(i,n) > (thresholds.(obj.filts{n}).threshVal - thresholds.(obj.filts{n}).threshVal * (threshPercent/100))
%                                 obj.tableData.Data{i,n+1} = colergen(rangeThreshColor,num2str(data(i,n)));
                            else
                                obj.tableData.Data{i,n+1} = data(i,n);
                            end
                        else
                            if data(i,n) > thresholds.(obj.filts{n}).threshVal
                                obj.tableData.Data{i,n+1} = colergen(aboveThreshColor,num2str(data(i,n)));
                                tableHighlight = true;
                            elseif data(i,n) > (thresholds.(obj.filts{n}).threshVal - thresholds.(obj.filts{n}).threshVal * (threshPercent/100))
                                obj.tableData.Data{i,n+1} = colergen(rangeThreshColor,num2str(data(i,n)));
                            else
                                obj.tableData.Data{i,n+1} = data(i,n);
                            end
                        end
                    end
                end
                
                %Highlight figure table if it has values above a threshold
                if tableHighlight
                    obj.t.BackgroundColor = [1 1 0.8; 0.95 0.95 0.8];
                else
                    obj.t.BackgroundColor = [1 1 1; 0.94 0.94 0.94];
                end
            end
        end
        
        %Add filter column to this class's figure table
        %
        %INPUTS: Name, Channels, Values, Threshold
        %
        %EX  >> addFilter('Name','Blink','Channels',1:length(EEG.chanlocs),
        %                     'Values',outmwppth,'Threshold',blink_thresh);
        %
        %Updates global 'thresholds' struct with new substruct containing
        %corresponding filter/threshold information.
        function addFilter(varargin)
            global thresholds;
            p = inputParser;
            p.addParameter('Name', '', @ischar);
            p.addParameter('Channels', 0, @isnumeric);
            p.addParameter('Type', '', @ischar);
            %p.addParameter('Values', 0, @isnumeric);
            p.addParameter('Threshold', 0, @isnumeric);
            p.parse(varargin{:});
            field = matlab.lang.makeValidName(lower(p.Results.Name));
            
            if isfield(thresholds,field)
                error(strcat('The field "',p.Results.Name,'" already exists within the struct - use a different field name.'));
            else
                thresholds.(field).name      = p.Results.Name;
                thresholds.(field).chan      = p.Results.Channels;
                thresholds.(field).threshVal = p.Results.Threshold;
                
                switch p.Results.Type
                    case 'NCL_pop_artmwppth'
                        global outmwppth;
                        thresholds.(field).thresh = outmwppth;
                        thresholds.(field).type = 'mwpp';
                        clearvars -global outmwppth;
                    case 'NCL_pop_artstep'
                        global outstepth;
                        thresholds.(field).thresh = outstepth;
                        thresholds.(field).type = 'step';
                        clearvars -global outstepth;
                    case 'NCL_pop_artflatline'
                        global outflat;
                        thresholds.(field).thresh = outflat;
                        thresholds.(field).type = 'flatline';
                        clearvars -global outflat;
                end
                
            end
        end
        
        %Simplified update function which calls 'updateFig' which handles
        %the table data.
        function update(epochnum)
           global figThresh;
           if isempty(figThresh)
               figThresh = plotthresh;
           elseif ~isempty(findobj('type','figure','tag','figThresh'))
               figThresh.fig = findobj('type','figure','tag','figThresh');
           end
           
           exist epochnum;
           if ans
               if isgraphics(figThresh.fig)
                   plotthresh.updateFig(figThresh,epochnum);
               end
           else
               if isempty(findobj('type','figure','tag','figThresh'))
                   figThresh = plotthresh;
               end
           end
        end
        
        function Resize_clbk(fig,callbackdata)
            t = fig.findobj('tag','tableData');
            set(t,'Position',[5 5 fig.Position(3)-13 (fig.Position(4)-50)]);
        end
        
        function surface()
            tfig = get(groot,'CurrentFigure');
            global figThresh;
            exist figThresh.fig;
            if ~ans
                figThresh = plotthresh;
            end
            ftFig = findobj('type','figure','tag','figThresh');
            if ~isempty(ftFig)
                figure(ftFig);
            end
            if ~isempty(tfig)
%                figure(tfig);
            end
        end
        
    end %methods
    
end

