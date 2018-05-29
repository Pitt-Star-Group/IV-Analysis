%Type out file directory

Directory = 'C:\Users\Sean\Box Sync\Graduate School\Research\Data\Sensor\Heterodyne\BTEX Sensor\2018-05-25 - Purus Nano Iso-sol Pd Pt Benzene and Toluene Sensing';
cd(Directory);

%Fill out information below.

Material = 'Purus Nano + Pd';
Gating_Solvent = 'air';
Analyte = 'benzene, toluene';
Chip_ID = 'Purus Nano-Pd-1';
Data_Points = 601;

%Include any additional experimental details.

Experiment_Details = 'Blank air, 99.9 ppm toluene balanced in air, 102 ppm benzene balanced in air';

%List out the treatment order separated by comma.

Treatment_Order = {
%    '0 Blank air',
    '1 Blank air #1',
    '2 99.9 ppm Toluene',
    '3 Blank air no ground',
    '4 Blank air #2',
    '5 Blank air #3',
    '6 102 ppm Benzene',
    '7 Blank air #4'
%    '7 100+6x1uL H2O',
%    '8 100+3x1uL H2O + 2x1uL 1000 ppmv Ac',
%    '9 100+3x1uL H2O + 3x1uL 1000 ppmv Ac',
%    '10 100+3x1uL H2O + 3x1uL 1000 ppm Ac + 1x1uL 1000 ppmv EtOH',
%    '11 100+3x1uL H2O + 3x1uL 1000 ppm Ac + 2x1uL 1000 ppmv EtOH',
%    '12 100+3x1uL H2O + 3x1uL 1000 ppm Ac + 3x1uL 1000 ppmv EtOH',
%    '13 100uL H2O',
%    '14 100uL+1x1 uL H2O',
%    '15 100uL+2x1 uL H2O',
%    '16 100uL+3x1 uL H2O',
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

Working_Devices = ['A','B','C','D'];
Working_Devices_Count = length(Working_Devices);

%Set your file name prefixes separated by devices.

Device_A_File_Names = dir([Chip_ID, ' - Dev A - Back Gate Heterodyne Sweep*.tdms']);
Device_B_File_Names = dir([Chip_ID, ' - Dev B - Back Gate Heterodyne Sweep*.tdms']);
Device_C_File_Names = dir([Chip_ID, ' - Dev C - Back Gate Heterodyne Sweep*.tdms']);
Device_D_File_Names = dir([Chip_ID, ' - Dev D - Back Gate Heterodyne Sweep*.tdms']);

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

Combined_File_Names_Count = length(Combined_File_Names);

Experimental_Data = cell(Measurement_Count * Combined_File_Names_Count, Working_Devices_Count);

%Inputs all the raw data from working devices into a structure matrix,
%where the rows indicate the experiment order and columns are functioning
%devices. The start and end rows indicate the range of rows that correspond 
%to 1 IVg plot measurement.

for count1 = 1:Combined_File_Names_Count

    for count2 = 1:Working_Devices_Count
        
        for count3 = (count1 - 1) * Measurement_Count + 1:Measurement_Count * count1
            
            for count4 = 1:Measurement_Count
            
                FileTDMS = convertTDMS(false, Combined_File_Names(count1,count2).name);
            
                Device.data = [FileTDMS.Data.MeasuredData(5*count4-2).Data, FileTDMS.Data.MeasuredData(5*count4-1).Data, FileTDMS.Data.MeasuredData(5*count4).Data, FileTDMS.Data.MeasuredData(5*count4+1).Data];

                Experimental_Data{count3,count2} = Device;
                
            end            
        end
    end    
end

%Set the desired output file root name.

Output_File_Name = 'Analysis Heterodyne';

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
            fprintf(fileID, '%s\t', 'Imix');
            
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