%% SIMULADOR DE PRUEBA ACELERACIÓN Y FRENADA [NO MODIFICAR]
% [CAMBIO] Adaptado del simulador de P1 para usar la planta pasoDinamico:
%   - estado de 6 componentes: posición = z(1), velocidad = z(4)
%   - mando u = [Fx; 0] (delta = 0, recta)
%   - controlador PI renombrado a controlVelocidadSimple
function [hist, t_evento] = simularE1(z0, p, ctrl, dt, Tmax)
    N = round(Tmax/dt);
    z = z0;
    hist.t  = zeros(1,N); hist.x  = zeros(1,N); hist.vx = zeros(1,N);
    hist.Fx = zeros(1,N); hist.vr = zeros(1,N);
    e_int = 0;  cruzada = false;  t_evento = NaN;  k_fin = N;
    for k = 1:N
        t = (k-1)*dt;
        if z(1) < ctrl.x_fren,  v_ref = ctrl.v_cru;  else,  v_ref = 0;  end
        [Fx, e_int] = controlVelocidadSimple(v_ref, z(4), e_int, dt, ctrl, p);  % [CAMBIO] z(2) -> z(4)
        z = pasoDinamico(z, [Fx; 0], p, dt);   % [CAMBIO] antes pasoLongitudinal(z, Fx, p, dt)
        hist.t(k)=t; hist.x(k)=z(1); hist.vx(k)=z(4); hist.Fx(k)=Fx; hist.vr(k)=v_ref;  % [CAMBIO] z(2) -> z(4)
        if ~cruzada && z(1) >= p.x_meta,  cruzada = true;  t_evento = t;  end
        if cruzada && z(4) <= 0.05,  k_fin = k;  break;  end  % [CAMBIO] z(2) -> z(4)
    end
    f = 1:k_fin;
    hist.t=hist.t(f); hist.x=hist.x(f); hist.vx=hist.vx(f);
    hist.Fx=hist.Fx(f); hist.vr=hist.vr(f);
end
 