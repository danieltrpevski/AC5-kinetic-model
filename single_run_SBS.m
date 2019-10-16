clear
sbioloadproject AC5small

% 1. Some simulation variables

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
ndips = 1;
dip_interval = 1.5;

% 2. Retrieve relevant rules and parameters
% 2.1 
totalAC5 = sbioselect(m1, 'Type','Species','Where', 'Name','==', 'totalAC5');
totalAC5 = totalAC5.InitialAmount;

pulse_start_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','pulse_duration');
pulse_start_par.Value = pulse_start;
pulse_duration_par.Value = pulse_duration;

dip_start_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_duration');
dip_interval_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','dip_interval');
ndips_par = sbioselect(m1, 'Type','Parameter','Where','Name','==','ndips');
dip_interval_par.Value = dip_interval;
dip_start_par.Value = dip_start;
dip_duration_par.Value = dip_duration;
ndips_par.Value = ndips;

% 2.2 Rules to set the rate constants (predicted with BD)

kf1_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf1');
kf2_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf2');
kf3_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf3');
kf4_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kf4');

kr1_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr1');
kr2_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr2');
kr3_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr3');
kr4_par = sbioselect(m1,'Type','Parameter','Where','Name','==','kr4');

kf1 = 0.018; kf2 = 0.02; kf3 = 0.012; kf4 = 0.02;
KD1 = 100; KD2 = 100; KD3 = 100; KD4 = KD1*KD3/KD2;
kf1_par.Value = kf1; kr1 = kf1*KD1; 
kf2_par.Value = kf2; kr2 = kf2*KD2;
kf3_par.Value = kf3; kr3 = kf3*KD3*10;
kf4_par.Value = kf4; kr4 = kf4*KD4*10;

kr1_par.Value = kr1; 
kr2_par.Value = kr2; 
kr3_par.Value = kr3; 
kr4_par.Value = kr4; 

% 3. Simulation
% 3.1. Equilibrate the system for this set of parameters and set initial amounts
% of species. 
[tr, simdatar, namesr]= relaxsys_for_smallAC5(m1, time_to_equilibrate);
for i = 1:length(namesr)
    if strfind( namesr{i},'Spine.kc_agg')
        kc_ss = simdatar(end,i);
    end
end

% 3.2. Configure simulation

cs_obj = getconfigset(m1);
cs_obj.StopTime = simtime; 
cs_obj.RuntimeOptions.StatesToLog = {'AC5', 'AC5GaolfGTP', 'AC5GaiGTP', 'AC5GaolfGTPGaiGTP', 'GaolfGTP',...
    'GaiGTP', 'kc_agg', 'kfGolf','kfGi'};
set(cs_obj.SolverOptions,'OutputTimes',output_time_points);

% 3.3. Run simulation
% a) Da peak + ACh dip
set_Gs_production_rule(m1, 1);
set_Gi_production_rule(m1, 1);
[t, simdata, names] = sbiosimulate(m1);

% b) Da peak
set_Gs_production_rule(m1, 1);
set_Gi_production_rule(m1, 0);
[t_Da, simdata_Da, names_Da] = sbiosimulate(m1);

% c) ACh dip
set_Gs_production_rule(m1, 0);
set_Gi_production_rule(m1, 1);
[t_ACh, simdata_ACh, names_ACh] = sbiosimulate(m1);

Synergy = ( simdata(:,7) + buff)./(simdata_Da(:,7) + simdata_ACh(:,7) - kc_ss + buff);  

% 4. Plot results

set(0, 'DefaultLineLineWidth', 2);
set(0, 'DefaultAxesFontSize',16);
set(0, 'DefaultAxesFontName', 'MathJax_Main');

f1 = figure;
plot(t, simdata(:,1:4)/totalAC5*100);
xlabel('t');
ylabel('% of total AC5 amount');
lgd1 = legend({'AC5','AC5G\alpha_{olf}','AC5G\alpha_{i}', 'G\alpha_{i}AC5G\alpha_{olf}'}, 'Box', 'off');
title('Da \uparrow + ACh \downarrow');
set(gca, 'TitleFontWeight', 'normal');

figure
plot(t, simdata(:,5)); hold on;
plot(t, simdata(:,6));
legend({'G\alpha_{olf}','G\alpha_{i}'});
xlabel('t');  
ylabel('[G\alpha] (nM)');
title('Da \uparrow + ACh \downarrow'); set(gca, 'TitleFontWeight', 'normal');
legend({'G_{olf\alpha}', 'G_{i\alpha}'}, 'Box', 'off');

figure
plot(t, simdata(:, 8)); hold on;
xlabel('t'); 
axis([0 10 0 5+eps]); 
ylabel('k_{fG_{olf}}');

figure
plot(t, simdata(:, 9));
xlabel('t'); 
axis([0 10 0 5+eps]); 
ylabel('k_{fG_{i}}');

%-----------------------------------------------
% Figure: average kc
% Inset - synergy
%-----------------------------------------------
f2 = figure;
plot(t, simdata(:,7)); hold on; 
plot(t, simdata_Da(:,7)); plot(t, simdata_ACh(:,7));
xlabel('t'); 
legend({'Da \uparrow + ACh \downarrow', 'Da \uparrow', 'ACh \downarrow'}, 'Box', 'off');
ylabel('k_c');
axis([0 15 0 15]);

f3 = figure;
plot(t, Synergy);
xlabel('t');
ylabel('S');
axis([0 15 0.98 5]);

f4 = figure;
plot(t_Da, simdata_Da(:,1:4)/totalAC5*100);
xlabel('t');
lgd1 = legend({'AC5','AC5G\alpha_{olf}','AC5G\alpha_{i}', 'G\alpha_{i}AC5G\alpha_{olf}'}, 'Box', 'off');
title('Da \uparrow'); set(gca, 'TitleFontWeight', 'normal');
ylabel('% of total AC5')

figure;
plot(t_Da, simdata_Da(:,5)); hold on;
plot(t_Da, simdata_Da(:,6));
legend({'G\alpha_{olf}', 'G\alpha_{i}'}, 'Box', 'off');
xlabel('t');
ylabel('[G\alpha] (nM)');
title('Da \uparrow'); set(gca, 'TitleFontWeight', 'normal');

f5 = figure;
plot(t_ACh, simdata_ACh(:,1:4)/totalAC5*100);
xlabel('t');
ylabel('% of total AC5 amount');
lgd1 = legend({'AC5','AC5G\alpha_{olf}','AC5G\alpha_{i}', 'G\alpha_{i}AC5G\alpha_{olf}'}, 'Box', 'off');
title('ACh \downarrow'); set(gca, 'TitleFontWeight', 'normal');

figure
plot(t_ACh, simdata_ACh(:,5)); hold on;
plot(t_ACh, simdata_ACh(:,6));
legend({'G\alpha_{olf}', 'G\alpha_{i}'}, 'Box', 'off');
xlabel('t');
ylabel('[G\alpha]');
title('ACh \downarrow'); set(gca, 'TitleFontWeight', 'normal');
