%Meran Abdelmajeed, 1152421

%Firstly, we define the directories to be worked on using the matlab dir
%command. We have our training and testing folders for both the yes and no.

%An overall discussion about how well those methods have worked is all
%the way down, at the end of the code.

yes_train = dir('C:\Users\user\Documents\train\yes\*.wav');
yes_test = dir('C:\Users\user\Documents\test\yes\*.wav');
no_train = dir('C:\Users\user\Documents\train\no\*.wav');
no_test = dir('C:\Users\user\Documents\test\no\*.wav');

%The first method used to test if a given audio record is a yes or a no is by
%calculating the mean of the energy of the training files and comparing it
%with each audio record to be tested. 

%As a first step we loop through the training files for both the yes and no
%and we calculate the energy and add it to the previous one to calculate
%the mean and as a last step we loop through each test file and compare it
%with the previously calculated mean energy. 
data1 = [];
for i = 1:length(yes_train)
file_path = strcat(yes_train(i).folder,'\',yes_train(i).name);
[y,fs] = audioread(file_path);

energy1=sum(y.^2); 
data1 = [data1 energy1]; 
end
energy1=mean(data1); 
fprintf('The average energy of the word "yes" is: \n');
disp(energy1);

data2 = [];
for i = 1:length(no_train)
file_path = strcat(no_train(i).folder,'\',no_train(i).name);
[y,fs] = audioread(file_path);

energy2=sum(y .^2);
data2 = [data2 energy2];
end
energy2=mean(data2);
fprintf('The average energy of the word "no" is:\n');
disp(energy2);


for i = 1:length(yes_test)
file_path = strcat(yes_test(i).folder,'\',yes_test(i).name);
[y,fs] = audioread(file_path);

y_energy  = sum(y.^2);
    if(abs(y_energy-energy1) < abs(y_energy-energy2)) 
        fprintf('Voice record {yes} #%d is classified as {yes} with energy E=%d\n',i,y_energy);
    else
        fprintf('Voice record {yes} #%d is classified as {NO} with energy E=%d\n, OOOOPS!',i,y_energy);
    end
end

for i = 1:length(no_test)
file_path = strcat(no_test(i).folder,'\',no_test(i).name);
[y,fs] = audioread(file_path);

y_energy  = sum(y.^2);

    if(abs(y_energy-energy1) < abs(y_energy-energy2))
        fprintf('Voice record{No} #%d is classified as {No} with energy E=%d\n',i,y_energy);
    else
        fprintf('Voice record{No} #%d is classified as {YES} with energyE=%d\n, OOOOPS!',i,y_energy);
    end
end

%The second method used which is the ZCR short for zero-crossing rate which
%is the rate of the sign changes in a voice record. As instructed best, we
%divide the signal into 3 parts for better results.
data3 = [];
for i = 1:length(yes_train)
file_path = strcat(yes_train(i).folder,'\',yes_train(i).name);
[y,fs] = audioread(file_path);

part1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
part2 = mean(abs(diff(sign(y(floor(end/3):floor (end*2/3))))))./2;
part3 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;

yesZCR = [part1 part2 part3];

data3 = [data3 ;yesZCR];
end
yesZCR=mean(data3);
fprintf('The mean ZCR of yes is: \n');
disp(yesZCR);

data4 = [];
for i = 1:length(no_train)
file_path = strcat(no_train(i).folder,'\',no_train(i).name);
[y,fs] = audioread(file_path);

part4 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
part5 = mean(abs(diff(sign(y(floor(end/3):floor (end*2/3))))))./2;
part6 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;

noZCR = [part4 part5 part6];

data4 = [data4 ;noZCR];
end
noZCR=mean(data4);
fprintf('The mean ZCR of no is: \n');
disp(noZCR);


%Now, we compare the ZCR for each test file as we did in the first method
%by using the pdist command the compares based on the euclidean distance 
%and decide based on the results of the calculated ZCR!

for i = 1:length(yes_test)
file_path = strcat(yes_test(i).folder,'\',yes_test(i).name);
[y,fs] = audioread(file_path);
part7 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
part8 = mean(abs(diff(sign(y(floor(end/3):floor (end*2/3))))))./2;
part9 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
testZCR = [part7 part8 part9];
    
    if(pdist([testZCR;yesZCR],'euclidean') < pdist([testZCR;noZCR],'euclidean'))
        fprintf('Voice Record {yes} #%d is classified as yes \n',i);
    else
        fprintf('Voice Record {yes} #%d classified as NO, OOPS! \n',i);
    end
end

for i = 1:length(no_test)
file_path = strcat(no_test(i).folder,'\',no_test(i).name);
[y,fs] = audioread(file_path);

part10 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
part11 = mean(abs(diff(sign(y(floor(end/3):floor (end*2/3))))))./2;
part12 = mean(abs(diff(sign(y(floor(end*2/3):end)))))./2;
testZCR1 = [part10 part11 part12];
 
    if(pdist([testZCR1;yesZCR],'euclidean') < pdist([testZCR1;noZCR],'euclidean'))
        fprintf('Voice record {no} #%d is classified as YES, OOPS! \n',i);
    else
        fprintf('Voice record {no} #%d is classified as no \n',i);
    end
end
%Last but not least, it is said that frequency domain makes everything
%better since when we're dealing with voice records we're talking
%frequency, this method will use the powerful fourier transform technique.
dataf1 = [] ; 
for i = 1:length(yes_train) 
    file_path = strcat(yes_train(i).folder,'\',yes_train(i).name); %uploding path 
    [y,fs] = audioread(file_path) ; 
    f = abs(fft(y));
    index_f = 1:length(f);  
    index_f = index_f ./ length(f); 
    index_f = index_f .* fs ; 
    energy_yes = sum (f.^2) ./length(f); 
    dataf1 = [dataf1 energy_yes] ; 
end
energy_yes = mean(dataf1);
fprintf('The energy of the word "yes" = ');
disp(energy_yes); 

dataf2 = [] ; 
for i = 1:length(no_train) 
    file_path = strcat(no_train(i).folder,'\',no_train(i).name);
    [y,fs] = audioread(file_path) ; 
    
    
    f = abs(fft(y));
    index_f = 1:length(f); 
    index_f = index_f ./ length(f); 
    index_f = index_f .* fs ;
    energy_no = sum (f.^2) ./length(f); 
    dataf2 = [dataf2 energy_no] ; 
    
end
energy_no = mean(dataf2);
fprintf('The energy of the word "no" :'); 
disp(energy_no);


for i = 1:length(yes_test)
    file_path = strcat(yes_test(i).folder,'\',yes_test(i).name);
    [y fs] = audioread(file_path);
    test_energy = sum(y.^2);
 
     if (abs(test_energy-energy_yes) > abs(test_energy-energy_no))
        fprintf('Voice record {yes} #%d is  classified as NO, OOPS!\n',i);
    else
        fprintf('Voice record {yes}#%d is classified as yes \n',i);
    
     end
end

for i = 1:length(no_test)
    file_path = strcat(no_test(i).folder,'\',no_test(i).name);
    [y fs] = audioread(file_path);
    test_energy = sum(y.^2);
    
     if (abs(test_energy-energy_yes) < abs(test_energy-energy_no))
        fprintf('Voice record {no} #%d is classified as no\n',i);
    else
        fprintf('Voice record {no} #%d is classified as YES, OOPS!\n',i);
    
     end
end


%Although the frequency domain was the better strategy for this program but
%I've realized that it wasn't the case with me since I got most of them
%right when I've used the time domain!