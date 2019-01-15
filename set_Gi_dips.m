function set_Gi_dips(model_obj, flag)

    rule_ACh_inputs = sbioselect(model_obj,'Type','Rule','Where','Name','==','rule_ACh_inputs');
    rule_ACh_inputs.Active = flag;
    if flag
        dip_start_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','dip_start');
        dip_duration_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','dip_duration');
        dip_interval_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','dip_interval');
        ndips_par = sbioselect(model_obj,'Type','Parameter','Where','Name','==','ndips');
        
        dip_start = dip_start_par.Value;
        dip_duration = dip_duration_par.Value;
        dip_interval = dip_interval_par.Value;
        
        for n = 0:(ndips_par.Value - 1)
            begin = dip_start + (dip_interval+dip_duration)*n;
            finish = dip_start + dip_duration + (dip_interval+dip_duration)*n;
            e1 = addevent(model_obj, char(strcat('time >=', string(begin))), 'NC = 1*NC');
            e2 = addevent(model_obj, char(strcat('time >=', string(finish))), 'NC = 1*NC');
        end
    end

end