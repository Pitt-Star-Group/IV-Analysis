%Type out file directory

Directory = 'C:\Users\seani\Box Sync\Graduate School\Research\Data\Sensor\Source Meter\THC Sensor\2018-05-04 - Purus Nano and Iso-sol THC Sensing in BMP-FMSI';
cd(Directory);

%Fill out information below.

Material = 'Iso-sol';
Gating_Solvent = 'BMP-FMSI';
Analyte = 'THC';
Chip_ID = 'Purus Nano BMP-FMSI 1';
Data_Points = 201;

%Include any additional experimental details.

Experiment_Details = '100x dilution of THC into BMP-FMSI';

%List out the treatment order separated by comma.

Treatment_Order = {
    '1 Blank BMP-FMSI',
    '2 Blank BMP-FMSI',
    '3 Blank 3 Day Incubation',
    '4 Blank Addition #1',
    '5 Blank Addition #2',
    '6 Blank Addition #3',
    '7 1pg/mL THC',
    '8 10pg/mL THC',
    '9 100pg/mL THC',
    '10 1ng/mL THC',
    '11 10ng/mL THC',
    '12 100ng/mL THC',
    '13 10ug/mL THC',
    '14 10ug/mL THC 15 hr incubation',
    '15 2-wire',
    '16 4-wire'
%    '17 100uL+3x1 uL H2O + 1uL 0.1% THC',
%    '18 100uL+3x1 uL H2O + 1uL 0.1% + 1uL 1% THC',
%    '19 100uL+3x1 uL H2O + 1uL 0.1% + 1uL 1% + 1uL 10% THC',
%    '20 100uL+3x1 uL H2O + 1uL 0.1% + 1uL 1% + 1uL 10% + 1uL 100% THC'
%    '21 min',
%    '22 min',
%    '23 min',
%    '24 min',
%    '25 min',
%    '26 min',
%    '27 min',
%    '28 min',
%    '29 min',
%    '30 min'    
    };

%Input measurement count.

Measurement_Count = 3;

%Input functioning devices to analyze.

Working_Devices = ['A'];
Working_Devices_Count = length(Working_Devices);

%Set your file name prefixes separated by devices.

Device_A_File_Names = dir([Chip_ID, ' - IVg - Dev A - *']);
Device_B_File_Names = dir([Chip_ID, ' - IVg - Dev B - *']);
Device_C_File_Names = dir([Chip_ID, ' - IVg - Dev C - *']);
Device_D_File_Names = dir([Chip_ID, ' - IVg - Dev D - *']);

Combined_File_Names = struct([]);

if contains(Working_Devices, 'A')
    Combined_File_Names = [Combined_File_Names, Device_A_File_Names];
end

if contains(Working_Devices, 'B')
    Combined_File_Names = [Combined_File_Names, Device_B_File_Names];
end

if contains(Working_Devices, 'C')
    Combined_File_Names = [Combined_File_Names, Device_C_File_Names];
end

if contains(Working_Devices, 'D')
    Combined_File_Names = [Combined_File_Names, Device_D_File_Names];
end

Combined_File_Names_Count = size(Combined_File_Names, 1);

Experimental_Data = cell(Measurement_Count * Combined_File_Names_Count, Working_Devices_Count);

%Set the desired output file root name.

Output_File_Name = 'Analysis IVg';

%Inputs all the raw data from working devices into a structure matrix,
%where the rows indicate the experiment order and columns are functioning
%devices. The start and end rows indicate the range of rows that correspond 
%to 1 IVg plot measurement.

for count1 = 1:Combined_File_Names_Count
        
    for count2 = 1:Working_Devices_Count
        
        startRow = 4;
        endRow = Data_Points + startRow - 1;
        formatSpec = '%f %f %f %f %f %f %[^\r\n]';
        delimiter = '\t';
        
        for count3 = (count1 - 1) * Measurement_Count + 1:Measurement_Count * count1
            
            fileID = fopen(Combined_File_Names(count1,count2).name, 'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', true, 'EndOfLine', '\r\n');
            fclose(fileID);
            Device.data = [dataArray{:,1}, dataArray{:,5}, dataArray{:,6}, dataArray{:,3}];
            
            Experimental_Data{count3,count2} = Device;
            
            startRow = endRow + 3;
            endRow = Data_Points + startRow - 1;
        
        end
    end    
end

%Establishes the required variables for the IVg analysis.

Current_At_Vg_1 = zeros(Measurement_Count, Working_Devices_Count+1);

Current_At_Vg_2 = zeros(Measurement_Count, Working_Devices_Count+1);

%Organizes multiple FET files into a single file for every functioning device.

for count1 = 1:Working_Devices_Count
    
    fileID = fopen([Output_File_Name, ' ', Chip_ID, ' Device ', Working_Devices(count1), '.txt'], 'w');
    
    fprintf(fileID, '%s\t', 'Material:', Material, 'Analyte:', Analyte, 'Solvent:', Gating_Solvent, 'Chip_ID:', Chip_ID, 'Device ID:', Working_Devices(count1), 'Experimental Details:', Experiment_Details);
    fprintf(fileID, '%s\n', '');
    
    for count3 = 1:Combined_File_Names_Count
            
        for count2 = 1:Measurement_Count
            
            fprintf(fileID, '%s\t', Combined_File_Names(count3, count1).name);
            fprintf(fileID, '%d\t', count2);
            fprintf(fileID, '%s', Treatment_Order{count3});
            fprintf(fileID, '% d\t', count2);
            fprintf(fileID, '%s\t', '');
        
        end
        
    end
    
    fprintf(fileID, '%s\n', '');
    
    for count3 = 1:Combined_File_Names_Count
        
        for count2 = 1:Measurement_Count
            
            fprintf(fileID, '%s\t', 'Time (s)');
            fprintf(fileID, '%s\t', 'Vg');
            fprintf(fileID, '%s\t', 'Ig');
            fprintf(fileID, '%s\t', 'Id');
            
        end
        
    end
    
    fprintf(fileID, '%s\n', '');
    
    Combined_Data = [];
    
    for count3 = 1:Measurement_Count * Combined_File_Names_Count
        
        Combined_Data = [Combined_Data, Experimental_Data{count3, count1}.data(:,:)];
       
    end
    
    for count4 = 1:size(Combined_Data, 1)
        
        fprintf(fileID, '%e\t', Combined_Data(count4, :));
        fprintf(fileID, '%s\n', '');
        
    end
end

%Organizes single FET file with multiple measurements into a single file per device.

fclose('all');