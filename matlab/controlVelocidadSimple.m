function [Fx, e_int] = controlVelocidadSimple(v_ref, vx, e_int, dt, ctrl, p)
    % Controlador PI de velocidad
    ctrl.v_cru = 25; % velocidad de crucero objetivo [m/s] (90 km/h)
    ctrl.x_fren = 78; % distancia a la que se ordena frenar [m]
    ctrl.Kp = 800; % ganancia proporcional 
    ctrl.Ki = 200; % ganancia integral 
    e = v_ref - vx; 
    % integral del error
    e_int = e_int + e*dt;
    Fx = ctrl.Kp*e + ctrl.Ki*e_int; % CONTROLADOR PI

    % Límites de saturación de mi controlador
    Fx = min(max(Fx, -p.Fx_fren_max), p.Fx_trac_max);
end