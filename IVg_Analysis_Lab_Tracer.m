%Type out file directory

Directory = 'C:\Users\seani\Box Sync\Graduate School\Research\Data\Sensor\Source Meter\Au Clusters\2018-06-13 - Au Clusters Nanopure FET';
cd(Directory);

%Fill out information below.

Material = '171(-1)-H';
Gating_Solvent = 'nanopure water';
Analyte = 'none';
Chip_ID = 'Au Clusters 171-(-1)-H';
Data_Points = 201;

%Include any additional experimental details.

Experiment_Details = 'Liquid gating measurements in water, 3x measurements';

%List out the treatment order separated by comma.

Treatment_Order = {
    '1 nanopure',
%    '2 nanopure',
%    '3 nanopure'
%    '4 50 + 3x5 nanopure',
%    '5 50 + 3x5 nanopure + 1x5 2.8 mig/mL THC',
%    '6 50 + 3x5 nanopure + 2x5 2.8 mig/mL THC',
%    '7 50 + 3x5 nanopure + 3x5 2.8 mig/mL THC',
%    '8 50 nanopure'
%    '6 Day 2 Blank water 3'
%    '7 Day 3 280 pg/mL',
%    '8 Day 4 Blank water 1',
%    '9 Day 4 Blank water 2',
%    '10 Day 4 Blank water 3',
%    '11 Day 4 Blank water 4',
%    '12 Day 4 280 pg/mL',
%    '13 Day 4 Blank water 6',
%    '14 Day 4 Blank water 7',
%    '15 Day 4 2.8 ng/mL',
%    '16 Day 4 Blank water 8',
%    '17 Day 5 Blank water 1',
%    '18 Day 5 28 ng/mL',
%    '19 Day 5 Blank water 2',
%    '20 Day 5 280 ng/mL',
%    '21 Day 5 Blank water 3',
%    '22 Day 5 2.8 microg/mL',
%    '23 Day 5 Blank water 4',
    };

%Input measurement count.

Measurement_Count = 3;

%Input functioning devices to analyze.

Working_Devices = ['ABCD'];
Working_Devices_Count = length(Working_Devices);

%Set your file name prefixes separated by devices.

Device_A_File_Names = dir([Chip_ID, ' - Dev A - LG IVg*']);
Device_B_File_Names = dir([Chip_ID, ' - Dev B - LG IVg*']);
Device_C_File_Names = dir([Chip_ID, ' - Dev C - LG IVg*']);
Device_D_File_Names = dir([Chip_ID, ' - Dev D - LG IVg*']);

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
        
        startRow = 3;
        endRow = Data_Points + startRow - 1;
        formatSpec = '%f%f%f%[^\n\r]';
        delimiter = '\t';
        
        for count3 = (count1 - 1) * Measurement_Count + 1:Measurement_Count * count1
            
            fileID = fopen(Combined_File_Names(count1,count2).name, 'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
            fclose(fileID);
            Device.data = [dataArray{:,1}, dataArray{:,2}, dataArray{:,3}];
            
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
            
            Measurement_Write = compose([Treatment_Order{count3}, ' %d'], count2);
            
            fprintf(fileID, '%s\t', Measurement_Write{1});
            fprintf(fileID, '%e\t', count2);
        
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