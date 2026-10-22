function hist = simularE4(z0, p, esc, dt)
    % El ego se modela como bicicleta (P2) con delta = 0 + coche líder guionizado. 
    N = round(esc.Tmax/dt);  z = z0;
    Xl = esc.lead_X0; % posición del líder
    mem.Fx_prev = 0; % memoria del controlador
    hist.t=zeros(1,N); hist.vx=zeros(1,N); hist.vl=zeros(1,N);
    hist.Xe=zeros(1,N); hist.Xl=zeros(1,N); hist.gap=zeros(1,N);
    hist.d_des=zeros(1,N); hist.Fx=zeros(1,N);
    for k = 1:N
        t = (k-1)*dt;
        Vl = liderVel(t);  % velocidad del líder 
        Xl = Xl + Vl*dt;   % integra su posición

        % OJO! esto es una simplificación: el estado estimado es la realidad
        est.X = z(1);  est.vx = z(4);

        ref.v_set = p.v_set;  ref.lead_X = Xl;  ref.lead_vx = Vl;

        [Fx, mem] = controlLongitudinal(est, ref, p, mem);

        z = pasoDinamico(z, [Fx;0], p, dt);   % delta = 0: recta

        hist.t(k)=t; hist.vx(k)=z(4); hist.vl(k)=Vl;
        hist.Xe(k)=z(1); hist.Xl(k)=Xl; hist.gap(k)=Xl - z(1);
        hist.d_des(k)=p.d0 + p.h*z(4); hist.Fx(k)=Fx;
    end
end