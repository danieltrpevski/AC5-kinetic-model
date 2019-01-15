function set_Gi_production_rule(model_obj, flag)

    rule_ACh_input = sbioselect(model_obj,'Type','Rule','Where','Name','==','rule_ACh_input');
    rule_ACh_input.Active = flag;
    if flag
        addevent(model_obj, 'time >= dip_start', 'NC = 1*NC');
        addevent(model_obj, 'time >= dip_start + dip_duration', 'NC = 1*NC');
    end

end