tic
clear all; close all; clc
% selecting the .rec file first 
[file,path]=uigetfile('*.rec','Select the .rec file to be analyzed');
FileName = file(1:end-4);
LFPFolder = [FileName,'.LFP'];
%% extract the analogue channels 
disp('Starting to read the analoge files')
AnalogChannels = readTrodesFileAnalogChannels(file,{'AccelX','AccelY','AccelZ'});
disp('Finished reading the analoge channels')
%% make a matric of the accelerometer data 
disp('Downsampling and concatenating movement channels')
OriginalFs = AnalogChannels.channelData.samplingRate;
TargetFs = 1500;
NdownSamp = OriginalFs / TargetFs;
g_x = decimate(double(AnalogChannels.channelData(1).data),NdownSamp,'FIR');
g_y = decimate(double(AnalogChannels.channelData(2).data),NdownSamp,'FIR');
g_z = decimate(double(AnalogChannels.channelData(3).data),NdownSamp,'FIR');
movement_data   = [g_x'; g_y'; g_z'];
% clear AnalogChannels
disp('movement_data matrix is ready')
%%
disp('checking if LFP files are exracted') 
cd(path)
if exist(LFPFolder,'dir')
    disp('LFP channels are extracted, proceeding with next step')
    cd(LFPFolder)
else
    disp('LFP files are not extracted, they will be extracted now...')
    extractLFPBinaryFiles(FileName)
    cd(LFPFolder)
end
%% choose the lfp channel to analyze 
% channelsToAnalyze = [17 1;9 1]; % please put the tetrode number first then electrode/channel number
prompt = {'Enter tetrode number:','Enter channel number:'};
dlgtitle = 'Channels to analyze';
dims = [1 35];
channelsToAnalyze = inputdlg(prompt,dlgtitle,dims);
tetrodeNum = str2num(channelsToAnalyze{1});
channelNum = str2num(channelsToAnalyze{2});
%%

for i = 1:numel(tetrodeNum)
    lfpToExtract = [LFPFolder,'_','nt',num2str(tetrodeNum(i)),'ch',num2str(channelNum(i)),'.dat'];
    dataTrodes = readTrodesExtractedDataFile(lfpToExtract);
    eeg_data{i} = double(dataTrodes.fields.data);
end


%% pack input in inputData structure
inputData.rawEeg = eeg_data;
inputData.Chs = tetrodeNum;
inputData.eegFS = TargetFs; 
inputData.MotionType = 'Channels (accelerometer)';
inputData.motionSignal = movement_data;
inputData.mChs = [1 2 3];
toc
%%
basename = path;
TheStateEditor(basename, inputData);
