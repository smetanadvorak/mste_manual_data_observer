%addpath(genpath('features_func')); addpath(genpath('sp_func')); addpath(genpath('readers_func')); addpath(genpath('utilities_func'));
addpath(genpath(pwd));

global database_name
database_name = 'Finger to nose_einar_full';

cd .. 
cd data_matlab
cd data_marking_in_progress
load(database_name);
cd ..
cd ..
cd myo_classification

global data
data = data_grouped;

sv = signal_viewer();