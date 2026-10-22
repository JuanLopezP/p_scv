% [CAMBIO] Copiado tal cual de P2 (lo usa simularE2 con @pasoCinematico)
function z_next = pasoCinematico(z, u, p, dt)
    % Entradas
    Fx = u(1);
    delta = u(2);
    % Estados
    X = z(1); 
    Y = z(2);
    psi = z(3);
    vx = z(4);
    %Longitud entre ejes delantero y trasero
    L = p.ld + p.lt;
 
    % Dinámica longitudinal (P1)
    Ra = 0.5*p.rho*p.Cd*p.Af*vx^2; 
    Rr = p.fr*p.m*p.g*cos(p.theta);
    Rg = p.m*p.g*sin(p.theta);
    ax = (Fx - Ra - sign(vx)*Rr - Rg)/p.m; % ecuación del movimiento longitudinal
    vx_next = max(vx + ax*dt,0);
 
    %% Dinámica lateral [cinemático]
    beta = atan((p.lt/L)*tan(delta)); % ángulo de deriva cinemática
    r = (vx/p.lt)*tan(beta);
    vy = vx*tan(beta);
 
    % cambio al sistema global
    X_next = X + (vx*cos(psi)-vy*sin(psi))*dt;
    Y_next = Y + (vx*sin(psi)+vy*cos(psi))*dt;
    psi_next = psi + r*dt; % integración del rumbo (psi) con la velocidad angular de guiñada.
 
    z_next = [X_next; Y_next; psi_next; vx_next; vy; r]; % vector de estados en el siguiente paso temporal
 
end
 