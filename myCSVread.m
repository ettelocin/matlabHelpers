function data = myCSVread(filename)
% data = myCSVread(filename)
% input csv file name, outputs structure array of variables
% creates variable names from column headers
%
% restrictions: 
%     *no commas can be in the csv file
%     *no spaces in header names
%     *no empty fields - instead put NaN there.
% 
% written 2012 by:
% nikki sullivan, nsullivan@caltech.edu
% www.its.caltech.edu/~nsulliva

if exist(filename,'file')
    fid = fopen(filename, 'r');
    tline = fgetl(fid);
else
    sprintf('%s does not exist.',filename)
    return
end

% header
clear tempVar
tempVar(1,:) = regexp(tline, '\,', 'split');

ctr = 2;
while(~feof(fid))
    tline = fgetl(fid);
    try
        tempVar(ctr,:) = regexp(tline, '\,', 'split');
    catch
        tline
    end
    ctr = ctr + 1;
end

% put into variables, turn numbers into int
varNames = tempVar(1,:);
data = cell2struct(varNames,varNames,2);
for dataVar=1:length(varNames)
    % determine if this is a string or number variable:
    try 
        eval([cell2mat(tempVar(2,dataVar)) ';' ]);
        varIsString=false;
        data.(varNames{dataVar})=[];
    catch
        varIsString=true;
        data.(varNames{dataVar})={};
    end
    if varIsString
        data.(varNames{dataVar}) = tempVar(2:end,dataVar);
    else % convert to integer
        for entry = 1:length(tempVar(2:end,dataVar))
            if strcmp(tempVar(entry,dataVar),'NaN')
                data.(varNames{dataVar})(entry) = NaN;
            else
                try
                    data.(varNames{dataVar})(entry) = ...
                        eval(cell2mat(tempVar(entry+1,dataVar)));
                catch
                    if strcmp(tempVar(entry+1,dataVar),'#VALUE!') || ...
                        isempty(tempVar{entry+1,dataVar})
                        data.(varNames{dataVar})(entry) = NaN;
                    end
                end
            end
        end
    end
end

fclose(fid);

end
