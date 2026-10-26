function [Fx, e_int] = controlVelocidadSimple(v_ref, vx, e_int, dt, ctrl, p)
    % Controlador PI de velocidad 
    e = v_ref - vx; 
    % integral del error
    %Tengo que añadirle un Anti-windup --> no acumulo error mientras mi
    %motor ya está a tope dando todo lo que tiene y no puede dar más. Con
    %esto consigo que al empezar el motor a dar menos el controlador puede
    %corregir ese error pequeño de velocidad y ajustarse a la consigna de
    %forma mucho más precisa. Todo esto se traduce en que directamente
    %conseguimos no pasarnos en la frenada de la primera prueba
    %e_int = e_int + e*dt;

    Fx = ctrl.Kp*e + ctrl.Ki*e_int; % CONTROLADOR PI


    % Condición para solo actualizar el error cuando el motor no va a tope.
    if Fx > -p.Fx_brake_max && Fx < p.Fx_drive_max
        e_int = e_int + e*dt;
    end

    % Límites de saturación de mi controlador
    Fx = min(max(Fx, -p.Fx_brake_max), p.Fx_drive_max);
end