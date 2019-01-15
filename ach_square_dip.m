function kf = ach_square_dip(t, dip_start, duration, kf_value, kf_ss_value)

    if t >= dip_start && t < dip_start + duration
        kf = kf_ss_value;
    else 
        kf = kf_value;
    end
        
end