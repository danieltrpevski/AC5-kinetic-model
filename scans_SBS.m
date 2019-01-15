clear all;
sbioloadproject AC5

% 1. Set some simulation variables
pulse_duration = 0.5;
dip_duration = 0.5;
simtime = 20;
pulse_start = 7; %simtime/10;
dip_start = 7; %simtime/10;
time_to_equilibrate = 1000;
time_step = 0.02;
output_time_points = 0:time_step:simtime;
points_per_second = 1/time_step;
buff = 0.01;

% 2. Retrieve relevant rules and parameters
pulse_start_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','pulse_duration');
pulse_start_par.Value = pulse_start;
pulse_duration_par.Value = pulse_duration;

dip_start_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_duration');
dip_start_par.Value = dip_start;
dip_duration_par.Value = dip_duration;

kf1_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf1');
kf2_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf2');
kf3_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf3');
kf4_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf4');

kr1_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr1');
kr2_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr2');
kr3_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr3');
kr4_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr4');

% 3. Simulation
% 3.1. Configure simulation
cs_obj = getconfigset(m1);
cs_obj.StopTime = simtime;
set(cs_obj.SolverOptions,'OutputTimes',output_time_points);

% 3.2. Set range for parameter scan. Initialize variables
KD1 = 100; KD2 = 100; KD3 = 100*10; KD4 = KD1*KD3/KD2;
kf1 = [0.0002 0.0004 0.001 0.002 0.004 0.01 0.02 0.05 0.1 0.2 0.5 1 2]; %logspace(-2.7,0.3,10);
kf2 = kf1; 
kf3 = kf2; 
kf4 = kf1; % For the hindered SBS use kf4 = kf1/100; 

scandata = (-1)*ones(length(kf1), length(kf1)); 
kc_max = zeros(length(kf1), length(kf1));  
kr3_used = zeros(length(kf1), length(kf1));

% 3.3. Parameter scan
for i = 1:length(kf1)
    kf1_par.Value = kf1(i); kr1_par.Value = kf1(i) * KD1;
    kf4_par.Value = kf4(i); kr4_par.Value = kf4(i) * KD4;
    
    for j = 1:length(kf2)
        tic
        kf2_par.Value = kf2(j); kr2_par.Value = kf2(j) * KD2;
        kf3_par.Value = kf3(j); kr3_par.Value = kf3(j) * KD3; 
        
        set_Gs_production_rule(m1, 0);
        set_Gi_production_rule(m1, 0);
        cs_obj.RuntimeOptions.StatesToLog = 'all';
        [tr, simdatar, namesr]= relaxsys_for_smallAC5(m1, time_to_equilibrate);
 
        for n = 1:length(namesr)
            if strfind( namesr{n},'Spine.kc_agg')
                kc_ss = simdatar(end,n);
            end
        end
        
        cs_obj.RuntimeOptions.StatesToLog = {'kc_agg'};
        set_Gs_production_rule(m1, 1);
        set_Gi_production_rule(m1, 1);
        [t, simdata, names] = sbiosimulate(m1);

        set_Gs_production_rule(m1, 1);
        set_Gi_production_rule(m1, 0);
        [t_Da, simdata_Da, names_Da] = sbiosimulate(m1);
      
        set_Gs_production_rule(m1, 0);
        set_Gi_production_rule(m1, 1);
        [t_ACh, simdata_ACh, names_ACh] = sbiosimulate(m1);
        
        Synergy = (simdata + buff)./(simdata_Da + simdata_ACh - kc_ss + buff);  
        
        scandata(i,j) = max(Synergy);
        kc_max(i,j) = max(simdata);
        toc
    end

end

% 4. Plot results
pos = [238   698   418   362];

f = figure;
ax = axes;
heatmap(kf1,kf2,scandata(:,:)');  
set(gcf, 'Position', pos);
set(gca, 'Colormap', brewermap([],'Greens'));

f = figure;
ax = axes;
heatmap(kf1,kf2,kc_max(:,:)');    
set(gcf, 'Position', pos);
set(gca, 'Colormap', brewermap([],'Greens'));

f = figure;
ax = axes;
C = (kc_max(:,:)'.*scandata(:,:)'); 
heatmap(kf1,kf2,C);
set(gcf, 'Position', pos);
set(gca, 'Colormap', brewermap([],'Greens'));