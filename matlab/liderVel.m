function Vl = liderVel(t)
% Perfil de velocidad del líder: acelera, crucero, frena.
    v_cru = 18; % 65 km/s
    if t < 8
        Vl = min(v_cru, 2.5*t);            % acelera
    elseif t < 14
        Vl = v_cru;                        % crucero
    else
        Vl = max(8, v_cru - 3*(t-14));     % frena a 8 m/s (30 km/s)
    end
end