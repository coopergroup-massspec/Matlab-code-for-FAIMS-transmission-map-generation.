# Matlab-code-for-FAIMS-transmission-map-generation.

# Instructions for generating single ion transmission maps and total ion transmission maps

Version 1.2 29-09-2015

1.  Make sure the following programs and folders are installed:

- MSConvert [http://proteowizard.sourceforge.net/downloads.shtml](http://proteowizard.sourceforge.net/downloads.shtml)
- imzmlconverter [www.imzMLConverter.co.uk](http://www.imzMLConverter.co.uk)
- The “Transmission maps” folder

2.  Convert .raw data to .mzml using MSConvert. Load the file and hit start.

- Convert .mzml to .imzml using the imzmlconverter. Load the file, in the Row organisation dropdown menu select “rows per file”. Hit convert.

## For single ion transmission maps:

4\. Open the “Single\_ion\_transmission_maps” code in the editor Enter the following parameters:

```MATLAB
filename = 'C:\Xcalibur\data\Owlstone\6th\ML2\AJC_ML_2.imzML'; % Path and name of the imzml file
imzMLConverterLocation = 'C:\Users\creeseay\Documents\MATLAB\imzMLConverter\imzMLConverter.jar'; % Path of the imzmlConverter software.
CFs=-1; %Starting CF
CFe=4; % Ending CF
ScanT=180; % Scan time in seconds
DFs=130:20:270; % DF steps used in experiment e.g from 130 to 270 in 20Td steps
Firsts=[90 200 310 420 529 639 748 858]; % First scan in each sweep
Scans=[110 110 110 109 110 109 110 108]; % Number of scans per sweep
ionsToGenerate = [616, 1058, 1081]; % The ions for which a single ion maps will be generate
massWindow = [1, 2, 2]; % The m/z width for each ion (the width extracted is X +/- 0.5 x masswindow)
```

5. Run the script

## Notes:
If you are using Xtracted protein data “comment out” rows 97-99 and remove the “comments” for lines 101-103. 

## For total ion transmission maps:

4. Open the “Total_ion_transmission_maps” code in the editor

```MATLAB
filename = 'C:\Xcalibur\data\Owlstone\6th\ML2\AJC_ML_2.imzML'; % Path and name of the imzml file
imzMLConverterLocation = 'C:\Users\creeseay\Documents\MATLAB\imzMLConverter\imzMLConverter.jar'; % Path of the imzmlConverter software
CFs=-1; %Starting CF
CFe=4; % Ending CF
ScanT=180; % Scan time in seconds
DFs=130:20:270; % DF steps used in experiment
binSize = 0.1; % Adjust to change the m/z width of the bins
minmz = 500; % Min m/z from mass spectrum
maxmz = 2000; % Max m/z from mass spectrum
Firsts=[90 200 310 420 529 639 748 858]; %first scan in each sweep
Scans=[110 110 110 109 110 109 110 108]; % number of scans per swee

```

5. Run the script

## For 3D total ion transmission 

The code is a modified version of the 2D total ion transmission map 

4. Open the “Total_ion_transmission_maps_3D” code in the edito


```MATLAB

filename = 'C:\Xcalibur\data\Owlstone\6th\ML2\AJC_ML_2.imzML'; % Path and name of the imzml file
imzMLConverterLocation = 'C:\Users\creeseay\Documents\MATLAB\imzMLConverter\imzMLConverter.jar'; % Path of the imzmlConverter software.
CFs=-1; %Starting CF
CFe=4; % Ending CF
ScanT=180; % Scan time in seconds
DFs=130:20:270; % DF steps used in experiment
binSize = 0.1; % Adjust to change the m/z width of the bins.
minmz = 500; % Min m/z from mass spectrum
maxmz = 2000; % Max m/z from mass spectrum
Firsts=[90 200 310 420 529 639 748 858]; %first scan in each sweep
Scans=[110 110 110 109 110 109 110 108]; % number of scans per sweep

```
Running the code will produce both 2D and 3D maps. The default settings produce a 3D map using an inverse jet colour scheme. 


## Notes
To produce maps which are have intensity normalised per m/z channel  “comment out” lines 117-126 and remove the “comment” for lines 129-144.  To plot all DF steps in the same figure “comment out” either line 117 or 137 as appropriate and remove the “comment” at either line 118 or 128 as appropriate.

# Troubleshooting
If the alignment heatmap figure only produces one heatmap with either red pixels at the left edge or dark blue pixels at the right side of the red edge then the start (or end) of the sweep has been incorrectly entered. To correct this adjust the start scans and the number of scans accordingly, increasing the start scan will remove the pixels on the left hand side and vice versa.




