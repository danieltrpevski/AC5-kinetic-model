function kf = ach_square_dips(t, dip_start, duration, interval, ndips, kf_value, kf_ss_value)

    for n = 0:(ndips-1)
        if t >= dip_start + (interval+duration)*n && t < dip_start + duration + (interval+duration)*n
            kf = kf_ss_value;
            break;
        else 
            kf = kf_value;
        end
    end
        
end