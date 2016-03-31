function myBarPlot(inputArrays,inputStdErr,options)
% myBarPlot(inputArrays,inputStdErr,options)
% 
% multiple bar plots with error bars, saves sized image
%
% mandatory inputs:
%     inputArrays: n x m matrix of n groupings ("ticks") on x-axis,
%                  and m categories per grouping (categories=diff. colored bars)
%     inputStdErr: n x m matrix of the inputArray's standard errors
%
% optional inputs: (in cell string, e.g. {'option1',optionvalue})
%     colors: m x 3 array of rgb values for each of categories
%     xlims or ylims: tuple for min and max x or y value
%               * designating ylims overwrites any re-sizing that might occur as
%               a result of added significance bars
%     xAxisTickLabels: cellstr or double labels for x-axis groupings (optional)
%     xAxisLabel: str to label x-axis with
%     yAxisLabel: str to label y-axis with
%     legendLabels: names of categories (different colored bars)
%     legendLoc: strong. location of legend (default bestoutside)
%     metaTitle: overall graph title
%     figure_no: figure number to use
%     imgName: filename including path and image type (png, jpg, etc.). if path
%              not specified, prints to pwd. if omitted, no image saved.
%     imgsize: [width height] of output image
%     pMatrix: matrix of p-values if you want significance bars drawn.
%         three structures can be designated:
%             .iBar: array the same size as inputArrays with p-values for each
%                    bar's significance (e.g. from zero). this puts just a
%                    significance indicator above that bar. no lines.
%             .cats: One cell for each tick along the x-axis, comparing categories
%                   * structure of the matrix p-values if there are m=4 categories:
%                              | cat1 | cat2 | cat3 | cat4
%                         --------------------------------
%                         cat1 | NaN  |  p   |  p   |  p
%                         --------------------------------
%                         cat2 | NaN  | NaN  |  p   |  p
%                         --------------------------------
%                         cat3 | NaN  | NaN  | NaN  |  p
%                         --------------------------------
%                         cat4 | NaN  | NaN  | NaN  |  NaN
%             .groups: One cell for each category
%                      compare categories across groupings on x-axis:
%                                | xTick1 | xTick2 | xTick3
%                         --------------------------------
%                         xTick1 | NaN    |    p   |    p  
%                         --------------------------------
%                         xTick2 | NaN    |   NaN  |    p  
%                         --------------------------------
%                         xTick3 | NaN    |   NaN  |   NaN 
%         * leave a column NaN if you don't want to compare those bars.
%         * labels bars with *,**,***, and ns for not significant.
%         * i know the first column/last row is not necessary but it's kept
%           strictly for clarity's sake
%
% example: myBarPlot(magic(2),rand(2,2),{'metaTitle','hello world'})
% 
% written 2012 by:
% nikki sullivan, nsullivan@caltech.edu
% www.its.caltech.edu/~nsulliva
% 
% 11-2015: began update to move to object bar handles (not finished)


%% set preferences
if exist('options','var')
    for i=1:length(options)
        if strcmpi(options{i},'xaxisticklabels')
            xAxisTickLabels=options{i+1};
        elseif strcmpi(options{i},'pmatrix')
            pMatrix=options{i+1};
        elseif strcmpi(options{i},'colors')
            colors=options{i+1};
        elseif strcmpi(options{i},'xaxislabel')
            xAxisLabel=options{i+1};
        elseif strcmpi(options{i},'yaxislabel')
            yAxisLabel=options{i+1};
        elseif strcmpi(options{i},'legendlabels')
            legendLabels=options{i+1};
        elseif strcmpi(options{i},'legendloc')
            legendLoc=options{i+1};
        elseif strcmpi(options{i},'metatitle')
            metaTitle=options{i+1};
        elseif strcmpi(options{i},'imgname')
            imgName=options{i+1};
        elseif strcmpi(options{i},'imgsize')
            imgSize=options{i+1};
        elseif strcmpi(options{i},'figure_no')
            figure_no=options{i+1};
        elseif strcmpi(options{i},'xlims')
            xlims=options{i+1};
        elseif strcmpi(options{i},'ylims')
            ylims=options{i+1};
        elseif strcmpi(options{i},'fontSize')
            fontSize=options{i+1};
        end
    end
end


%% plot  bars

if exist('figure_no','var')
    figure(figure_no)
end
if ~exist('fontSize','var')
    fontSize=12;
end
if ~ishold
    hold on
end

