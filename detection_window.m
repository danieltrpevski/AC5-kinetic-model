clear
sbioloadproject AC5small

% 1. Set some simulation variables
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
tdiff = -5:0.125:20;

kf1 = 0.018; kf2 = 0.02; kf3 = 0.012; kf4 = 0.02;
KD1 = 100; KD2 = 100; KD3 = 100*10; KD4 = KD1*KD3/KD2;
kr1 = kf1*KD1; 
kr2 = kf2*KD2;
kr3 = kf3*KD3;
kr4 = kf4*KD4;

% 2. Retrieve relevant rules and parameters
% 2.1. 
pulse_start_m3 = sbioselect(m3, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_m3 = sbioselect(m3, 'Type','Parameter','Where','Name','==','pulse_duration');
dip_start_m3 = sbioselect(m3, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_m3 = sbioselect(m3, 'Type','Parameter','Where','Name','==','dip_duration');

pulse_start_m3.Value = pulse_start;
pulse_duration_m3.Value = pulse_duration;
dip_start_m3.Value = dip_start;
dip_duration_m3.Value = dip_duration;

pulse_start_m1 = sbioselect(m1, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_m1 = sbioselect(m1, 'Type','Parameter','Where','Name','==','pulse_duration');
dip_start_m1 = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_m1 = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_duration');

pulse_start_m1.Value = pulse_start;
pulse_duration_m1.Value = pulse_duration;
dip_start_m1.Value = dip_start;
dip_duration_m1.Value = dip_duration;

pulse_start_m2 = sbioselect(m2, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_m2 = sbioselect(m2, 'Type','Parameter','Where','Name','==','pulse_duration');
dip_start_m2 = sbioselect(m2, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_m2 = sbioselect(m2, 'Type','Parameter','Where','Name','==','dip_duration');

pulse_start_m2.Value = pulse_start;
pulse_duration_m2.Value = pulse_duration;
dip_start_m2.Value = dip_start;
dip_duration_m2.Value = dip_duration;

% 2.2 Rules to set rate constants (predicted with BD)
kf1_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kf1');
kf2_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kf2');
kf3_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kf3');
kf4_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kf4');

kr1_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kr1');
kr2_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kr2');
kr3_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kr3');
kr4_par_m1 = sbioselect(m1,'Type','Parameter','Where','Name','==','kr4');

kf1_par_m2 = sbioselect(m2,'Type','Parameter','Where','Name','==','kf1');
kf2_par_m2 = sbioselect(m2,'Type','Parameter','Where','Name','==','kf2');
kf3_par_m2 = sbioselect(m2,'Type','Parameter','Where','Name','==','kf3');

kr1_par_m2 = sbioselect(m2,'Type','Parameter','Where','Name','==','kr1');
kr2_par_m2 = sbioselect(m2,'Type','Parameter','Where','Name','==','kr2');
kr3_par_m2 = sbioselect(m2,'Type','Parameter','Where','Name','==','kr3');

kf1_par_m3 = sbioselect(m3,'Type','Parameter','Where','Name','==','kf1');
kf2_par_m3 = sbioselect(m3,'Type','Parameter','Where','Name','==','kf2');
kr1_par_m3 = sbioselect(m3,'Type','Parameter','Where','Name','==','kr1');
kr2_par_m3 = sbioselect(m3,'Type','Parameter','Where','Name','==','kr2');

kf1_par_m1.Value = kf1; kf1_par_m2.Value = kf1; kf1_par_m3.Value = kf1;
kf2_par_m1.Value = kf2; kf2_par_m2.Value = kf2; kf2_par_m3.Value = kf2;
kf3_par_m1.Value = kf3; kf3_par_m2.Value = kf3;
kf4_par_m1.Value = kf4;

kr1_par_m1.Value = kr1; kr1_par_m2.Value = kr1; kr1_par_m3.Value = kr1; 
kr2_par_m1.Value = kr2; kr2_par_m2.Value = kr2; kr2_par_m3.Value = kr2; 
kr3_par_m1.Value = kr3; kr3_par_m2.Value = kr3;
kr4_par_m1.Value = kr4;

% 3. Simulation
% 3.1. Equilibrate the system for this set of parameters and set initial amounts
% of species. 

[tr, simdatar_m1, namesr_m1]= relaxsys_for_smallAC5(m1, time_to_equilibrate);
[tr, simdatar_m2, namesr_m2]= relaxsys_for_smallAC5(m2, time_to_equilibrate);
[tr, simdatar_m3, namesr_m3]= relaxsys_for_smallAC5(m3, time_to_equilibrate);

for i = 1:length(namesr_m1)
    if strfind( namesr_m1{i},'Spine.kc_agg')
        kc_ss_m1 = simdatar_m1(end,i);
    end
end
for i = 1:length(namesr_m2)
    if strfind( namesr_m2{i},'Spine.kc_agg')
        kc_ss_m2 = simdatar_m2(end,i);
    end
end
for i = 1:length(namesr_m3)
    if strfind( namesr_m3{i},'Spine.kc_agg')
        kc_ss_m3 = simdatar_m3(end,i);
    end
end

% 3.2. Configure simulation
cs_obj_m1 = getconfigset(m1);
cs_obj_m1.StopTime = simtime; 
cs_obj_m1.RuntimeOptions.StatesToLog = {'AC5', 'AC5GaolfGTP', 'AC5GaiGTP', 'AC5GaolfGTPGaiGTP', 'GaolfGTP',...
    'GaiGTP', 'kc_agg', 'kfGaolfGDPtoGaolfGTP','kfGaiGDPtoGaiGTP'};
set(cs_obj_m1.SolverOptions,'OutputTimes',output_time_points);

cs_obj_m2 = getconfigset(m2);
cs_obj_m2.StopTime = simtime; 
cs_obj_m2.RuntimeOptions.StatesToLog = {'AC5', 'AC5GaolfGTP', 'AC5GaiGTP', 'AC5GaolfGTPGaiGTP', 'GaolfGTP',...
    'GaiGTP', 'kc_agg', 'kfGaolfGDPtoGaolfGTP','kfGaiGDPtoGaiGTP'};
set(cs_obj_m2.SolverOptions,'OutputTimes',output_time_points);

cs_obj_m3 = getconfigset(m3);
cs_obj_m3.StopTime = simtime; 
cs_obj_m3.RuntimeOptions.StatesToLog = {'AC5', 'AC5GaolfGTP', 'AC5GaiGTP', 'GaolfGTP', 'GaiGTP', 'kc_agg',...
     'kfGaolfGDPtoGaolfGTP','kfGaiGDPtoGaiGTP'};
set(cs_obj_m3.SolverOptions,'OutputTimes',output_time_points);

% 3.3. Run simulation
% Initialize storage vectors
res_m1 = zeros(1, length(tdiff));
res_m2 = res_m1; res_m3 = res_m1;

% Run loop for simulations of each model
for i = 1:length(tdiff)
    dip_start_m1.Value = pulse_start + tdiff(i);
    dip_start_m2.Value = pulse_start + tdiff(i);
    dip_start_m3.Value = pulse_start + tdiff(i);

    % 1. Simultaneous binding motif 
    % a) Da peak + ACh pause 
    set_Gs_production_rule(m1, 1);
    set_Gi_production_rule(m1, 1);
    [t, simdata_m1, names] = sbiosimulate(m1);
    
    % b) Da peak
    set_Gs_production_rule(m1, 1);
    set_Gi_production_rule(m1, 0);
    [t_Da, simdata_Da_m1, names_Da] = sbiosimulate(m1);

    % c) ACh pause
    set_Gs_production_rule(m1, 0);
    set_Gi_production_rule(m1, 1);
    [t_ACh, simdata_ACh_m1, names_ACh] = sbiosimulate(m1);

    Synergy_m1 = ( simdata_m1(:,7) + buff)./(simdata_Da_m1(:,7) + simdata_ACh_m1(:,7) - kc_ss_m1 + buff);  
    res_m1(i) = max(Synergy_m1);
    
    % 2. Hindered simultaneous binding motif
    % a) Da peak + ACh pause
    set_Gs_production_rule(m2, 1);
    set_Gi_production_rule(m2, 1);
    [t, simdata_m2, names] = sbiosimulate(m2);
    
    % b) Da peak
    set_Gs_production_rule(m2, 1);
    set_Gi_production_rule(m2, 0);
    [t_Da, simdata_Da_m2, names_Da] = sbiosimulate(m2);

    % c) ACh pause
    set_Gs_production_rule(m2, 0);
    set_Gi_production_rule(m2, 1);
    [t_ACh, simdata_ACh_m2, names_ACh] = sbiosimulate(m2);
    
    Synergy_m2 = ( simdata_m2(:,7) + buff)./(simdata_Da_m2(:,7) + simdata_ACh_m2(:,7) - kc_ss_m2 + buff);  
    res_m2(i) = max(Synergy_m2);
    
    % 3. Allosteric occlusion motif
    % a) Da peak + ACh pause
    set_Gs_production_rule(m3, 1);
    set_Gi_production_rule(m3, 1);
    [t, simdata_m3, names] = sbiosimulate(m3);
    
    % b) Da peak
    set_Gs_production_rule(m3, 1);
    set_Gi_production_rule(m3, 0);
    [t_Da, simdata_Da_m3, names_Da] = sbiosimulate(m3);

    % c) ACh pause
    set_Gs_production_rule(m3, 0);
    set_Gi_production_rule(m3, 1);
    [t_ACh, simdata_ACh_m3, names_ACh] = sbiosimulate(m3);
    
    Synergy_m3 = ( simdata_m3(:,6) + buff)./(simdata_Da_m3(:,6) + simdata_ACh_m3(:,6) - kc_ss_m3 + buff);  
    res_m3(i) = max(Synergy_m3);
end
set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesFontSize',16);
set(0, 'DefaultAxesFontName', 'MathJax_Main');

plot(tdiff,res_m1, tdiff,res_m2, tdiff,res_m3);
xlabel('t_{ACh \downarrow} - t_{Da \uparrow}');
ylabel('max(S)');
legend({'SBS', 'HSBS', 'ABS'}, 'Box', 'off');
pos=[0.1424 0.1463 0.7626 0.7718];
set(gca,'Position', pos);
axis([-5 20 0.998 5]);