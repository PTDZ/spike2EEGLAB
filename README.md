<div id="top"></div>

# spike2EEGLAB

spike2EEGGLAB(): load CED Spike format dataset (.mat) and return EEGLAB EEG structure

## Usage
```sh
[EEG] = spike2EEGLAB(fileName)
```

### Inputs:
fileName - path to the file (e.g. 'sample_data.mat')

### Outputs
EEG - EEGLAB EEG structure

Note: Import is possible via .mat files that can be saved in CED Spike software.

### Example Usage

You can download sample file from /sample-data directory:
* sample_data.mat (with Keyboard/DigMark channels)

```sh
[EEG] = spike2EEGLAB('sample_data.mat')
EEGLAB redraw
```

You can also copy spike2EEGLAB directory to your EEGLAB's 'plugins' subdirectory (e.g. eeglab_current\eeglab2021.1\plugins).

Then you can simply use the plugin from EEGLAB GUI:
```sh
File > Import data > Using EEGLAB functions and plugins > From CED Spike Matlab file (.mat)
```
![EEGLAB GUI screenshot][EEGLAB-screenshot]
### How to sucessfully export files in CED Spike
1. File > Export as...
2. Choose MATLAB data *.mat and file name.
3. Choose channels or 'All channels'.
4. Choose time range: 0 to MaxTime().
5. Click 'Add', then click 'Export'.
6. Choose layout options as 'Waveform and times' then click 'OK'.

<p align="right">(<a href="#top">back to top</a>)</p>

## Built with
* MATLAB
* EEGLAB

<p align="right">(<a href="#top">back to top</a>)</p>

## License
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
[EEGLAB-screenshot]: images/EEGLABscreen.png

## Contact

Patrycja | mail[at]ptdz.pl

Project link: https://github.com/PTDZ/spike2EEGLAB