% plot bars
barHandle = bar(inputArrays);
if ~isa(barHandle,'double')
    drawnow % this may need to be moved up earlier than if statement for versions earlier than 2015b, need to check
    baroffset = cell2mat({barHandle.XOffset});
end
nBars = size(inputArrays,2); % number of bars per grouping (i.e. number of colors)
nXTicks = size(inputArrays,1); % number of groupings along x=axis

% set colors
if exist('colors','var')
    for cat = 1:nBars
        set(barHandle(cat),'FaceColor',colors(cat,:))
    end
end


%% plot error bars

noEntries=cumprod(size(inputStdErr));
noEntries=noEntries(end);

if exist('inputStdErr','var') && sum(sum(isnan(inputStdErr))) < noEntries

    % find x location for bars (middle of bar) for each data array (data column)
    if isa(barHandle,'double') % matlab changed handles to objects ^#&$*% so this makes it backward-compatible
        for nBar = 1:nBars % commented this 11/3/15
            barLoc = get(get(barHandle(nBar),'Children'),'xdata'); % bar x locations
            errorBarXGuide(:,nBar) = mean(barLoc,1); % horizontal center of the bar
        end
    else        
        for nBar = 1:nBars % added 11/3/15
            errorBarXGuide(:, nBar) = barHandle(nBar).XData+ baroffset(nBar);% horizontal center of the bar
        end
    end
    % now plot them
    if nXTicks > 1        
        errorHandle=errorbar(errorBarXGuide, inputArrays,...
            inputStdErr,'+k');
    else
        errorHandle=errorbar(inputArrays, inputStdErr,'+k');
    end
end

%% label x-ticks, set font
yTicks=get(gca,'YTick');
if exist('xAxisTickLabels','var')
    set(gca,'XTick',1:nXTicks,'XTickLabel',xAxisTickLabels,'fontsize',fontSize)
    set(gca,'YTick',yTicks,'fontsize',fontSize)
else
    set(gca,'XTick',1:nXTicks)
end

%% significance indicators

