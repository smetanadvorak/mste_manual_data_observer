
raw_signals_path = 'D:\MYO\matlab\data_comparison\9021_my\07_12_2016\Finger tap\run_1';

EMG = dlmread([raw_signals_path, filesep, 'emg.txt']);
emg_time_orig = EMG(:,1);
emg_sig_orig = EMG(:,2:9);
if size(EMG,2) > 9
    eyes_emg = EMG(:,10);
end

emg_time_orig = (emg_time_orig-emg_time_orig(1))/10^3; %From us to ms
compare = [emg_time_orig(:)';(0:length(emg_time_orig)-1)*5];

[emg_time_int, emg_sig_int] = said_function(emg_time_orig, emg_sig_orig, 5);
separator_int = repmat((1:8)*256, length(emg_sig_int), 1);
separator_orig = repmat((1:8)*256, length(emg_sig_orig), 1);

figure;
subplot(4,1,1:3); 
h1 = plot(emg_time_orig, emg_sig_orig+separator_orig, '--k');  set(h1, 'color', [0.5 0.5 0.5]); hold on;
plot(emg_time_int, emg_sig_int+separator_int); title('Received and interpolated EMG (ECN)'); 

subplot(4,1,4); plot(compare(1,:)-compare(2,:)); title('Signal transmission delays');

%% Read acceleration data
ACC = dlmread([raw_signals_path, filesep, 'acceleration.txt']);
acc_time_orig = ACC(:,1);
acc_sig_orig  = ACC(:,2:4);
if size(ACC,2) > 4
    eyes_acc = ACC(:,5);
end

acc_time_orig = (acc_time_orig-acc_time_orig(1))/10^3;
[acc_time_int,acc_sig_int] = said_function(acc_time_orig,acc_sig_orig,20);

separator_int = repmat((1:3)*10, length(acc_sig_int), 1);
separator_orig = repmat((1:3)*10, length(acc_sig_orig), 1);

figure;
h2 = plot(acc_time_orig, acc_sig_orig+separator_orig); set(h2,'color',[0.5,0.5,0.5]); hold on;
plot(acc_time_int, separator_int, 'k');
h_acc = plot(acc_time_int, acc_sig_int+separator_int); 

title('Accelerometer (ECN)'); legend(h_acc(:), 'X', 'Y', 'Z');

%% Read orientation data
ORN = dlmread([raw_signals_path, filesep, 'orientation.txt']);
orn_time_orig = ORN(:,1);
orn_sig_orig  = ORN(:,2:5);
if size(ORN,2) > 5
    eyes_orn = ORN(:,6);
end

orn_time_orig = (orn_time_orig-orn_time_orig(1))/10^3;
[orn_time_int,orn_sig_int] = said_function(orn_time_orig,orn_sig_orig,20);

separator_int = repmat((1:4)*5, length(orn_sig_int), 1);
separator_orig = repmat((1:4)*5, length(orn_sig_orig), 1);

figure;
h3 = plot(orn_time_orig, orn_sig_orig+separator_orig); set(h3,'color',[0.5,0.5,0.5]); hold on;
plot(orn_time_int, separator_int,'k'); 
h_orn = plot(orn_time_int, orn_sig_int+separator_int); 

title('Orientation Quaternion (ECN)');  legend(h_orn(:), 'i', 'j', 'k','\theta');

%% Compensate gravity
addpath('quat_func');
acc_comp = zeros(size(acc_sig_int));
for i = 1:min(length(acc_sig_int), length(orn_sig_int))
   %Qrot = qGetRotQuaternion(orn_sig_int(i,4),orn_sig_int(i,1:3));
   acc_comp(i,:) = qRotatePoint(acc_sig_int(i,:)', [orn_sig_int(i,4),orn_sig_int(i,1:3)]'); 
   acc_comp(i,3) = acc_comp(i,3)-1;
end

figure;
separator_int = repmat((1:3)*10, length(acc_comp), 1);
plot(acc_time_int, separator_int, 'k'); hold on;
h_comp = plot(acc_time_int, acc_comp + separator_int); 

title('Compensated gravity (ECN)'); legend(h_comp(:), 'X', 'Y', 'Z');


%% Plot acceleration spectrum
figure;

s_acc = abs(fft(acc_comp-repmat(mean(acc_comp),length(acc_comp),1))).^2;
s_acc = s_acc(1:ceil(end/2),:);
freqs_acc = linspace(0,50/2,length(s_acc));
max_acc = max(max(s_acc));

for i = 1:3
    subplot(8,2,(i*2-1):(i*2));
    plot(freqs_acc,s_acc(:,i));
    axis([0,25,0,max_acc*1.2]);
end
 
s_emg = abs(fft(emg_sig_int-repmat(mean(emg_sig_int), length(emg_sig_int),1))).^2;
s_emg = s_emg(1:ceil(end/2),:);
freqs_emg = linspace(0,200/2,length(s_emg));
max_emg = max(max(s_emg));

for i = 1:8
    subplot(8,2,8+i); 
    plot(freqs_emg,s_emg(:,i));
    axis([0,100,0,max_emg]);
end

%% Save results
cd processed_signals
save('processed_signals','acc_sig_int','acc_time_int','emg_sig_int','emg_time_int');
cd ..




















%%
% figure;
% plot(1000./resample(smooth(diff(acc_time), 25), length(emg_time), length(acc_time))); hold all
% plot(1000./smooth(diff(emg_time), 100))
% ROT = dlmread('rotfile.txt');
% rot_time = ROT(:,1);
% rot_sig  = ROT(:,2:4);
% if size(ROT,2) > 4
%     eyes_rot = ROT(:,5);
% end
% figure(3);
% separator = repmat((1:3)*2, length(rot_sig), 1);
% plot(rot_time, rot_sig+separator); hold on;
% plot(rot_time(eyes_acc>0), eyes_rot(eyes_rot>0), '*k');


% %% EMG Timestamps
% mean(diff(emg_time));
% figure;
% hist(diff(emg_time), 200);
% 
% figure;
% subplot(311);
% plot(emg_time);
% 
% subplot(312);
% plot(smooth(diff(emg_time), 10))
% plot(smooth(diff(emg_time), 50))
% plot(smooth(diff(emg_time), 100))
% plot(smooth(diff(emg_time), 200))
% 
% subplot(313);
% %plot(1000./smooth(diff(emg_time), 10))
% plot(1000./smooth(diff(emg_time), 50)); hold all
% plot(1000./smooth(diff(emg_time), 100))
% plot(1000./smooth(diff(emg_time), 200))
% prev_ax = axis;
% axis([prev_ax(1), prev_ax(2), 100, 250])