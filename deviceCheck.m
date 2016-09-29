function [devices internal wireless] = deviceCheck
% [devices internal wireless] = deviceCheck
% 
% purpose: find mouse & keyboard IDs for KbCheck
% 
% no inputs required
% 
% two outputs:
% two struct vars for [internal wireless] devices.
% each var has a keyboard and mouse/trackpad field
%
% this ID number (e.g. internal.keyboard) can be used to listen to specific
% devices in, e.g., KbCheck(ID)
% 
% written 2012 by:
% nikki sullivan, nsullivan@caltech.edu
% www.its.caltech.edu/~nsulliva



% to find all discoverable devices:
devices = PsychHID('Devices');


% keyboard codes:
[keyboardID keyboardName] = GetKeyboardIndices;
% find wireless vs. internal:
for nDevice = 1:length(keyboardID)
    if ~isempty(strfind(keyboardName{nDevice},'Wireless'))
        wireless.keyboard = keyboardID(nDevice);
    elseif ~isempty(strfind(keyboardName{nDevice},'Internal'))
        internal.keyboard = keyboardID(nDevice);
    end
end


% mouse OR trackpad codes:
[mouseID mouseName] = GetMouseIndices;
% find wireless vs. internal:
for nDevice = 1:length(mouseID)
    if ~isempty(strfind(mouseName{nDevice},'Magic'))
        wireless.mouse = mouseID(nDevice);
    elseif ~isempty(strfind(mouseName{nDevice},'Internal'))
        internal.mouse = mouseID(nDevice);
    end
end


end % function