% get y ticks before you do this
goodYTicks = get(gca,'YTick');
tickSteps = diff(goodYTicks(1:2));
if exist('pMatrix','var')

    pThresh=[0 .001 .01 .05 1];
    pLabel={'','***','**','*','ns'};
    elevate=.1;
    yPosArray=[];
    % for each individual bar (no lines drawn; just an indicator above the bar)
    if isfield(pMatrix,'iBar')
        for cat = 1:nBars
            for xtick =1:nXTicks
                pval = pMatrix.iBar(xtick,cat);
                % what p-level bin does each location fit into?
                pInd = find(pval < pThresh,1,'first');
                xPos = errorBarXGuide(xtick,cat);
                if inputArrays(xtick,cat)>=0
                    yPos = inputArrays(xtick,cat) + inputStdErr(xtick,cat) + ...
                        range(get(gca,'ylim'))*elevate;
                else
                    yPos = inputArrays(xtick,cat) - inputStdErr(xtick,cat) - ...
                        range(get(gca,'ylim'))*elevate;
                end
                if ~isnan(pval)
                    text(xPos,yPos,pLabel{pInd},'HorizontalAlignment','center','fontsize',15)
                    yPosArray = [yPosArray yPos]; % for re-sizing later
                end
            end
        end
        elevate=.1;
    end
    % for comparison between categories inside one x-tick grouping
    if isfield(pMatrix,'cats')
        catCombinations = combnk(1:nBars,2);
        for xtick =1:nXTicks
            for combos = 1:size(catCombinations,1)
                thisComarison = catCombinations(combos,:);
                pval = pMatrix.cats{xtick}(thisComarison(1),thisComarison(2));
                % what p-level bin does each location fit into?
                pInd = find(pval < pThresh,1,'first');
                xPos = mean(errorBarXGuide(xtick,thisComarison));
                if sum(sign(inputArrays(xtick,thisComarison)))==0
                    yPos = max(inputArrays(xtick,thisComarison) + ...
                        inputStdErr(xtick,thisComarison)) + ...
                        range(get(gca,'ylim'))*elevate;
                elseif sum(sign(inputArrays(xtick,thisComarison)))>0
                    yPos = max(inputArrays(xtick,thisComarison) + ...
                        inputStdErr(xtick,thisComarison)) + ...
                        range(get(gca,'ylim'))*elevate;
                elseif sum(sign(inputArrays(xtick,thisComarison)))<0
                    yPos = min(inputArrays(xtick,thisComarison) - ...
                        inputStdErr(xtick,thisComarison)) - ...
                        range(get(gca,'ylim'))*elevate;
                end
                if ~isnan(pval)
                    line([errorBarXGuide(xtick,thisComarison(1)) errorBarXGuide(xtick,thisComarison(2))],...
                        [yPos yPos],'color','k')
                    if yPos >= 0
                        amntToSubtract = range(get(gca,'ylim'))*(elevate*.3);
                    else
                        amntToSubtract = range(get(gca,'ylim'))*(elevate*.3)*-1;
                    end
                    line([errorBarXGuide(xtick,thisComarison(1)) errorBarXGuide(xtick,thisComarison(1))],...
                        [yPos yPos-amntToSubtract],'color','k')
                    line([errorBarXGuide(xtick,thisComarison(2)) errorBarXGuide(xtick,thisComarison(2))],...
                        [yPos yPos-amntToSubtract],'color','k')
                    text(xPos,yPos,pLabel{pInd},'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','center','fontsize',15)
                    yPosArray = [yPosArray yPos]; % for re-sizing later
                    elevate=elevate+.04;
                    
                end
            end
        end
        elevate=elevate+.05;
    end
    % for each category and x-tick comparison
    if isfield(pMatrix,'groups')
        xTickCombinations = combnk(1:nXTicks,2);
        for cat = 1:nBars
            for combos = 1:size(xTickCombinations,1)
                thisComarison = xTickCombinations(combos,:);
                pval = pMatrix.groups{cat}(thisComarison(1),thisComarison(2));
                % what p-level bin does each location fit into?
                pInd = find(pval < pThresh,1,'first');
                xPos = mean(errorBarXGuide(thisComarison,cat));
                yPos = max(inputArrays(thisComarison,cat) + inputStdErr(thisComarison,cat)) + ...
                    range(get(gca,'ylim'))*elevate;
                if ~isnan(pval)
                    line([errorBarXGuide(thisComarison(1),cat) errorBarXGuide(thisComarison(2),cat)],...
                        [yPos yPos],'color','k')
                    amntToSubtract = range(get(gca,'ylim'))*(elevate*.3);
                    line([errorBarXGuide(thisComarison(1),cat) errorBarXGuide(thisComarison(1),cat)],...
                        [yPos yPos-amntToSubtract],'color','k')
                    line([errorBarXGuide(thisComarison(2),cat) errorBarXGuide(thisComarison(2),cat)],...
                        [yPos yPos-amntToSubtract],'color','k')
                    text(xPos,yPos,pLabel{pInd},'BackgroundColor',[1 1 1],...
                        'HorizontalAlignment','center','fontsize',15)
                    yPosArray = [yPosArray yPos]; % for re-sizing later
                    elevate=elevate+.04;
                end
            end
        end
    end
    
    % re-size x-limits if necessary (if y limits not externally called)
    if ~exist('ylims','var')
        newYLimits=get(gca,'YLim');
        if newYLimits(1) > min(yPosArray)-min(yPosArray)*.1
            newYLimits(1)=min(yPosArray)-min(yPosArray)*.1;
        end
        if newYLimits(2) < max(yPosArray)+max(yPosArray)*.1
            newYLimits(2)=max(yPosArray)+max(yPosArray)*.1;
        end
        ylim(newYLimits)
    end

end



%% add labels, titles, legend, etc.

if exist('xAxisLabel','var')
    xlabel(xAxisLabel,'fontsize',fontSize)
end
if exist('yAxisLabel','var')
    ylabel(yAxisLabel,'fontsize',fontSize)
end
if exist('legendLabels','var')
    if exist('legendLoc','var')
        legend(legendLabels,'location',legendLoc,'fontsize',fontSize*.8)
    else
        legend(legendLabels,'location','bestoutside','fontsize',fontSize*.8)
    end
    legend BOXOFF
end
if exist('metaTitle','var')
    title(metaTitle,'fontweight','bold','fontsize',10)
end
if exist('xlims','var')
    xlim(xlims)
end
if exist('ylims','var')
    ylim(ylims)
    ticks = round(linspace(ylims(1),ylims(end),5));
    set(gca,'YTick',ticks)
else
    if exist('yPosArray','var')
        set(gca,'YTick',goodYTicks(1):tickSteps:(tickSteps*2+yPosArray(end)))
    end
end


%% dimensions of figure

if exist('imgSize','var')
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [1 1 imgSize(1) imgSize(2)]);
end

%% save figure if desired

if exist('imgName','var')

    saveas(gca,imgName)
end


end % function