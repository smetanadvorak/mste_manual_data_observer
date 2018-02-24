function [acc_sig_int, acc_time_int, eyes, missed_samples_ratio, acc_time_orig, acc_sig_orig] = myo_acc_reader( filename, interpolation )

ACC = dlmread(filename);
acc_time_orig = ACC(:,1);
acc_sig_orig  = ACC(:,2:4);
if size(ACC,2) > 4
    eyes = ACC(:,5);
end
% Original timeline: pass to milliseconds
acc_time_orig = (acc_time_orig-acc_time_orig(1))/10^3;

if interpolation
    % Interpolate the signal to restore missing samples
    [acc_time_int, acc_sig_int] = said_function(acc_time_orig, acc_sig_orig, 20);
else
    acc_time_int = (0:length(acc_time_orig)-1)*20;
    acc_sig_int = acc_sig_orig;
end

missed_samples_ratio = (length(acc_time_int) - length(acc_time_orig))/length(acc_time_int);

if missed_samples_ratio
    warning('ACC reader: Warning: %2.2f\% of samples are missing.',missed_samples_ratio*100);
end
end

