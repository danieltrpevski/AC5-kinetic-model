clear
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
ndips = 1;
dip_interval = 1.5;

% 2. Retrieve relevant rules and parameters
% 2.1 
pulse_start_par = sbioselect(m3, 'Type','Parameter','Where','Name','==','pulse_start');
pulse_duration_par = sbioselect(m3, 'Type','Parameter','Where','Name','==','pulse_duration');
dip_start_par = sbioselect(m3, 'Type','Parameter','Where','Name','==','dip_start');
dip_duration_par = sbioselect(m3, 'Type','Parameter','Where','Name','==','dip_duration');
dip_interval_par = sbioselect(m3, 'Type','Parameter','Where','Name','==','dip_interval');
ndips_par = sbioselect(m3, 'Type','Parameter','Where','Name','==','ndips');

pulse_start_par.Value = pulse_start;
pulse_duration_par.Value = pulse_duration;
dip_start_par.Value = dip_start;
dip_duration_par.Value = dip_duration;
dip_interval_par.Value = dip_interval;
ndips_par.Value = ndips;

totalAC5 = sbioselect(m3, 'Type','Species','Where','Name','==','totalAC5');
totalAC5 = totalAC5.InitialAmount;

% 2.2 Rules to set rate constants (predicted with BD)

kf1_par = sbioselect(m3,'Type','Parameter','Where','Name','==','kf1');
kf2_par = sbioselect(m3,'Type','Parameter','Where','Name','==','kf2');

kr1_par = sbioselect(m3,'Type','Parameter','Where','Name','==','kr1');
kr2_par = sbioselect(m3,'Type','Parameter','Where','Name','==','kr2');

kf1 = 0.018; kf2 = 0.02; KD1 = 100; KD2 = 100;
kf1_par.Value = kf1; kr1 = kf1 * KD1;
kf2_par.Value = kf2; kr2 = kf2 * KD2;

kr1_par.Value = kr1;
kr2_par.Value = kr2;

% 3. Simulation
% 3.1. Equilibrate the system for this set of parameters and set initial amounts
% of species. 
[tr, simdatar, namesr]= relaxsys_for_smallAC5(m3, time_to_equilibrate);
for i = 1:length(namesr)
    if strfind( namesr{i},'Spine.kc_agg')
        kc_ss = simdatar(end,i);
    end
end

% 3.2. Configure simulation
cs_obj = getconfigset(m3);
cs_obj.StopTime = simtime; 
cs_obj.RuntimeOptions.StatesToLog = {'AC5', 'AC5GaolfGTP', 'AC5GaiGTP', 'GaolfGTP', 'GaiGTP', 'kc_agg',...
     'kfGolf','kfGi'};
set(cs_obj.SolverOptions,'OutputTimes',output_time_points);

% 3.3. Run simulation
% a) Da peak + ACh dip
set_Gs_production_rule(m3, 1);
set_Gi_production_rule(m3, 1);
[t, simdata, names] = sbiosimulate(m3);

% b) Da peak
set_Gs_production_rule(m3, 1);
set_Gi_production_rule(m3, 0);
[t_Da, simdata_Da, names_Da] = sbiosimulate(m3);

% c) ACh dip
set_Gs_production_rule(m3, 0);
set_Gi_production_rule(m3, 1);
[t_ACh, simdata_ACh, names_ACh] = sbiosimulate(m3);

Synergy = ( simdata(:,6) + buff)./(simdata_Da(:,6) + simdata_ACh(:,6) - kc_ss + buff);  

% 4. Plot results

f1 = figure;
plot(t, simdata(:,1:3)/totalAC5*100);
xlabel('t');
ylabel('% of total AC5 amount');
lgd1 = legend({'AC5','AC5G\alpha_{olf}','AC5G\alpha_{i}'}, 'Box', 'off');
title('Da \uparrow + ACh \downarrow');
set(gca, 'TitleFontWeight', 'normal');

figure
plot(t, simdata(:,4)); hold on;
plot(t, simdata(:,5));
legend({'G\alpha_{olf}','G\alpha_{i}'});
xlabel('t');  
ylabel('[G\alpha] (nM)');
title('Da \uparrow + ACh \downarrow'); set(gca, 'TitleFontWeight', 'normal');
legend({'G_{olf\alpha}', 'G_{i\alpha}'}, 'Box', 'off');

figure
plot(t, simdata(:, 7)); hold on;
xlabel('t'); 
axis([0 10 0 5+eps]); 
ylabel('k_{fG_{olf}}');

figure
plot(t, simdata(:, 8));
xlabel('t'); 
axis([0 10 0 5+eps]); 
ylabel('k_{fG_{i}}');

%-----------------------------------------------
% Figure: average kc
% Inset - synergy
%-----------------------------------------------
f2 = figure;
plot(t, simdata(:,6)); hold on; 
plot(t, simdata_Da(:,6)); plot(t, simdata_ACh(:,6));
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
plot(t_Da, simdata_Da(:,1:3)/totalAC5*100);
xlabel('t');
lgd1 = legend({'AC5','AC5G\alpha_{olf}','AC5G\alpha_{i}'}, 'Box', 'off');
title('Da \uparrow'); set(gca, 'TitleFontWeight', 'normal');
ylabel('% of total AC5')

figure;
plot(t_Da, simdata_Da(:,4)); hold on;
plot(t_Da, simdata_Da(:,5));
legend({'G\alpha_{olf}', 'G\alpha_{i}'}, 'Box', 'off');
xlabel('t');
ylabel('[G\alpha] (nM)');
title('Da \uparrow'); set(gca, 'TitleFontWeight', 'normal');

f5 = figure;
plot(t_ACh, simdata_ACh(:,1:3)/totalAC5*100);
xlabel('t');
ylabel('% of total AC5 amount');
lgd1 = legend({'AC5','AC5G\alpha_{olf}','AC5G\alpha_{i}'}, 'Box', 'off');
title('ACh \downarrow'); set(gca, 'TitleFontWeight', 'normal');

figure
plot(t_ACh, simdata_ACh(:,4)); hold on;
plot(t_ACh, simdata_ACh(:,5));
legend({'G\alpha_{olf}', 'G\alpha_{i}'}, 'Box', 'off');
xlabel('t');
ylabel('[G\alpha]');
title('ACh \downarrow'); set(gca, 'TitleFontWeight', 'normal');
