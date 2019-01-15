clear;
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

% 2. Retrieve relevant rules and parameters
% 2.1 
pulse_start_par = sbioselect(m5, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_par = sbioselect(m5, 'Type','Parameter','Where','Name','==','pulse_duration');
pulse_start_par.Value = pulse_start;
pulse_duration_par.Value = pulse_duration;

dip_start_par = sbioselect(m5, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_par = sbioselect(m5, 'Type','Parameter','Where','Name','==','dip_duration');
dip_start_par.Value = dip_start;
dip_duration_par.Value = dip_duration;

% 2.2 Rules to set rate constants (predicted with BD)
kf1_par = sbioselect(m5,'Type','Parameter','Where','Name','==','kf1');
kf2_par = sbioselect(m5,'Type','Parameter','Where','Name','==','kf2');
kr1_par = sbioselect(m5,'Type','Parameter','Where','Name','==','kr1');
kr2_par = sbioselect(m5,'Type','Parameter','Where','Name','==','kr2');

kf1_holo_par = sbioselect(m5,'Type','Parameter','Where','Name','==','kfh1');
kf2_holo_par = sbioselect(m5,'Type','Parameter','Where','Name','==','kfh2');
kr1_holo_par = sbioselect(m5,'Type','Parameter','Where','Name','==','krh1');
kr2_holo_par = sbioselect(m5,'Type','Parameter','Where','Name','==','krh2');

kf1 = 0.018; kf2 = 0.02; KD1 = 100; KD2 = 100;
kf1_par.Value = kf1; kr1_par.Value = kf1*KD1;
kf2_par.Value = kf2; kr2_par.Value = kf2*KD2;

kf1_holo = 0.026; kf2_holo = 0.05; KD1 = 100; KD2 = 100;
kf1_holo_par.Value = kf1; kr1_holo_par.Value = kf1_holo*KD1;
kf2_holo_par.Value = kf2; kr2_holo_par.Value = kf2_holo*KD2;

totalAC5 = sbioselect(m5, 'Type','Species','Where', 'Name','==', 'totalAC5');
totalAC5 = totalAC5.InitialAmount;

% 3. Simulation
% 3.1. Equilibrate the system for this set of parameters and set initial amounts
% of species. 
[tr, simdatar, namesr]= relaxsys_for_smallAC5(m5, time_to_equilibrate);
for i = 1:length(namesr)
    if strfind( namesr{i},'Spine.kc_agg')
        kc_ss = simdatar(end,i);
    end
end

% 3.2. Configure simulation

cs_obj = getconfigset(m5);
cs_obj.StopTime = simtime; 
cs_obj.RuntimeOptions.StatesToLog = {'AC5','AC5ATP', 'AC5GaolfGTP', 'AC5GaolfGTPATP', ...
    'AC5GaiGTP','AC5GaiGTPATP', 'GaolfGTP','GaiGTP',...
    'kc_agg', 'cAMP'};
set(cs_obj.SolverOptions,'OutputTimes',output_time_points);

% 3.3. Run simulation
% a) Da peak + ACh dip
set_Gs_production_rule(m5, 1);
set_Gi_production_rule(m5, 1);
[t, simdata, names] = sbiosimulate(m5);

% b) Da peak 
set_Gs_production_rule(m5, 1);
set_Gi_production_rule(m5, 0);
[t_Da, simdata_Da, names_Da] = sbiosimulate(m5);

% c) ACh dip
set_Gs_production_rule(m5, 0);
set_Gi_production_rule(m5, 1);
[t_ACh, simdata_ACh, names_ACh] = sbiosimulate(m5);

Synergy = ( simdata(:,9) + buff)./(simdata_Da(:,9) + simdata_ACh(:,9) - kc_ss + buff);  

% 4. Plot results
pos = [239   493   277   229];
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesFontSize',16);
set(0, 'DefaultAxesFontName', 'MathJax_Main');

f0 = figure;
plot(t, simdata(:,10)); hold on;
plot(t_Da, simdata_Da(:,10)); plot(t_ACh, simdata_ACh(:,10));
ylabel({'cAMP (nM)'});
xlabel('t');
set(f0, 'Position',pos); box off;

f1 = figure;
cAMP_baseline = min(simdata(:,10));
plot(t, simdata(:,10)/cAMP_baseline); hold on;
plot(t_Da, simdata_Da(:,10)/cAMP_baseline); plot(t_ACh, simdata_ACh(:,10)/cAMP_baseline);
ylabel({'[cAMP]/[cAMP]_0'});
xlabel('t'); 
set(f1, 'Position',pos); box off;

