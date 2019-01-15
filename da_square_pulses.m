function kf = da_square_pulses(t, pulse_start, duration, interval, npulses, kf_value, kf_ss_value)

    for n = 0:(npulses-1)
        if t >= pulse_start + (interval+duration)*n && t < pulse_start + duration + (interval+duration)*n
            kf = kf_value;
            break;
        else 
            kf = kf_ss_value;
        end
    end
end