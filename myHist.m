function myHist(inputArrays,options)
% myHist(inputArrays,{options})
% plots one/many histograms, and saves image
% 
% mandatory inputs:
%     inputArrays: array of histogram subplots to plot (an be cells or other)
%         if array of double/etc., subplots are rows - so size nSubplots x 
%         nDataPoints
% 
% optional inputs (case insensitive): in cell string, e.g. {'option1',optionvalue}
%     figure_no: number to assign the figure if desired
%     xAxisLabel: label for x axis
%     yaxislabel: label for y axis; "frequency" by default.
%     type: 'overlay' (default) overlays histograms on top of one another.
%           'subplots' creates separate plots for each array.
%     arrayNames: cellstr array for names for each data array.
%           - if type is 'overlay': labels for legend
%           - if type is 'subplot': titles for individual subplots
%           - leave blank if you don't want to label arrays
%     metaTitle: overall graph title (larger than any subtitles)
%     fontSize: 20 by default.
%     barColors: nSubplots x 3 of rgb values for histogram colors.
%           - default draws from matlab's "lines" colormap
%           - note that if "overlay', colors will be fainter than you
%           expect because they'll be made partially transparent.
%     normalizeXAxis: true/false (default=true) - should the x limits on each
%              histogram plot be the same range? - OBSOLETE. NOW MANDATORY.
%           - only relevant for type = 'subplot'
%     yLimit: forces histogram y axis to be of x to yLimit range.
%     xLimits: forces x axis limits
%     imgName: filename including path and image type (png, jpg, etc.). if path
%              not specified, prints to pwd. if omitted, no image saved.
%     imgSize: [width height] of output image
% 
% 2012/2014, nikki sullivan, nsullivan@caltech.edu
% www.its.caltech.edu/~nsulliva


% set preferences
if exist('options','var')
    for i=1:length(options)
        if strcmpi(options{i},'arrayNames')
            arrayNames=options{i+1};
        elseif strcmpi(options{i},'metatitle')
            metaTitle=options{i+1};
        elseif strcmpi(options{i},'imgname')
            imgName=options{i+1};
        elseif strcmpi(options{i},'figure_no')
            figure_no=options{i+1};
        elseif strcmpi(options{i},'imgsize')
            imgSize=options{i+1};
        elseif strcmpi(options{i},'xaxislabel')
            xAxisLabel=options{i+1};
        elseif strcmpi(options{i},'yaxislabel')
            yAxisLabel=options{i+1};
        elseif strcmpi(options{i},'barColors')
            barColors=options{i+1};
        elseif strcmpi(options{i},'yLimit')
            yLimit=options{i+1};
        elseif strcmpi(options{i},'xLimits')
            xLimits=options{i+1};
        elseif strcmpi(options{i},'normalizexaxis')
            normalizeXAxis=options{i+1};
        elseif strcmpi(options{i},'fontsize')
            fontSize = options{i+1};
        elseif strcmpi(options{i},'type')
            type=options{i+1};
        end
    end
end


%% settings

% reshape if necessary (assume more observations than variables)
% how many variables
sz = size(inputArrays);
% assume more observations than vars (obviously)
if iscell(inputArrays)
    nArraysToPlot = length(inputArrays);
else
    varDim = find(sz == min(sz));
    % reshape if necessary
    if varDim ~= 1; 
        inputArrays = inputArrays';
    end
    nArraysToPlot = size(inputArrays,1);
end

if ~exist('barColors','var')
    barColors = lines(nArraysToPlot);
end
% if exist('figure_no','var')
%     figure(figure_no);
% else
%     clf
% end
if ~exist('yAxisLabel','var')
    yAxisLabel = 'Frequency';
end
if ~exist('fontSize','var')
    fontSize = 20;
end
if ~exist('type','var')
    type = 'subplots';
end

%% set up plot data and bins

% make bins
for arrayInd = 1:nArraysToPlot
    if iscell(inputArrays)
        small(arrayInd)=min(inputArrays{arrayInd});
        large(arrayInd)=max(inputArrays{arrayInd});
    else
        small(arrayInd)=min(inputArrays(arrayInd,:));
        large(arrayInd)=max(inputArrays(arrayInd,:));
    end
end
bins = linspace(min(small),max(large),10);

% find values etc.
for arrayInd = 1:nArraysToPlot
    if iscell(inputArrays)
        [counts(arrayInd,:), values(arrayInd,:)] = hist(inputArrays{arrayInd}, bins);
    else
        [counts(arrayInd,:), values(arrayInd,:)] = hist(inputArrays(arrayInd,:), bins);
    end
