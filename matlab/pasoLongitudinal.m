function z_next = pasoLongitudinal(z, u, p, dt)
    Fx = u; 
    vx = z(2);

    % Resistencias
    Ra = 0.5*p.rho*p.Cd*p.Af*vx^2; % resistencia aerodinámica
    Rr = p.fr*p.m*p.g*cos(p.theta); % rodadura
    Rg = p.m*p.g*sin(p.theta); % gravitatoria

    % Aceleración 
    ax = (Fx - Ra - sign(vx)*Rr - Rg)/p.m;

    % Velocidad
    vx_next = max(vx + ax*dt,0); % velocidad en el siguiente instante de tiempo
    x_next = z(1)+vx*dt; 
    z_next = z;
    z_next(1) = x_next; 
    z_next(2) = vx_next; 
end