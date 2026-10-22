function [Fx, e_int] = controlVelocidadSimple(v_ref, vx, e_int, dt, ctrl, p)
    % Controlador PI de velocidad 
    e = v_ref - vx; 
    % integral del error
    e_int = e_int + e*dt;
    Fx = ctrl.Kp*e + ctrl.Ki*e_int; % CONTROLADOR PI

    % Límites de saturación de mi controlador
    Fx = min(max(Fx, -p.Fx_brake_max), p.Fx_drive_max);
end