end


%% plot data

switch type
    case 'subplots'
        
        for arrayInd = 1:nArraysToPlot % for each subplot
            
            if nArraysToPlot > 1
                subplot(nArraysToPlot,1,arrayInd)
            end

            h = bar(values(arrayInd,:), counts(arrayInd,:));
            if isa(h, 'double')
                ph = arrayfun(@(x) allchild(x),h);
                set(ph,'FaceColor',barColors(arrayInd,:),'EdgeColor','k')
            else
                h.FaceColor = barColors(arrayInd,:);
            end
            
            % set y limit if specified
            if exist('yLimit','var')
                ylim([0 yLimit])
            end
            if exist('xLimits','var')
                xlim(xLimits)
            end
            
            set(gca,'fontsize',fontSize,'box','off')
            
            histYlim(arrayInd,:) = get(gca,'Ylim');
            histXlim(arrayInd,:) = get(gca,'Xlim');

            if arrayInd == nArraysToPlot && exist('xAxisLabel','var')
                xlabel(xAxisLabel,'fontsize',fontSize);
            end

        end
        
        % norm plot y limits
        if nArraysToPlot > 1
            for arrayInd = 1:nArraysToPlot
                subplot(nArraysToPlot,1,arrayInd)
                ylim([0 max(histYlim(:,2))])
            end
        end
        
    case 'overlay'
        
        hold on;
        for arrayInd = 1:nArraysToPlot
            
            h = bar(values(arrayInd,:), counts(arrayInd,:));
            if isa(h,'double')
                ph = arrayfun(@(x) allchild(x),h);
                set(ph,'FaceAlpha',.4,'FaceColor',barColors(arrayInd,:),'EdgeColor','k')
            end
            
            histYlim(arrayInd,:) = get(gca,'Ylim');
            histXlim(arrayInd,:) = get(gca,'Xlim');
            
            graphkey(arrayInd) = h;
        end
                
        if exist('xAxisLabel','var')
            xlabel(xAxisLabel,'fontsize',fontSize);
        end
        
        if exist('yLimit','var')
            ylim([0 yLimit])
        end
        if exist('xLimits','var')
            xlim(xLimits)
        end
        
        set(gca,'fontsize',fontSize,'box','off')
end


%% subplot titles or legend


if exist('arrayNames','var')
    switch type
        case 'subplots'
            if nArraysToPlot > 1
                for arrayInd = 1:nArraysToPlot
                    subplot(nArraysToPlot,1,arrayInd)
                    title(arrayNames{arrayInd},...
                        'Position',[mean(get(gca,'XLim')) max(get(gca,'YLim'))*.87],...
                        'fontsize',fontSize*.8)
                end
            end
        case 'overlay'
            if nArraysToPlot > 1 && exist('arrayNames','var')
                h = legend(graphkey, arrayNames, 'location','best', ...
                    'fontsize',fontSize*.7);
                i = get(h, 'children');
                legendDimmer = 1:2:length(i);
                count=length(legendDimmer);
                for j = legendDimmer
                    ph = arrayfun(@(x) allchild(x),i(j));
                    set(ph,'FaceAlpha',.4,'FaceColor',barColors(count,:))
                    count=count-1;
                end
            end
    end
end


%% overall title & y label

if exist('metaTitle','var') && nArraysToPlot > 1 && strcmp(type,'subplots')
    set(gcf,'NextPlot','add');axes;
    h(1) = title(metaTitle,'FontWeight','bold','fontsize',fontSize);
    h(2) = ylabel(yAxisLabel,'fontsize',fontSize);
    set(gca,'Visible','off');
    set(h,'Visible','on'); 
elseif exist('metaTitle','var')
    title(metaTitle,'FontWeight','bold');
    ylabel(yAxisLabel,'fontsize',fontSize);
elseif strcmp(type,'subplots')
    set(gcf,'NextPlot','add');axes;
    h = ylabel(yAxisLabel,'fontsize',fontSize);
    set(gca,'Visible','off');
    set(h,'Visible','on'); 
else
    ylabel(yAxisLabel,'fontsize',fontSize);
end


%% dimensions of figure

if exist('imgSize','var')
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [0 0 imgSize(1) imgSize(2)]);
    set(gcf, 'PaperSize', [imgSize(1) imgSize(2)])
end


%% save figure if desired

if exist('imgName','var')
    saveas(gca,imgName)
    %print('-dpsc2', '-noui', '-adobecset', '-painters', imgName);

end

hold off
end % function
