function set_Gs_production_rule(model_obj, flag)

    rule_Da_input = sbioselect(model_obj,'Type','Rule','Where','Name','==','rule_Da_input');
    rule_Da_input.Active = flag;
    if flag
        addevent(model_obj, 'time >= pulse_start', 'NC = 1*NC');
        addevent(model_obj, 'time >= pulse_start + pulse_duration', 'NC = 1*NC');
    end
end