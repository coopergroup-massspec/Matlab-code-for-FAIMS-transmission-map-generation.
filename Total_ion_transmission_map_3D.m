%% Things you need to imput/change.

filename = 'C:\Xcalibur\data\Owlstone\6th\ML2\AJC_ML_2.imzML'; % Location of the imzml file

imzMLConverterLocation = 'C:\Users\creeseay\Documents\MATLAB\imzMLConverter\imzMLConverter.jar'; % Location of the imzmlConverter software.

CFs=-1; %Starting CF
CFe=4; % Ending CF
ScanT=180; % Scan time in seconds
DFs=130:20:270; % DF steps used in experiment
binSize = 0.1; % adjust to change the m/z width of the bins.
minmz = 500; % min m/z from mass spectrum
maxmz = 2000; % max m/z from mass spectrum

Firsts=[90 200 310 420 529 639 748 858]; %first scan in each sweep
Scans=[110 110 110 109 110 109 110 108]; % number of scans per sweep

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
ChroTime=round(ChroTime*100)/100;

From = Firsts(1);
To = Firsts(end)+Scans(end);

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


%% Generate datacube

% Generate datacube by rebinning at the bin size specified
fullData = squeeze(imzML.generateDatacube(minmz, maxmz, binSize));
spectralChannels = imzML.getBinnedmzList(minmz, maxmz, binSize);

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
imagesc((bottom:0.2:top),DFs,vqmodel)
colormap jet
title('correction','fontsize',20);
xlabel('CF')
ylabel('DF sweep')


%%
datalength=length(fullData);

for k=1:length(Scans)
    DF = zeros(Scans(k), size(fullData, 2));
    
    for s=1:Scans(k)
        DF(s,:)=fullData(Firsts(k)+(s-1),:);
    end
    
    DF=DF';
    
    [R,C]=size(DF);
    unadj=zeros([R,Scans(k)]);
    
    for r=1:R
        for s=1:(Scans (k))
            unadj(r,s)=ImageCF(k,s);
        end
    end
    
    [adjusted]=multiInterpol(DF,unadj,xqAll);
    
    figure
    % subplot(8,1,k),
    
    imagesc((bottom:0.01:top),spectralChannels,adjusted)
    set(gca,'YDir','normal');
    colormap 'hot';
    xlabel('CF (Td)', 'fontsize',14)
    ylabel('m/z','fontsize',14)
    
    clearvars DF
    
    % %     nomalisation
    %              for a=1:R
    %                  minrow=min(adjusted(a,:));
    %                  adjusted(a,:)=(adjusted(a,:))-minrow;
    %                  maxrow=max(adjusted(a,:));
    %                  scalar=255/maxrow;
    %                  adjusted(a,:)=(adjusted(a,:))*scalar;
    %              end
    %
    %         figure
    % %       subplot(8,1,k),
    %         imagesc((bottom:0.01:top),spectralChannels,adjusted)
    %         set(gca,'YDir','normal');
    %         colormap hot
    %         xlabel('CF (Td)', 'fontsize',14)
    %         ylabel('m/z','fontsize',14)
    %         clearvars DF
end
%% 3D total ion transmission map
datalength=length(fullData);

for k=1:length(Scans)
    DF = zeros(Scans(k), size(fullData, 2));
    
    for s=1:Scans(k)
        DF(s,:)=fullData(Firsts(k)+(s-1),:);
    end
    
    DF=DF';
    
    [R,C]=size(DF);
    unadj=zeros([R,Scans(k)]);
    
    for r=1:R
        for s=1:(Scans (k))
            unadj(r,s)=ImageCF(k,s);
        end
    end
    
    [adjusted]=multiInterpol(DF,unadj,xqAll);

figure, hold all
% subplot(8,1,k), 
h=surf(spectralChannels,(bottom:0.01:top),adjusted')
shading interp
        set(h,'edgecolor','none')
        set(gca,'YDir','normal');       
        myColorMap = jet; % Make a copy of jet.
        myColorMap(end, :) = [0.94 0.94 0.94];
        colormap(myColorMap); % Apply the colormap
        colormap(flipud(colormap)); % inverts the colour map
        ylabel('CF (Td)', 'fontsize',14);
        xlabel('m/z','fontsize',14);
        xlim([min(spectralChannels),max(spectralChannels)]);
        ylim([min(xqAll),max(xqAll)]);
        view([45 30]);
clearvars DF

meanspectra=mean(adjusted,2);
normmeanspectra=(meanspectra./(max(meanspectra))).*max(max(adjusted));
chromatogram=mean(adjusted,1);
normchrom=(chromatogram./(max(chromatogram))).*max(max(adjusted));
plot3(spectralChannels,repmat(top,1,length(spectralChannels)),normmeanspectra,'r');
plot3(repmat(spectralChannels(1),1,size(adjusted,2)),(bottom:0.01:top),normchrom,'b')
            
end        
