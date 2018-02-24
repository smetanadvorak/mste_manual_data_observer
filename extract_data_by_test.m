function   extract_data_by_test(dataset, experiment_name)
addpath(genpath(pwd));

% Make a list of patients' folders
cd(['..' filesep 'data_original' filesep dataset]);
patientFolds = getFolderNames();

%Variable containing the number of subfolders (visit dates) for each patient
visits_n=zeros(length(patientFolds),1);
data_grouped = [];

for patient = 1:(length(patientFolds))
    cd(patientFolds{patient});
    visitFolds = getFolderNames();
    visits_n(patient)=length(visitFolds);
    
    %Accessing each visit
    for visit = 1:length(visitFolds)
        cd(visitFolds{visit});
        
        % Accessing specified test
        if( exist([pwd filesep experiment_name],'dir') )% If test folder exists
            cd(experiment_name);
            trialFolds = getFolderNames();
            s=struct;  % structure pour chaque patient dont les ?lements sont les signaux emg de chaque essai et le label
            
            % Accessing all trials
            for trial = 1:length(trialFolds)
                cd(trialFolds{trial});
                [emg_sig_int, emg_time_int] = myo_emg_reader('emg.txt', false); %Second argument is true if interpolation to initial data is applied. For now, preferably set to 0. 
                s.emg_sig{trial}=emg_sig_int;
                s.emg_time{trial}=emg_time_int;
                
                [orn_sig_int, orn_time_int] = myo_orn_reader('orientation.txt', false); 
                s.orn_sig{trial}=orn_sig_int;
                s.orn_time{trial}=orn_time_int;
                
                [acc_sig_int, acc_time_int] = myo_acc_reader('acceleration.txt', false);
                acc_sig_int = compensate_gravity(acc_sig_int, orn_sig_int);
                s.acc_sig{trial}=acc_sig_int;
                s.acc_time{trial}=acc_time_int;
                
                [gyr_sig_int, gyr_time_int] = myo_gyr_reader('gyroscope.txt', false);
                s.gyr_sig{trial}=gyr_sig_int;
                s.gyr_time{trial}=gyr_time_int;
                
                cd ..
            end
            
            if patient==1
                eval([ 'patient_' num2str(visit) ' = s ;' ]); % renameles diff?rents signaux emg
            else
                eval([ 'patient_' num2str(visit+sum(visits_n(1:(patient-1)))) ' = s;' ]);
            end
            
            % Labelling
            s.patient_label = patientFolds{patient};
            
            if strfind(s.patient_label, 'MS')
                s.groupe_label = 1;
                s.groupe_text = 'MS';
            else
                s.groupe_label = 0;
                s.groupe_text = 'HC';
            end
            
            % Valid intervals
            s.valid_interval = cell(size(s.emg_sig));
            s.artifact = cell(size(s.emg_sig));
            s.quality = cell(size(s.emg_sig));
            
            data_grouped = [data_grouped, s];
            
            cd(['..' filesep '..']) % acc?s ? une autre donn?e emg du meme folder ( ex. patient_normal)
        else % if no specified test for this visit
            cd ..     
        end
    end
    cd ..  % acc?s au deuxi?me folder ( ex. patient_sclerose)
end
cd ..
cd ..
cd data_matlab
save([experiment_name, '_', dataset],'data_grouped'); % sauvegarder les diff?rentes signaux emg et la varable du label dans un le fichier emg_global.mat
fprintf('\nData saved in folder %s\n', pwd);
cd .. 
cd myo_classification
end




