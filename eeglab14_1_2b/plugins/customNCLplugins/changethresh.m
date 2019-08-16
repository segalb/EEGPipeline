classdef changethresh < handle
    %--------------------------------------------------------------------%
    %
    %
    %Added 11/1/16 by David DiStefano
    %Tuft's University Integrative Cognitive Neuroscience Lab
    %--------------------------------------------------------------------%
    
    properties
        fig; filts; numEpochs; tableData; table;
    end
    
    methods (Static)
        %Create figure with tabulated filter values for a specified epoch
        function obj = changethresh()
            global thresholds; global figChangeThresh;
            figChangeThresh.fig = findobj('tag','figChangeThresh');
            if ~isempty(thresholds) && isempty(figChangeThresh.fig)
                panelColor = [0.93 0.96 1];
                obj.fig = figure('Name','Change Filter Thresholds',...
                    'Tag','figChangeThresh','Position',[50 100 300 900],...
                    'Resize','off','SizeChangedFcn',@plotthresh.Resize_clbk,...
                    'Color',panelColor,'DockControls','off');
                figChangeThresh = obj;
                
                %Create button for displaying window to change thresholds
                uicontrol('Style', 'pushbutton',...
                    'String', '<HTML><center>View Channels',...
                    'Position', [(obj.fig.Position(3)-100)/2 obj.fig.Position(4)-60 100 25],...
                    'Callback', 'plotthresh.surface');
                
                uicontrol(obj.fig,...
                    'Style','text',...
                    'String','Filter Thresholds',...
                    'tag','thresholds',...
                    'Position',[(obj.fig.Position(3)-150)/2 obj.fig.Position(4)-30 150 20],...
                    'FontSize',12,'BackgroundColor',panelColor);
                
                colHeight = 85;
                uicontrol(obj.fig,...
                    'Style','text',...
                    'String','Filter',...
                    'tag','filter',...
                    'Position',[30 obj.fig.Position(4)-colHeight 60 20],...
                    'FontSize',9,'BackgroundColor',panelColor,...
                    'FontWeight','bold');
                uicontrol(obj.fig,...
                    'Style','text',...
                    'String','Current',...
                    'tag','current',...
                    'Position',[(obj.fig.Position(3)-60)/2 obj.fig.Position(4)-colHeight 60 20],...
                    'FontSize',9,'BackgroundColor',panelColor,...
                    'FontWeight','bold');
                uicontrol(obj.fig,...
                    'Style','text',...
                    'String','New',...
                    'tag','newThresh',...
                    'Position',[obj.fig.Position(3)-75 obj.fig.Position(4)-colHeight 60 20],...
                    'FontSize',9,'BackgroundColor',panelColor,...
                    'FontWeight','bold');
                
                obj.filts = fieldnames(thresholds);
                for n = 1:length(obj.filts)
                    uicontrol(obj.fig,...
                        'String',thresholds.(obj.filts{n}).name,...
                        'Style','text','BackgroundColor',panelColor,...
                        'tag',strcat(obj.filts{n},'Label'),...
                        'Position',[35 obj.fig.Position(4)-(colHeight+2)-(n*25) 50 20]);
                    uicontrol(obj.fig,...
                        'String',thresholds.(obj.filts{n}).threshVal,...
                        'Style','text','BackgroundColor',panelColor,...
                        'tag',strcat(obj.filts{n},'Thresh'),...
                        'Position',[(obj.fig.Position(3)-60)/2+5 obj.fig.Position(4)-(colHeight+2)-(n*25) 50 20]);
                    uicontrol(obj.fig,...
                        'Style','edit',...
                        'String',num2str(thresholds.(obj.filts{n}).threshVal),...
                        'tag',obj.filts{n},...
                        'Callback',@changethresh.threshUpdate,...
                        'Position',[(obj.fig.Position(3)-70) obj.fig.Position(4)-(colHeight+2)-(n*25) 50 20]);
                end
                
                tableHeight = obj.fig.Position(4)-15-colHeight-25*length(obj.filts);
                obj.numEpochs = length(thresholds.(obj.filts{1}).thresh);
                
                table = zeros(obj.numEpochs,3);
                totalRejected = 0;
                table(:,1) = 1:obj.numEpochs;
                obj.tableData = num2cell(table);
                
                colergen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD><b>',text,'</b></TD></TR></table></html>'];
                Red = '#FF7777';
                Green = '#AAFFAA';
                for e = 1:obj.numEpochs
                    for n = 1:length(obj.filts)
                        if isempty(thresholds.(obj.filts{n}).thresh)
                            disp(['   ERROR(plotthresh.m) - ''thresholds.',(obj.filts{n}),'.thresh'' is empty']);
                        else
                            if strcmp(thresholds.(obj.filts{n}).type,'flatline')
                                if numel(thresholds.(obj.filts{n}).threshVal)==1
                                    thresholds.(obj.filts{n}).threshVal(1) = -abs(thresholds.(obj.filts{n}).threshVal);
                                    thresholds.(obj.filts{n}).threshVal(2) = abs(thresholds.(obj.filts{n}).threshVal);
                                end
                                if min(thresholds.(obj.filts{n}).thresh(:,e)) <= thresholds.(obj.filts{n}).threshVal(2)
                                    table(e,2) = 1;
                                end
                            else
                                if max(thresholds.(obj.filts{n}).thresh(:,e)) > thresholds.(obj.filts{n}).threshVal
                                    table(e,2) = 1;
                                end
                            end
                        end
                    end
                    if table(e,2)
                        obj.tableData{e,2} = colergen(Red,'Yes');
                        obj.tableData{e,3} = colergen(Red,'Yes');
                    else
                        obj.tableData{e,2} = colergen(Green,'No');
                        obj.tableData{e,3} = colergen(Green,'No');
                    end
                    %obj.tableData{e,3} = colergen(White,'No');
                end
                totalRejected = sum(table(:,2));
                
                colnames = {strcat('<HTML><center>',...
                    'Epoch','<br>','#'),...
                    strcat('<HTML><center>',...
                    'Currently Rejected<br>',...
                    num2str(totalRejected)),...
                    strcat('<HTML><center>',...
                    'Newly Rejected<br>',...
                    '0')};
                
                %Create data table
                obj.table = uitable(obj.fig,'Data',obj.tableData,...
                    'Position',[5 5 obj.fig.Position(3)-5 tableHeight],...
                    'tag','tableData','ColumnName',colnames,...
                    'RowName','','Enable','on','CellSelectionCallback',{@changethresh.cellSelect});
                set(obj.table,'ColumnWidth',{45 (obj.table.Position(3)-65)/2 (obj.table.Position(3)-65)/2});
                figChangeThresh = obj;
            end
        end
        
        function cellSelect(hObject, eventdata, handles)
            if ~isempty(eventdata.Indices)
                global changeEpochNum;
                changeEpochNum = eventdata.Indices(1);
                plotthresh.update(eventdata.Indices(1));
                tFig = gcf;
                eegplotfig = findobj('tag','EEGPLOT','Name','Scroll channel activities -- NCL_eegplot()');
                figure(eegplotfig);
                NCL_eegplot('drawp', 0);
                figure(tFig);
            end
        end
        
        function updateTable()
            global figChangeThresh thresholds;
            figChangeThresh.fig = findobj('tag','figChangeThresh');
            jScrollpane = findjobj(figChangeThresh.fig.Children.findobj('tag','tableData'));
            scrollVal = jScrollpane.getVerticalScrollBar.getValue;
            
            colergen = @(color,text) ['<html><table border=0 width=400 bgcolor=',color,'><TR><TD><b>',text,'</b></TD></TR></table></html>'];
            Red = '#FF7777';
            Green = '#AAFFAA';
            newThreshs = figChangeThresh.fig.findobj('Style','edit','type','uicontrol');
            newThreshs = [{newThreshs(:).Tag}.' {newThreshs(:).String}.'];
            table = zeros(figChangeThresh.numEpochs);
            for e = 1:figChangeThresh.numEpochs
                for n = 1:length(figChangeThresh.filts)
                    if isempty(thresholds.(newThreshs{n,1}).thresh)
                        disp(['   ERROR(plotthresh.m) - ''thresholds.',(newThreshs{n,1}),'.thresh'' is empty']);
                    else
                        if strcmp(thresholds.(newThreshs{n,1}).type,'flatline')
                            if min(thresholds.(newThreshs{n,1}).thresh(:,e)) <= abs(str2num(newThreshs{n,2}))
                                table(e,3) = 1;
                            end
                        else
                            if max(thresholds.(newThreshs{n,1}).thresh(:,e)) > str2num(newThreshs{n,2})
                                table(e,3) = 1;
                            end
                        end
                    end
                end
                if table(e,3)
                    figChangeThresh.table.Data{e,3} = colergen(Red,'Yes');
                else
                    figChangeThresh.table.Data{e,3} = colergen(Green,'No');
                end
            end
            totalRejected = sum(table(:,3));
            figChangeThresh.table.ColumnName{3} = strcat('<HTML><center>Newly Rejected<br>'...
                ,num2str(totalRejected));
            drawnow;
            jScrollpane.getVerticalScrollBar.setValue(scrollVal);
        end
        
        function threshUpdate(hObject, eventdata, handles)
            input = str2double(get(hObject,'String'));
            if isnan(input)
                errordlg('You must enter a numeric value','Invalid Input','modal')
                uicontrol(hObject)
                return
            else
                changethresh.updateTable;
            end
        end
        
        function surface()
            tfig = get(groot,'CurrentFigure');
            global figChangeThresh;
            exist figChangeThresh.fig;
            if ans
                if ~isgraphics(figChangeThresh.fig)
                    changethresh;
                end
            else
                changethresh;
            end
            fctFig = findobj('type','figure','tag','figChangeThresh');
            if ~isempty(fctFig)
                figure(fctFig);
            end
            if ~isempty(tfig)
%                figure(tfig);
            end
        end
        
    end %methods
    
end

