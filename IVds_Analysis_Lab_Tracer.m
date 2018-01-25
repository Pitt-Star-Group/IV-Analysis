%Type out file directory

Directory = 'E:\Data\Sensor\Ben C\2017-12-20 - Chip 2 10microg - Ivg-sweep gated blank DPBS';
cd(Directory);

%Fill out information below.

Material = 'Iso-sol + pyrene-COOH + H1 Antibody';
Measurement_Solvent = 'DPBS; air';
Analyte = 'H1';
Chip_ID = 'Chip 1';
Data_Points = 201;

%Include any additional experimental details.

Experiment_Details = 'DPBS blank measurement';

%List out the treatment order separated by comma.

Treatment_Order = {
    '1 Day 1 Blank DPBS 1',
    '2 Day 2 1E-6 mg/mL HA1 in DPBS 1',
    '3 Day 2 Blank DPBS 1',
%    '4 Day 2 Blank water 1',
%    '5 Day 2 Blank water 2'
%    '6 Day 2 Blank water 3'
%    '7 Blank water 2',
%    '8 Blank water 3',
%    '9 Blank water 4',
%    '10 Blank water 5',
%    '11 1 microg per mL EtOH in H2O',
%    '12 Blank water 6',
%    '13 1 microg per mL EtOH in H2O',
%    '14 Blank water 7',
%    '15 1 microg per mL EtOH in H2O',
%    '16 Blank water 8',
%    '17 Blank water 1',
%    '18 1 ppmv Acetone in H2O',
%    '19 Blank water 2',
%    '20 1 ppmv Acetone in H2O',
%    '21 Blank water 3',
%    '22 1 ppmv Acetone in H2O',
%    '23 Blank water 4',
%    '24 Blank water 1',
%    '25 280 pg/mL',
%    '26 Blank water 2',
%    '27 2.8 ng/mL',
%    '28 Blank water 3',
%    '29 28 ng/mL',
%    '30 Blank water 4',
%    '31 280 ng/mL',
%    '32 Blank water 5'
%    '33 2.8 microg/mL',
%    '34 Blank water 6'
    };

%Input measurement count.

Measurement_Count = 10;

%Input functioning devices to analyze.

Working_Devices = ['B','D'];
Working_Devices_Count = length(Working_Devices);

%Set your file name prefixes separated by devices.

Device_A_File_Names = dir([Chip_ID, ' - Dev A - IVds*']);
Device_B_File_Names = dir([Chip_ID, ' - Dev B - IVds*']);
Device_C_File_Names = dir([Chip_ID, ' - Dev C - IVds*']);
Device_D_File_Names = dir([Chip_ID, ' - Dev D - IVds*']);

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

Output_File_Name = 'Analysis IVds';

%Inputs all the raw data from working devices into a structure matrix,
%where the rows indicate the experiment order and columns are working devices.
%The start and end rows indicate the range of rows that correspond to 1 IVg
%plot measurement.

startRow = 4;
endRow = Data_Points + startRow - 1;
formatSpec = '%f%f%f%[^\n\r]';
delimiter = '\t';

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
            Device.data = [dataArray{:,1}, dataArray{:,2}];
            
            Experimental_Data{count3,count2} = Device;
            
            startRow = endRow + 3;
            endRow = Data_Points + startRow - 1;
        
        end
    end    
end

%The code for the analysis.
%Change the index values to select current at the desired Vsd

Current_At_Vds_1 = zeros(Measurement_Count, Working_Devices_Count+1);

Current_At_Vds_2 = zeros(Measurement_Count, Working_Devices_Count+1);

%Organizes multiple files into a single file per device.

for count1 = 1:Working_Devices_Count
    
    fileID1 = fopen([Output_File_Name, ' ', Chip_ID, ' Device ', Working_Devices(count1), '.txt'], 'w');
    
    fprintf(fileID1, '%s\t', 'Material:', Material, 'Analyte:', Analyte, 'Solvent:', Measurement_Solvent, 'Chip_ID:', Chip_ID, 'Device ID:', Working_Devices(count1), 'Experimental Details:', Experiment_Details);
    fprintf(fileID1, '%s\n', '');
    
    for count2 = 1:Combined_File_Names_Count
        
        for count3 = 1:Measurement_Count
        
            fprintf(fileID1, '%s\t', Combined_File_Names(count2, count1).name);
            fprintf(fileID1, '%s\t', Treatment_Order{count2});
                    
        end
                    
    end
    
    fprintf(fileID1, '%s\n', '');
    
    Combined_Data = [];
    
    for count3 = 1:Measurement_Count * Combined_File_Names_Count
        
        Combined_Data = [Combined_Data, Experimental_Data{count3, count1}.data(:,:)];
        
    end
    
    for count4 = 1:length(Combined_Data)
        
        fprintf(fileID1, '%e\t', Combined_Data(count4, :));
        fprintf(fileID1, '%s\n', '');
        
    end
end

%End of code block for organizing device data.

fclose('all');