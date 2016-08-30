% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                            Function and Outputs
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The function creates two arrays: one to measure the total number of fires
% that occur in each well (column) of the input array, and one to measure
% to the total number of simultaneous fires in each well. The program
% calculates the total synchrony of the neuronal firing, which is between 0
% and 1.
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                     List of Variables and Descriptions:
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% greatestarraysize ~ the size of the largest array, which is calculated in
% order to prevent data from getting cut off from the outputarray1, which
% filters the neuronal fires out from the rest of the data in the input. 
%
% inputwidth ~ the total number of wells in the sample collected. Used to
% create FOR loops that match the total number of given inputs
%
% outputarray ~ the first outputarray. Contains a list of times that were
% neuronal firings from each well. Used when creating an array of filtered
% out results.
%
% outputarray2 ~ lengths of each column in outputarray. This is used to
% calculate synchrony, which is the ratio of the # of simultaneous fires to
% the # of fires total that happened within a well.
%
% sync_output ~ The total number of simultaneous fires that occured in each
% well. sync_output_double is just a version that is converted to a double
% value for easier access.
%
% total_synchrony ~ the total synchrony value for each well. This is the
% end product and is what you're looking for after running the script.
%
% wellall ~ the input file. Manually add the filepath into the script in
% the subdivided area below, or load it in as variable wellall and comment
% out that section of code.
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%                                  NOTE
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% All other variables are either used temporarily for storage of
% data, or are used because functions like size() require that the output
% have two dimensions or more. variables with odd names like f, d, and z,
% have no real purpose and can be ignored.

%% Begin Code
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Reset all variables and commands
clc
clear
d=dir('*'); % <- retrieve all names: file(s) and folder(s)
     d=d(~[d.isdir]); % <- keep file name(s), only
     d={d.name}.'; % <- file name(s)
     nf=numel(d);
for i=1:nf
     disp(sprintf('working on %5d/%5d: %s',i,nf,d{i}));

    %% Load in new variables
    % You can change this if you want to - if you load wellall as a variable in
    % the same format as this, then you should not have any problems and you
    % can comment out this line of code.
    filename = d{i};    
    load(filename);
    %% Find Size of new array
    greatestarraysize = 0;
    [inputwidth,o] = size(wellall);
    for arraysizectr = 1:inputwidth
        [currentarraysize,f] = size(wellall{arraysizectr,2}); %f is a useless variable and isn't needed
        if currentarraysize > greatestarraysize 
            greatestarraysize = currentarraysize;
        end
    end
    outputarray = cell(greatestarraysize,inputwidth,1);
    %% Load data into a new array
    for rowcounter = 1:inputwidth
        [workingarraysize, z] = size(wellall{rowcounter, 2});
        for ctr = 1:workingarraysize
            outputarray{ctr,rowcounter} = wellall{rowcounter,2}{ctr,1};
        end
    end


    %% Calculate Synchrony function
    %% 
    %% Calculate total number of fires
    outputarray2 = cell(greatestarraysize,inputwidth,1);
    for wellcounter = 1:inputwidth
        [workingarraysize, z] = size(wellall{wellcounter, 2});

        for arrayrow = 1:workingarraysize
            outputarray2{arrayrow,wellcounter} = length(outputarray{arrayrow,wellcounter});
        end
    end
    lengthoutput = cell(2,inputwidth,1);
    for columncounter = 1:inputwidth
        subtotal = cellfun(@sum,outputarray2);
        total = sum(subtotal);
    end

    %% Create Synchrony Array 
    newtotal = [];
    for wellcounter = 1:inputwidth
        [workingarraysize,z] = size(wellall{wellcounter,2});

        for i = 1:workingarraysize
            for j = 1:workingarraysize
                append = outputarray{j,wellcounter};
                newtotal = [newtotal append];
            end
            newcell = outputarray{i,wellcounter};
            newtotal(strfind(newtotal,newcell):strfind(newtotal,newcell)+numel(newcell)-1)=[];
            sync_output{i,wellcounter} = ismember(newcell,newtotal);
            sync_output_doubles{i,wellcounter} = +sync_output{i,wellcounter}; 
            newtotal = [];
        end
    end
    %% Calculate Synchrony Amount
    for columncounter = 1:inputwidth
        sync_total = 0;
        [workingarraysize,z] = size(wellall{columncounter,2});
        for cellcounter = 1:workingarraysize
            sync_calc = nnz(sync_output_doubles{cellcounter,columncounter});
            sync_total = sync_total + sync_calc;
            sync_array{1,columncounter} = sync_total;
        end
    end
    %% Calculate total synchrony (Sync amount / total amt)
    total_synchrony = cell(1,inputwidth,1);
    for columncounter = 1:inputwidth
        total_synchrony{3,(columncounter+1)} = (sync_array{1,columncounter}) / (total(1,columncounter));
    end

    %% Add Labels
    for i = 1:inputwidth
        label = wellall{i,1};
        total_synchrony{1,(i+1)} = label;
    end
    for i = 1:inputwidth
        [workingarraysize,z] = size(wellall{i,2});
        total_synchrony{2,(i+1)} = workingarraysize;
    end
    total_synchrony{1,1} = 'Well ID';
    total_synchrony{2,1} = 'Number of Cells';
    total_synchrony{3,1} = 'Synchrony Level';

    filename_xls = strcat(filename,'.xlsx');
    xlswrite(filename_xls,total_synchrony);
    %% Make Graph
%{ 
    for column = 1:inputwidth
        figure();
        [workingarraysize,z] = size(wellall{column,2});
        for i = 1:workingarraysize
            input_elements = numel(outputarray{i,column});
        end
        for k=1:input_elements

            cell_elements = outputarray{k,column};

            for y=1:numel(cell_elements)
                plot(cell_elements(y),k);
                xlabel('Time fired (s)');
                ylabel('Cell Number');
                hold on;
            end    
        end
    input_elements = 0;
    end
    %}
end
    

