function set_Gs_pulses(model_obj, flag)

    rule_ACh_inputs = sbioselect(model_obj,'Type','Rule','Where','Name','==','rule_Da_inputs');
    rule_ACh_inputs.Active = flag;
    if flag
        pulse_start_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','pulse_start');
        pulse_duration_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','pulse_duration');
        pulse_interval_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','pulse_interval');
        npulses_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','npulses');
        
        pulse_start = pulse_start_par.Value;
        pulse_duration = pulse_duration_par.Value;
        pulse_interval = pulse_interval_par.Value;
        
        for n = 0:(npulses_par.Value - 1)
            begin = pulse_start + (pulse_interval+pulse_duration)*n;
            finish = pulse_start + pulse_duration + (pulse_interval+pulse_duration)*n;
            e1 = addevent(model_obj, char(strcat('time >=', string(begin))), 'NC = 1*NC');
            e2 = addevent(model_obj, char(strcat('time >=', string(finish))), 'NC = 1*NC');
        end
    end

end