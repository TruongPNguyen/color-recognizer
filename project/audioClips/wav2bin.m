clear all; close all;

%read file IN NATIVE FORMAT
[wavData, Fs] = audioread("green.wav", 'native'); 

%convert to binary

soundbitsbinary = dec2bin(typecast((wavData(:)), 'uint16'), 16 ) - '0';

%extend to 24 bit
A = repmat(soundbitsbinary(:, 1), 1, 8); 
soundbit24 = [A, soundbitsbinary(:, :)];


%print to file
fid = fopen('green.txt', 'w'); 
for i = 1:6130
    fprintf(fid, '%d', soundbit24(i, 1:23));
    fprintf(fid, '%d\n', soundbit24(i, 24)); 
end 
fclose(fid); 
