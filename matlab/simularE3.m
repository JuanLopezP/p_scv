function hist = simularE3(z0, p, centro, dt) %Autocross
    z = z0;  N = size(centro,1);
    mem_lat.idx = 1;  e_int = 0;
    Nmax = 60000;                         
    t=zeros(1,Nmax); X=zeros(1,Nmax); Y=zeros(1,Nmax); PSI=zeros(1,Nmax);
    VX=zeros(1,Nmax); ECT=zeros(1,Nmax);
    vuelta_ini = false;  k_fin = Nmax;
    ctrl.Kp = p.Kp_v;  ctrl.Ki = p.Ki_v;   % ganancias del PI de la P4
    for k = 1:Nmax
        est.X=z(1); est.Y=z(2); est.psi=z(3); est.vx=z(4); est.vy=z(5); est.r=z(6);
        % Control lateral (Pure Pursuit)
        [delta, mem_lat] = controlLateral(est, centro, p, mem_lat);
        % Control longitudinal (velocidad objetivo, PI simple)
        [Fx, e_int] = controlVelocidadSimple(p.v_set, z(4), e_int, dt, ctrl, p);
        % Planta (bicicleta dinámica de L2)
        z = pasoDinamico(z, [Fx; delta], p, dt);
        % Registro + error lateral
        t(k)=(k-1)*dt; X(k)=z(1); Y(k)=z(2); PSI(k)=z(3); VX(k)=z(4);
        ECT(k) = errorLateral(z(1), z(2), centro);
        % ¿Vuelta completa? (se aleja del inicio y luego vuelve)
        d_ini = hypot(z(1)-centro(1,1), z(2)-centro(1,2));
        if ~vuelta_ini && d_ini > 10, vuelta_ini = true; end
        if vuelta_ini && d_ini < 2 && k > 100, k_fin = k; break; end
    end
    f=1:k_fin;
    hist.t=t(f); hist.X=X(f); hist.Y=Y(f); hist.psi=PSI(f); hist.vx=VX(f); hist.ect=ECT(f);
end