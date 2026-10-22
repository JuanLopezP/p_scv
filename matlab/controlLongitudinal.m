function [Fx, mem] = controlLongitudinal(est, ref, p, mem)
    vx = est.vx; 


    %ley ACC ---> ctrol ALTO NIVEL 
    d_des = p.d0 + p.h * vx; % distancia deseada
    e_gap = (ref.lead_X - est.X) - d_des; % error del gap/espacio entre vehículos
    
    %Modo velocidad 
    a_vel = p.Kv*(ref.v_set -vx); % controlador proporcional sencillo
    
    % Modo distancia 
    a_gap = p.Kg*e_gap + p.Kd*(ref.lead_vx - vx); % controlador PD

    % CONMUTADOR/ SELECTOR para elegir la más conservadora de las dos 

    a_des = min(a_vel,a_gap); %ME QUEDO CON LA MÁS CONSERVADORA 


    % CONTROL A BAJO NIVEL  --> de la aceleración a la fuerza

    %Fx = p.m * a_des;
    % forma más sencilla pero vamos a incluir la prealmientación 
    Fx = p.m * a_des + 0.5 * p.rho * p.Cd * p.Af * vx^2  + sign(vx)*p.fr*p.m*p.g;

    % SATURACIÓN 

    Fx = min(max(Fx,-p.Fx_brake_max),p.Fx_drive_max);

    % JERK/ TASA DE VARIACIÓN DE LA ACELERACIÓN

    dFx = p.jerk_max*p.m*p.dt;

    Fx = mem.Fx_prev + max(min(Fx - mem.Fx_prev, dFx),-dFx);
    mem.Fx_prev = Fx;


end 