clear all;
sbioloadproject AC5small

pulse_duration = 0.5;
dip_duration = 0.5;
simtime = 15;
pulse_start = 3; 
dip_start = 3; 
time_to_equilibrate = 1000;
time_step = 0.02;
points_per_second = 1/time_step;
output_time_points = 0:time_step:simtime;
buff = 0.01;

totalAC5 = sbioselect(m4, 'Type','Species','Where', 'Name','==', 'totalAC5');
totalAC5 = totalAC5.InitialAmount;

pulse_start_par = sbioselect(m4, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_par = sbioselect(m4, 'Type','Parameter','Where','Name','==','pulse_duration');
pulse_start_par.Value = pulse_start;
pulse_duration_par.Value = pulse_duration;

dip_start_par = sbioselect(m4, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_par = sbioselect(m4, 'Type','Parameter','Where','Name','==','dip_duration');
dip_start_par.Value = dip_start;
dip_duration_par.Value = dip_duration;


% 2.2 Rules to set rate constants (predicted with BD)
kf1_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kf1');
kf2_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kf2');
kf3_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kf3');
kf4_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kf4');

kr1_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kr1');
kr2_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kr2');
kr3_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kr3');
kr4_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kr4');

kf1_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kfh1');
kf2_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kfh2');
kf3_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kfh3');
kf4_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','kfh4');

kr1_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','krh1');
kr2_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','krh2');
kr3_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','krh3');
kr4_holo_par = sbioselect(m4,'Type','Parameter','Where','Name','==','krh4');

kf1 = 0.018; kf2 = 0.02; kf3 = 0.012; kf4 = 0.02; % 0.02
KD1 = 100; KD2 = 100; KD3 = 100*10; KD4 = KD1*KD3/KD2;
kf1_par.Value = kf1; kr1_par.Value = kf1*KD1;
kf2_par.Value = kf2; kr2_par.Value = kf2*KD2;
kf3_par.Value = kf3; kr3_par.Value = kf3*KD3;
kf4_par.Value = kf4; kr4_par.Value = kf4*KD4;

kf1_holo = 0.026; kf2_holo = 0.05; kf3_holo = 0.017; kf4_holo = 0.02; %0.02
KD1 = 100; KD2 = 100; KD3 = 100*10; KD4 = KD1*KD3/KD2;
kf1_holo_par.Value = kf1; kr1_holo_par.Value = kf1*KD1;
kf2_holo_par.Value = kf2; kr2_holo_par.Value = kf2*KD2;
kf3_holo_par.Value = kf3; kr3_holo_par.Value = kf3*KD3;
kf4_holo_par.Value = kf4; kr4_holo_par.Value = kf4*KD4;

% 3. Simulation
% 3.1. Equilibrate the system for this set of parameters and set initial amounts
% of species. 
[tr, simdatar, namesr] = relaxsys_for_smallAC5(m4, time_to_equilibrate);
for i = 1:length(namesr)
    if strfind( namesr{i},'Spine.kc_agg')
        kc_ss = simdatar(end,i);
    end
end

% 3.2. Configure simulation
cs_obj = getconfigset(m4);
cs_obj.StopTime = simtime; 
cs_obj.RuntimeOptions.StatesToLog = {'AC5','AC5ATP', 'AC5GaolfGTP','AC5GaolfGTPATP',...
    'AC5GaiGTP', 'AC5GaiGTPATP', 'AC5GaolfGTPGaiGTP','AC5GaolfGTPGaiGTPATP', ...
    'GaolfGTP','GaiGTP', 'kc_agg', 'cAMP'};
set(cs_obj.SolverOptions,'OutputTimes',output_time_points);

% 3.3. Run simulation
% a) Da peak + ACh dip
set_Gs_production_rule(m4, 1);
set_Gi_production_rule(m4, 1);
[t, simdata, names] = sbiosimulate(m4);

% b) Da peak 
set_Gs_production_rule(m4, 1);
set_Gi_production_rule(m4, 0);
[t_Da, simdata_Da, names_Da] = sbiosimulate(m4);

% c) ACh dip
set_Gs_production_rule(m4, 0);
set_Gi_production_rule(m4, 1);
[t_ACh, simdata_ACh, names_ACh] = sbiosimulate(m4);

Synergy = ( simdata(:,11) + buff)./(simdata_Da(:,11) + simdata_ACh(:,11) - kc_ss + buff);  

% 4. Plot results
pos = [239   493   277   229];

set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesFontSize',16);
set(0, 'DefaultAxesFontName', 'MathJax_Main');

f0 = figure;
plot(t, simdata(:,12)); hold on;
plot(t_Da, simdata_Da(:,12)); plot(t_ACh, simdata_ACh(:,12));
ylabel({'cAMP (nM)'});
xlabel('t');
set(f0, 'Position',pos); box off;

f1 = figure;
cAMP_baseline = min(simdata(:,12));
plot(t, simdata(:,12)/cAMP_baseline); hold on;
plot(t_Da, simdata_Da(:,12)/cAMP_baseline); plot(t_ACh, simdata_ACh(:,12)/cAMP_baseline);
ylabel({'[cAMP]/[cAMP]_0'});
xlabel('t');
set(f1, 'Position',pos); box off;
