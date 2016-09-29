function printRegTable(stats,regressorNames,regressorIndicator,options)
% printRegTable(stats,regressorNames,regressorIndicator,{options})
% prints results of regstats in regression table format to text file and/or screen.
% can be used with multiple models or just one model.
% 
% mandatory inputs:
% - stats: output of regstats in the following format:
%       * nModels x 1 cell variable
%           - if only one model, can just input the struct var from regstats.
%     	* in regstats: can use 'all' flag or just the following flags:
%             * {'rsquare', 'adjrsquare', 'tstat', 'yhat','beta','mse'}
% - regressorNames: nVars x 1 cellstr of variables in all the models. 
%       * include all regressor names in all of the  models (EXCEPT constant).
%       * for pretty tables, regressor names should be short.
% - regressorIndicator: nModels x nRegressors indicator array (0 or 1) 
%       * designates which regressors specified in regressorNames are 
%         in each model.
% 
% optional inputs: (in cell string, e.g. {'option1',optionvalue})
% - filename: file name of text file to save as (do not include .txt suffix).
%       * if omitted, no file is saved.
%       * to save somewhere other than pwd, include directory in file name
%         e.g. 'fullpath/filename' OR 'subdirectory/filename'
% - displayType is 'silent' if you don't want output to screen and 'noisy' 
%   if you want output printed.
%       - default is noisy if you're not saving a file, silent if you are.
% 
% note: if no file name specified, but display type is 'silent', it still
% outputs to the screen because... otherwise why are you calling this script??
%
% example use:
%   generating data for input:
%     stats = regstats(y,X,model,{'rsquare', 'adjrsquare', 'tstat', 'yhat', 'beta', 'mse'})
%           -OR-
%     stats{1} = regstats(y,X1,model,'all')
%     stats{2} = regstats(y,X2,model,'all')
%     stats{3} = regstats(y,X2,model,'all')
%     etc.
%   calling printRegTable:
%     just one model run:
%         printRegTable(stats,{'Var1Name' 'Var2Name' 'Var3Name'},[1 1 1]...
%           {''displaytype','noisy','filename','textfilename'})
%     three models:
%         printRegTable(stats,{'Var1Name' 'Var2Name' 'Var3Name'},...
%            [1 0 0;1 1 0;1 1 1]...
%           {''displaytype','noisy','filename','textfilename'})
% 
% written 2012 by:
% nikki sullivan, nsullivan@caltech.edu
% www.its.caltech.edu/~nsulliva

% set defaults
saveVar=false;

% set preferences
if exist('options','var')
    for i=1:length(options)
        if strcmpi(options{i},'displaytype')
            displayType=options{i+1};
        elseif strcmpi(options{i},'filename')
            filename=options{i+1};
            saveVar=true;
        end
    end
end

if ~exist('filename','var')
    displayType='noisy';
elseif exist('filename','var') && ~exist('displayType','var')
    displayType = 'silent';
end


%% get model details:

nRegressors = length(regressorNames);

if isstruct(stats) % just one model
    
    nModels = 1;
    
    temp = stats;
    clear stats
    stats{1} = temp;
    clear temp

        
elseif iscell(stats)
    
    nModels = length(stats);

else
    
    disp('error. stats variable is not in the correct format.')
    disp('see help printRegTable for correct formats')
    return
    
end

if length(regressorNames) ~= size(regressorIndicator,2)
    
    disp(['error. make sure there are the same number of regressor names' ...
        ' as regressor indicators.'])
    display(['currently, nRegressors = ' num2str(length(regressorNames))' ...
        ' and nIndicators = ' num2str(size(regressorIndicator,2)) '.'])
    disp('see help printRegTable for correct formats')
    return
    
end


%% make table

% column 1 (names, headings, etc.):
row = cell(1,1);
for regInd = 1:nRegressors % reg information rows
    row{size(row,1)+1,1} = regressorNames{regInd};
    row{size(row,1)+1,1} = [];
end
row{size(row,1)+1,1} = 'Constant';
row{size(row,1)+1,1} = [];
row{size(row,1)+1,1} = '-----------------';
row{size(row,1)+1,1} = 'R-squared';
row{size(row,1)+1,1} = 'Adjust. R-squared';
row{size(row,1)+1,1} = 'MSE';
row{size(row,1)+1,1} = 'N';
row{size(row,1)+1,1} = '-----------------';
row{size(row,1)+1,1} = 't-statistic in parentheses';
row{size(row,1)+1,1} = '*p<.05 **p<.01 ***p<.001';

% columns 2:nModels (statistics):
for modelInd = 1:nModels
    row{1,modelInd+1} = ['Model (' num2str(modelInd) ')'];

    statInd = 2; % row to put stat info
    statStructInd = 1; % place to pull from in stats var
    for regInd = 1:nRegressors
        
        if regressorIndicator(modelInd,regInd)

            if stats{modelInd}.tstat.pval(statStructInd+1) < .001
                pvalIndicator = '***';
            elseif stats{modelInd}.tstat.pval(statStructInd+1) < .01
                pvalIndicator = '**';
            elseif stats{modelInd}.tstat.pval(statStructInd+1) < .05
                pvalIndicator = '*';
            else
                pvalIndicator = '';
            end

            row{statInd,modelInd+1} = [num2str(roundn(stats{modelInd}.beta(statStructInd+1),-3)) pvalIndicator];
            statInd = statInd+1;
            row{statInd,modelInd+1} = ['(' num2str(roundn(stats{modelInd}.tstat.t(statStructInd+1),-3)) ')'];
            statInd = statInd+1;
            
            statStructInd = statStructInd + 1;
        else
            row{statInd,modelInd+1} = [];
            statInd = statInd+1;
            row{statInd,modelInd+1} = [];
            statInd = statInd+1;
        end
    end

    % constant
    if stats{modelInd}.tstat.pval(1) < .001
        pvalIndicator = '***';
    elseif stats{modelInd}.tstat.pval(1) < .01
        pvalIndicator = '**';
    elseif stats{modelInd}.tstat.pval(1) < .05
        pvalIndicator = '*';
    else
        pvalIndicator = '';
    end        
    row{statInd,modelInd+1} = num2str(roundn(stats{modelInd}.beta(1),-2));
    statInd = statInd+1;
    row{statInd,modelInd+1} =['(' num2str(roundn(stats{modelInd}.tstat.t(1),-2)) ')'];
    statInd = statInd+1;
    row{statInd,modelInd+1} ='---';
    statInd = statInd+1;

    % model stats
    row{statInd,modelInd+1} = num2str(roundn(stats{modelInd}.rsquare,-2));
    statInd = statInd+1;
    row{statInd,modelInd+1} = num2str(roundn(stats{modelInd}.adjrsquare,-2));
    statInd = statInd+1;
    row{statInd,modelInd+1} = num2str(roundn(stats{modelInd}.mse,-2));
    statInd = statInd+1;
    row{statInd,modelInd+1} = num2str(length(stats{modelInd}.yhat));
    statInd = statInd+1;
    row{statInd,modelInd+1} = '---';

end




%% save and/or print to command window

switch saveVar
    case true % print to text file
        
        % create table to save:
        table=[];
        fullRow = cell(1,size(row,1));
        for rInd = 1:size(row,1)

            fullRow{rInd} = row{rInd,1};
            for cInd = 2:size(row,2) % gather all columns
                fullRow{rInd} = [fullRow{rInd} '\t' row{rInd,cInd}];
            end

            table = [table '\n' fullRow{rInd}];

        end
        
        pathInd = findstr('/',filename); % is path specified?
        if isempty(pathInd)
            [fid,~] = fopen([pwd '/' filename '.txt'], 'w');
        else
            [fid,~] = fopen([filename '.txt'], 'w');
        end
        fprintf(fid, table);
        fclose(fid);
        
        switch displayType
            case 'noisy'
                disp(row)
                disp(' ')
                if ~isempty(pathInd)
                    disp(['in directory ' filename(1:pathInd)])
                    disp(['results saved to text file ' filename(pathInd+1:end) '.txt'])
                else
                    disp(['in directory ' pwd])
                    disp(['results saved to text file ' filename '.txt'])
                end
        end
        
    case false % don't print to text file
        
        switch displayType
            case 'noisy'
                disp(row)        
                disp(' ')
                disp('results not saved to text file, but printed above.')
        end
        
end


end
