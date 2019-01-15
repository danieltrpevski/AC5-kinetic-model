function kf = da_square_pulse(t, pulse_start, duration, kf_value, kf_ss_value)
    
    if t >= pulse_start && t < pulse_start + duration
        kf = kf_value;
    else 
        kf = kf_ss_value;
    end
end
