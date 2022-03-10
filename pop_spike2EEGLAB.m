% spike2EEGLAB()--load CED Spike format dataset and return EEGLAB EEG structure
%
% Usage:
%   >> [EEG] = spike2EEGLAB(fileName)
%
% Inputs:
%   fileName  - path to file (e.g. 'sample_data.mat')
% Outputs:
%   EEG       - EEGLAB EEG structure
%
% Note:
%   Import is possible with .mat files that can be exported from CED Spike
%   software.
%
% Author: P. Dzianok, 2020-2022
% Copyright (C) 2020 P. Dzianok, mail@ptdz.pl
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% Revision 1.2 03.2022 PTDZ
% adding EEG structure update for new versions of EEGLAB (2019.1 and later)
% adding possibility of loading files through EEGLAB GUI
% Revision 1.1 06.2021 PTDZ
% adding DigMark reading

function [EEG] = pop_spike2EEGLAB(fileName)

EEG = [];

if nargin < 1
    [fileName,pwd] = uigetfile2('*.mat', 'Select CED Spike .mat file:');
end

     % File reading
     matFileName = fullfile(pwd,  fileName);
     if ~exist(matFileName, 'file')
       message = sprintf('%s file does not exist', matFileName);
       uiwait(warndlg(message));
     else
      spikeMat = load(matFileName);
     end
     clearvars matFileName

    spikeMat = struct2cell(spikeMat);

    countChan = 0;
    countEvents = 0;
    uN_digit = 0;

    for ii=1:length(spikeMat)

        % Some channels imported from Spike have different points number
        % (this part checkes and corrects the data)

        % List of all lengths
        for jj=1:length(spikeMat)
           if isfield(spikeMat{jj}, 'values') == 1
            chanLength(jj) = spikeMat{jj}.length;
           end
        end
        clearvars jj

        % Check unique
        isTheSame = unique(chanLength);
        % Delete zeros
        isTheSame(isTheSame==0) = [];
        % Maximum
        maxLength = max(isTheSame);

        if isfield(spikeMat{ii}, 'values') == 1

            % Last channel, sampling rate calc
            chanFieldNo = ii;

            countChan = countChan + 1;

            % If the length of a given channel is less than max
            currentLen = length(spikeMat{ii}.values);
            if currentLen < maxLength
                % Fill the remaining values with zeros
                spikeMat{ii}.values(currentLen+1:maxLength,1) = 0;
                % Time (last sample)
                lastTime = spikeMat{ii}.times(end);
                spikeMat{ii}.times(currentLen+1:maxLength,1) = lastTime;
            end

            % Assigning values: channels
            chanValues(:,countChan) = spikeMat{ii}.values;
            chanNames{1,countChan} = spikeMat{ii}.title;

            % If the time field exists write appropriate values
            % If not, then time will be a vecor from 1 to the end of all
            % samples
            if isfield(spikeMat{ii}, 'times') == 1
                chanxMax = spikeMat{ii}.times(end);
                chanTimes = transpose(spikeMat{ii}.times);
            else
                chanTimes = 1:maxLength;
                chanxMax = maxLength;
            end

        else
            % Assigning values: event channels
            if isfield(spikeMat{ii}, 'title') == 1 % If title field exists, if not - skip

             countEvents = countEvents + 1;

             % Give own event channel name, Unnamed_1 + consecutive digits, if the channel has an empty name

             if strcmp('',spikeMat{ii}.title)
                 uN_digit = uN_digit + 1;
                 spikeMat{ii}.title = append('Unnamed_',num2str(uN_digit));
             end

                eventNames{1,countEvents} = spikeMat{ii}.title;
                eventTimes{1,countEvents} = spikeMat{ii}.times;


                % Keyboard and DigMark key press codes
                 if strcmp(spikeMat{ii}.title,'Keyboard') || strcmp(spikeMat{ii}.title,'DigMark')
                    eventCodes{1,countEvents} = double(spikeMat{ii}.codes(:,1));
                 else
                    eventCodes{1,countEvents} = spikeMat{ii}.title;
                 end

             end
         end

    end
    clearvars countChan countEvents ii

    % Sampling rate
    if isfield(spikeMat{chanFieldNo}, 'interval') == 1
         sRate = 1 / spikeMat{chanFieldNo}.interval;
         sRate = round(sRate,2);
    else
         sRate = maxLength/chanxMax;
         sRate = round(sRate,2);
    end

    chanValues = transpose(chanValues);

    if exist('eventNames','var') == 1
        % Event list
        fromT = 1;
        for jj = 1:length(eventNames)

            lenEvent = length(eventTimes{jj});

            if jj == 1
                toT = lenEvent;
            else
                toT = lenEvent+fromT-1;
            end

            spikeMatevent.latency(fromT:toT,1) = eventTimes{jj}*sRate;
            spikeMatevent.duration(fromT:toT,1) = 1;

            % Applies to both keyboard ('Keyboard') and ('DigMark') events
            countKeyboard = 0;

            for tt = fromT:toT
                spikeMatevent.code{tt,1} = eventNames{jj};

            % If the eventCodes variable was created before, it means that
            % keyboard events were added [('Keyboard') or ('DigMark')], which unfortunately have a separate code array (dec)
            % Assign keyboard codes to events (countKeyboard), if the code type is 'Keyboard',
            % if not, the codes will be event names

                if exist('eventCodes','var') == 1
                    if strcmp(spikeMatevent.code{tt,1},'Keyboard') || strcmp(spikeMatevent.code{tt,1},'DigMark')
                        countKeyboard = countKeyboard + 1;

                        % Names for space and enter (instead of empty % '' events)
                        if 32 == eventCodes{jj}(countKeyboard)
                            spikeMatevent.type{tt,1} = 'space';
                        elseif 13 == eventCodes{jj}(countKeyboard)
                            spikeMatevent.type{tt,1} = 'enter';
                        else
                            if strcmp(spikeMatevent.code{tt,1},'Keyboard')
                                spikeMatevent.type{tt,1} = char(eventCodes{jj}(countKeyboard)); % Convert to ASCII
                            elseif strcmp(spikeMatevent.code{tt,1},'DigMark')
                                spikeMatevent.type{tt,1} = eventCodes{jj}(countKeyboard);
                            end

                        end

                    else
                        spikeMatevent.type{tt,1} = eventCodes{jj};
                    end
                else

                spikeMatevent.type{tt,1} = eventNames{jj};

                end

            end

            fromT = toT+1;

        end
          clearvars fromT toT tt jj lenEvent



     spikeMatevent = struct2table(spikeMatevent);
     spikeMatevent = table2struct(spikeMatevent);

     end

    % Customizing channel list
    chanNames = transpose(chanNames);
    chanLocs = struct('labels',chanNames);

    % Assembling the EEG structure
    EEG.setname = fileName(1:end-4);
    EEG.filename = '';
    EEG.filepath = '';
    EEG.subject = '';
    EEG.group = '';
    EEG.condition = '';
    EEG.session = [];
    EEG.comments = '';
    EEG.nbchan = size(chanValues,1);
    EEG.trials = 1;
    EEG.pnts = maxLength;
    EEG.srate = sRate;
    EEG.xmin = 0;
    EEG.xmax = chanxMax;
    EEG.times = chanTimes;
    EEG.data = chanValues;
    EEG.icaact = [];
    EEG.icawinv = [];
    EEG.icasphere = [];
    EEG.icaweights = [];
    EEG.icachansind = [];
    EEG.chanlocs = chanLocs;
    EEG.urchanlocs = [];
    EEG.chaninfo.plotrad = [];
    EEG.chaninfo.shrink = [];
    EEG.chaninfo.nosedir = '+X';
    EEG.chaninfo.nodatchans = [];
    EEG.chaninfo.icachansind = [];
    EEG.ref = 'common';

    if exist('spikeMatevent','var') == 1
        EEG.event = spikeMatevent;
    else
        EEG.event = [];
    end

    EEG.urevent = [];
    EEG.eventdescription = [];
    EEG.epoch = [];
    EEG.epochdescription = [];
    EEG.reject = [];
    EEG.stats = [];
    EEG.specdata = [];
    EEG.specicaact = [];
    EEG.splinefile = '';
    EEG.icasplinefile = '';
    EEG.dipfit = [];
    EEG.history = '';
    EEG.saved = '';

    % Check EEGlab version
    verEEGlab = eeg_getversion;
    if strcmp(verEEGlab,"2019.1") || strcmp(verEEGlab,"2020.0") || strcmp(verEEGlab,"2021.1") || strcmp(verEEGlab,"2021.2") || strcmp(verEEGlab,"2022.1")
        EEG.run = [];
    end

    EEG.etc.eeglabvers = verEEGlab;
    EEG.datfile = '';


    disp("File was sucessfully uploaded.");
end
