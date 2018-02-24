function [emg_sig_int, emg_time_int, eyes, missed_samples_ratio, emg_time_orig, emg_sig_orig] = myo_emg_reader( filename, interpolation )

% Read the txt file
EMG = dlmread(filename);
emg_time_orig = EMG(:,1);
emg_sig_orig = EMG(:,2:9);
if size(EMG,2) > 9
    eyes = EMG(:,10);
end

% Original timeline: pass to milliseconds
emg_time_orig = (emg_time_orig-emg_time_orig(1))/10^3;

if interpolation
    % Interpolate the signal to restore missing samples
    [emg_time_int, emg_sig_int] = interpolate_missing_samples(emg_time_orig, emg_sig_orig, 5);
else
    emg_time_int = (0:length(emg_time_orig)-1)*5;
    emg_sig_int = emg_sig_orig;
end

missed_samples_ratio = (length(emg_time_int) - length(emg_time_orig))/length(emg_time_int);
if missed_samples_ratio
    warning('EMG Reader: Warning: %2.2f\% of samples are missing.',missed_samples_ratio*100);
end

end

