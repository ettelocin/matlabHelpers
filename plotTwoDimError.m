function h = plotTwoDimError(xData,yData,xError,yError,options)
% h = plotTwoDimError(xData,yData,xError,yError,options)
% plots a line with shaded error bars in both x and y dimensions.
% this is useful for plotting two-dim spatial data e.g. trajectories
% 
% handle output is h.line for the mean data line, h.error lines
%
% mandatory inputs:
%     xData and yData: data to plot the main average data line
%     xError and yError: error in the x-dimension and y-dimension, respectively.
%         if x- or y-dim have different upper and lower error, use two rows. 
%         (otherwise assumed to be symmetrical)
% 
% optional inputs:
%     options: cell array with line property options. allowable options are:
%         plotType: 'shaded' (default) vs. 'bars' for error bars at each point.
%         lineColor (rgb array or string, e.g. [1 0 0] or 'r')
%         lineWidth (default 1.5)
%         lineStyle (default '-')
%         marker (default 'none')
%         patchSaturation (number from 0 to 1. how much color to take away
%               from the line color for the error bar, default 0.3)
%         overlayLines (true/false. overlay x and y dim error on top of each 
%               other - makes overlapping error darker. defaults true.)
% 
% written 2013 by:
% nikki sullivan, nsullivan@caltech.edu
% www.its.caltech.edu/~nsulliva



%% check yo self

if (size(xData,2) ~= size(yData,2)) || (size(xError,2) ~= size(yError,2))
    disp('All arrays must be of equal length.')
    return
end

% set defaults:
plotType='shaded';
patchSaturation=0.3;
overlayLines=true;
lineColor=[0 0 0];
lineWidth=1.5;
lineStyle='-';
marker='none';

% set preferences
if exist('options','var')
    for i=1:length(options)
        if strcmpi(options{i},'plottype')
            plotType=options{i+1};
        elseif strcmpi(options{i},'linecolor')
            lineColor=options{i+1};
        elseif strcmpi(options{i},'linewidth')
            lineWidth=options{i+1};
        elseif strcmpi(options{i},'linestyle')
            lineStyle=options{i+1};
        elseif strcmpi(options{i},'marker')
            marker=options{i+1};
        elseif strcmpi(options{i},'patchsaturation')
            patchSaturation=options{i+1};
        elseif strcmpi(options{i},'overlaylines')
            overlayLines=options{i+1};
        end
    end
end

% if doing bar plot and lineStyle==none but no marker type specified, this 
% won't plot a thing. so designate a marker:
if strcmp('none',lineStyle) && strcmp('none',marker) && strcmp('bars',plotType)
    marker='.';
end

% re-shape data if necessary
if size(xData,1)>1
    xData=xData';
end
if size(yData,1)>1
    yData=yData';
end
if size(xError,1)>2
    xError=xError';
end
if size(yError,1)>2
    yError=yError';
end


%% create error bar arrays

% upper and lower error different or the same?
% (row 1 = upper, row 2 = lower)
if size(xError,1)==1
    xError(2,:) = xError(1,:);
end
if size(yError,1)==1
    yError(2,:) = yError(1,:);
end

% now create a line for each data point representing the error in each dim
xErrorLine = [(xData+xError(1,:));(xData-xError(2,:))];
yErrorLine = [(yData+yError(1,:));(yData-yError(2,:))];


%% plot that noise! (get it?)

if ~ishold
    hold on
end

% main data line:
h.line=plot(xData,yData,'linewidth',lineWidth,'color',lineColor,...
    'linestyle',lineStyle,'marker',marker);

% error:
if strcmp(plotType,'bars')
    
    % error bar cap size (.5% of data spread)
    xCapSize = range(xData) * .01;
    yCapSize = range(yData) * .01;

    % plot them error bars (always solid lines, on purpose)
    h.error(:,1)=plot(xErrorLine,[yData;yData],...
        'linewidth',lineWidth-.5,'color',lineColor);
    h.error(:,2)=plot([xData;xData],yErrorLine,...
        'linewidth',lineWidth-.5,'color',lineColor);
    % x-dim caps:
    h.error(:,3)=plot([xErrorLine(1,:);xErrorLine(1,:)],...
        [yData+xCapSize;yData-xCapSize],...
        'linewidth',lineWidth-.5,'color',lineColor);
    h.error(:,4)=plot([xErrorLine(2,:);xErrorLine(2,:)],...
        [yData+xCapSize;yData-xCapSize],...
        'linewidth',lineWidth-.5,'color',lineColor);
    % y-dim caps
    h.error(:,5)=plot([xData-yCapSize;xData+yCapSize],...
        [yErrorLine(1,:);yErrorLine(1,:)],...
        'linewidth',lineWidth-.5,'color',lineColor);
    h.error(:,6)=plot([xData-yCapSize;xData+yCapSize],...
        [yErrorLine(2,:);yErrorLine(2,:)],...
        'linewidth',lineWidth-.5,'color',lineColor);
    
elseif strcmp(plotType,'shaded')
    
    % y-dim error polygon:
    yDimPatch_xVals=[xData,fliplr(xData)];
    yDimPatch_yVals=[yErrorLine(2,:),fliplr(yErrorLine(1,:))];
    
    
    % x-dim error polygon:
    xDimPatch_xVals=[xErrorLine(2,:),fliplr(xErrorLine(1,:))];
    xDimPatch_yVals=[yData,fliplr(yData)];
    
    set(gcf,'renderer','openGL')

    % plot patches separately or together:
    if overlayLines
        
        h.error(1)=patch(yDimPatch_xVals,yDimPatch_yVals,1,'facecolor',...
            lineColor,'edgecolor','none','facealpha',patchSaturation);
        h.error(2)=patch(xDimPatch_xVals,xDimPatch_yVals,1,'facecolor',...
            lineColor,'edgecolor','none','facealpha',patchSaturation);
        
        %plot(yDimPatch_xVals,yDimPatch_yVals,'color',lineColor,'linestyle',':')
        %plot(xDimPatch_xVals,xDimPatch_yVals,'color',lineColor,'linestyle',':')
    else
        
        % union of x and y error bars:
        [yDimPatch_xVals,yDimPatch_yVals]=... %only necessary so polybool doesn't complain
            poly2cw(yDimPatch_xVals,yDimPatch_yVals);
        [xDimPatch_xVals,xDimPatch_yVals]=... %only necessary so polybool doesn't complain
            poly2cw(xDimPatch_xVals,xDimPatch_yVals);
        [bothDimPatch_xVals,bothDimPatch_yVals] = ...
            polybool('union',yDimPatch_xVals,yDimPatch_yVals,...
            xDimPatch_xVals,xDimPatch_yVals);
        
        bothDimPatch_xVals(isnan(bothDimPatch_xVals)) = xData(end);
        bothDimPatch_yVals(isnan(bothDimPatch_yVals)) = yData(end);
        
        h.error=patch(bothDimPatch_xVals,bothDimPatch_yVals,1,'facecolor',...
            lineColor,'edgecolor','none','facealpha',patchSaturation);
        
        %plot(bothDimPatch_xVals,bothDimPatch_yVals,'color',lineColor,'linestyle',':')
    end

end


end
