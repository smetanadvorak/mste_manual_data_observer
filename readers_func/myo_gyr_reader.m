function [gyr_sig_int, gyr_time_int, eyes, missed_samples_ratio, gyr_time_orig, gyr_sig_orig] = myo_gyr_reader( filename, interpolation )

GYR = dlmread(filename);
gyr_time_orig = GYR(:,1);
gyr_sig_orig  = GYR(:,2:4);
if size(GYR,2) > 4
    eyes = GYR(:,5);
end
% Original timeline: pass to milliseconds
gyr_time_orig = (gyr_time_orig-gyr_time_orig(1))/10^3;

if interpolation
    % Interpolate the signal to restore missing samples
    [gyr_time_int, gyr_sig_int] = said_function(gyr_time_orig, gyr_sig_orig, 20);
else
    gyr_time_int = (0:length(gyr_time_orig)-1)*20;
    gyr_sig_int = gyr_sig_orig;
end

missed_samples_ratio = (length(gyr_time_int) - length(gyr_time_orig))/length(gyr_time_int);

if missed_samples_ratio
    warning('GYR reader: Warning: %2.2f\% of samples are missing.',missed_samples_ratio*100);
end
end

