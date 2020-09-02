%% Things you need to imput/change.

filename = 'C:\Xcalibur\data\Owlstone\6th\ML2\AJC_ML_2.imzML'; % Location of the imzml file

imzMLConverterLocation = 'C:\Users\creeseay\Documents\MATLAB\imzMLConverter\imzMLConverter.jar'; % Location of the imzmlConverter software.

CFs=-1; %Starting CF
CFe=4; % Ending CF
ScanT=180; % Scan time in seconds
DFs=130:20:270; % DF steps used in experiment e.g from 130 to 270 in 20Td steps

Firsts=[90 200 310 420 529 639 748 858]; %first scan in each sweep
Scans=[110 110 110 109 110 109 110 108]; % number of scans per sweep


ionsToGenerate = [1042.08]; % The ions for which a single ion map will be generated
massWindow = [1]; % The m/z width used to created the extracted data for each ion (the width extracted is X+/- masswindow)

% Determine the minimum start scan and remove all others
sX = Firsts - min(Firsts) + 1; % removes scans which are not in the sweeps
%% Parse data and extract chromatogram

% Add imzMLConverter to the path so we can use its functionality
javaaddpath(imzMLConverterLocation);

% Parse the imzML file
imzML = imzMLConverter.ImzMLHandler.parseimzML(filename);

% Generate the chromatogram
spectrumList = imzML.getRun().getSpectrumList();
ChroTime = zeros(spectrumList.size(), 1);

%updated code to account for different vocabulary for differnt imzML
%converter versions
 if isempty(spectrumList.getSpectrum(0).getScanList().getScan(0).getCVParam('MS:1000016')); 
     for i = 0:spectrumList.size()-1
     ChroTime(i+1) = (spectrumList.getSpectrum(i).getScanList().getScan(0).getDoubleCVParam('MS:1000016').getValue());
     end
 else
    for i = 0:spectrumList.size()-1
        ChroTime(i+1) = str2num(spectrumList.getSpectrum(i).getScanList().getScan(0).getCVParam('MS:1000016').getValue());
    end
end

%%

% Round chromatogram to 2 decimal places
%ChroTime=round(ChroTime*100)/100;

From=Firsts(1);
To=Firsts(end)+Scans(end);
Sweep=ChroTime(From:To);
Sweep=Sweep*60;
SweepStart=Sweep(1);
SweepRel=Sweep-SweepStart;

for x=1:length(Sweep)
    Y=((CFe-CFs)/ScanT)*SweepRel(x,1)+CFs;
    if Y>CFe
        while Y>CFe
            Y=Y-(CFe-CFs);
        end
    end
    SweepRel(x,2)=Y;
end

%%
ImageCF=zeros(length(Firsts),(max(Scans)+1));
for j=1:length(sX)
    for i=1:(Scans(j)-1)
        ImageCF(j,i)=SweepRel((sX(j)+(i-1)),2);
    end
end
figure
subplot(2,1,1)
imagesc(ImageCF);  axis off;


xlabel('scan from start of sweep')
ylabel('DF sweep')
title('Heat map of CF for each DF sweep','fontsize',20)

bottom=ceil(max(ImageCF(:,1))*100)/100;
top=floor(min(max(ImageCF,[],2))*100)/100;
xqAll=bottom:0.01:top;
[vqmodel]=multiInterpol(ImageCF,ImageCF,xqAll);
subplot(2,1,2)
imagesc((bottom:0.01:top),DFs,vqmodel)
colormap jet
title('correction','fontsize',20);
xlabel('CF')
ylabel('DF sweep')

%%
ImageDF=zeros(length(Firsts),(max(Scans)+1));
figure
p=1;
for n=1:length(ionsToGenerate) %
    
    Name = [num2str(ionsToGenerate(n)) ' +/- ' num2str(massWindow(n))];
    Image = imzML.generatemzImage(ionsToGenerate(n), massWindow(n));
    
    for m=1:length(Firsts)
        
        %m/z data
        for i=1:(Scans(j)-1)
            ImageDF(m,i)=Image(Firsts(m)+(i-1));
        end
        % xtracted data
        %          for i=1:(Scans(j)-1)
        %             ImageDF(m,i)=Image((Firsts(m)+(i-1)),2);
        %          end
    end
    
    [vqdata]=multiInterpol(ImageDF,ImageCF,xqAll);
    
    figure
    
    imagesc((bottom:0.02:top),DFs,vqdata)
    xlabel('CF')
    ylabel('DF')
    xticklabels = -1:5;
    colormap pink
    title(Name,'fontsize',20);
    
end