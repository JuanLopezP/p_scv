function [delta, mem] = controlLateral(est, path, p, mem)
    x = est.X; y = est.Y; psi = est.psi; vx = est.vx;  % solo extraigo del estado los parámetros que necesito 
    
    L = p.ld + p.lt; % batalla del vehículo 
    Ld = p.Ld0 + p.kLd*max(vx,0); % distancia de anticipación 

    % Extraer el punto objetivo ( cruce de la distancia de anticipación y
    % la trayectoria de referencia ) 

    [tx,ty,mem.idx] = buscarPuntoAdelante(path,x, y, Ld, mem.idx); 
    %Calcular geometría 
    alpha = atan2(ty-y, tx-x) - psi; % angulo al punto objetivo 
    %añado restricciones para que no se me vaya el volante demasiado y lo
    %normalizo a -pi +pi 
    alpha = atan2(sin(alpha),cos(alpha)); %normaliza a [-pi,pi]
    delta = atan2(2*L*sin(alpha),Ld);

    delta = max(min(delta,p.delta_max),-p.delta_max);
end