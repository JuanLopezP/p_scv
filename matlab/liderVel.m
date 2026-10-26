function Vl = liderVel(t)
% Perfil de velocidad del líder: acelera, crucero, frena.
    v_cru = 18; % 65 km/s
    if t < 8
        Vl = min(v_cru, 2.5*t);            % acelera
    elseif t < 14
        Vl = v_cru;                              % crucero
    else
        Vl = max(0, v_cru - 10*(t-14));          % frenazo a 10 m/s² hasta parar
end
