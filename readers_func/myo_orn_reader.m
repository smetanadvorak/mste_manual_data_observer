function [orn_sig_int, orn_time_int, eyes, missed_samples_ratio, orn_time_orig, orn_sig_orig] = myo_orn_reader( filename, interpolation )

ORN = dlmread(filename);
orn_time_orig = ORN(:,1);
orn_sig_orig  = ORN(:,2:5);
if size(ORN,2) > 5
    eyes = ORN(:,6);
end
% Original timeline: pass to milliseconds
orn_time_orig = (orn_time_orig-orn_time_orig(1))/10^3;

if interpolation
    % Interpolate the signal to restore missing samples
    [orn_time_int, orn_sig_int] = said_function(orn_time_orig, orn_sig_orig, 20);
else
    orn_time_int = (0:length(orn_time_orig)-1)*20;
    orn_sig_int = orn_sig_orig;
end

missed_samples_ratio = (length(orn_time_int) - length(orn_time_orig))/length(orn_time_int);

if missed_samples_ratio
    warning('ACC reader: Warning: %2.2f\% of samples are missing.',missed_samples_ratio*100);
end
end

