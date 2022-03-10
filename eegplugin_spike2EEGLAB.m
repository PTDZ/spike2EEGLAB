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


function eegplugin_spike2EEGLAB(fig,trystrs, catchstrs)

% create menu
menuSelection = findobj(fig, 'tag', 'import data');
comcnt1 = [ trystrs.no_check '[EEG] = spike2EEGLAB();'  catchstrs.new_non_empty ];
uimenu( menuSelection, 'label', 'From CED Spike Matlab file (.mat)',  'callback', comcnt1, 'separator', 'on' );
