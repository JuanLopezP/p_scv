function animarE1(hist, p, ctrl, paso, seguir, gif)
% ANIMARE1  Animación "3D" de la prueba de aceleración y frenada (salida de simularE1).
%   animarE1(hist, p, ctrl)                 -> cámara de persecución, 1 de cada 10 muestras
%   animarE1(hist, p, ctrl, paso, seguir)   -> seguir = false para vista fija de toda la recta
%   animarE1(hist, p, ctrl, paso, seguir, 'acel.gif') -> además guarda un GIF (R2022a+)
%
%   Gris = tu simulación (hist). Verde translúcido = coche de referencia "ideal" calculado aquí:
%     acelera a tope (Fx_drive_max, limitado por agarre), mantiene ctrl.v_cru y frena a tope de
%     agarre justo a tiempo para parar en p.x_box. Usa las mismas resistencias que pasoDinamico.
%     Es una referencia de diseño (opinión), no un resultado del profesor.
%   Líneas en el suelo: verde = salida, negra = meta (x_meta), naranja = orden de frenada
%   (x_fren), roja = fin de la caja (x_box). Luz trasera = frenando (Fx < 0).
%   Abajo: v(x) real vs ideal (la curva verde es la frontera de frenada: si la roja va por
%   encima, ya no se puede parar antes de x_box) y Fx(t) frente a sus límites.
%   Ojo: hist.Fx es la salida del controlador; la planta la recorta luego al agarre.
%   Llama a esta función justo después de simularE1 (E4 también usa 'hist').
%   Se repite en bucle hasta cerrar la ventana (o Ctrl+C).
%   Las medidas de la caja del coche son solo visuales, no parámetros de la planta.

    if nargin < 4 || isempty(paso),   paso = 10;     end
    if nargin < 5 || isempty(seguir), seguir = true; end
    if nargin < 6, gif = ''; end

    cReal = [0.3 0.3 0.3];  cIdeal = [0 0.6 0];   % gris oscuro: así resalta la luz de freno roja
    dt = hist.t(2) - hist.t(1);
    id = perfilIdeal(p, ctrl, dt);
    L = p.ld + p.lt;
    FxAgarre = p.mu_d*p.m*p.g*p.lt/L + p.mu_t*p.m*p.g*p.ld/L;   % mismo límite que pasoDinamico

    %% Escena
    fig = figure('Color','w','Name','Aceleración 3D','WindowStyle','normal','Visible','on');
    ax = axes('Parent', fig, 'Position', [0.05 0.38 0.9 0.56]); hold(ax,'on'); axis(ax,'equal');
    Xmax = max([p.x_box, max(hist.x)]) + 15;
    W = 6;
    axis(ax, [-10 Xmax -W W 0 4]);
    if seguir, axis(ax,'off'); else, view(ax, -20, 25); grid(ax,'on'); xlabel(ax,'X [m]'); end

    patch(ax, [-10 Xmax Xmax -10], [-W -W W W], [0 0 0 0], [0.85 0.85 0.85], 'EdgeColor','none', ...
          'HandleVisibility','off');
    xc = 0:5:Xmax;
    scatter3(ax, xc,  2.5*ones(size(xc)), 0.05*ones(size(xc)), 30, [0 0.3 0.9],  'filled', 'HandleVisibility','off');
    scatter3(ax, xc, -2.5*ones(size(xc)), 0.05*ones(size(xc)), 30, [0.95 0.8 0], 'filled', 'HandleVisibility','off');
    for xt = 0:10:Xmax
        text(ax, xt, 3.3, 0.1, sprintf('%d m', xt), 'FontSize', 8, 'HorizontalAlignment','center');
    end
    hS = lineaSuelo(ax, 0,           [0 0.6 0]);
    hM = lineaSuelo(ax, p.x_meta,    [0 0 0]);
    hF = lineaSuelo(ax, ctrl.x_fren, [1 0.5 0]);
    hB = lineaSuelo(ax, p.x_box,     [0.8 0 0]);
    patch(ax, [p.x_meta p.x_box p.x_box p.x_meta], [-3 -3 3 3], 0.01*[1 1 1 1], [1 0.85 0.85], ...
          'EdgeColor','none', 'FaceAlpha', 0.5, 'HandleVisibility','off');   % caja de frenada

    % Coches: el ideal desplazado en y para que no se solapen
    [tfR, luzR] = crearCoche(ax, p, cReal,  0.85);
    [tfI, luzI] = crearCoche(ax, p, cIdeal, 0.35);
    hR = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', cReal,  'MarkerEdgeColor', cReal,  'MarkerSize', 10);
    hI = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', cIdeal, 'MarkerEdgeColor', cIdeal, 'MarkerSize', 10);
    legend(ax, [hR hI hS hM hF hB], {'tu simulación', 'referencia ideal', 'salida', ...
           sprintf('meta (%g m)', p.x_meta), sprintf('frenada (%g m)', ctrl.x_fren), ...
           sprintf('fin caja (%g m)', p.x_box)}, 'Location','northeastoutside', 'AutoUpdate','off');
    yI = -1.8;  yR = 0;                                   % carriles visuales

    %% Gráfica 1: v(x)
    ax2 = axes('Parent', fig, 'Position', [0.07 0.07 0.4 0.23]); hold(ax2,'on'); grid(ax2,'on');
    plot(ax2, id.x, id.v*3.6, '--', 'Color', cIdeal, 'LineWidth', 1.2);
    plot(ax2, hist.x, hist.vx*3.6, 'Color', [0.85 0.85 0.85]);
    xline(ax2, p.x_meta, 'k-');  xline(ax2, ctrl.x_fren, '-', 'Color', [1 0.5 0]);  xline(ax2, p.x_box, 'r-');
    yline(ax2, ctrl.v_cru*3.6, 'k:', 'v_{cru}');
    vR = plot(ax2, NaN, NaN, 'Color', cReal, 'LineWidth', 1.5);
    pR = plot(ax2, NaN, NaN, 'o', 'Color', cReal, 'MarkerFaceColor', cReal);
    xlim(ax2, [0 Xmax]);  ylim(ax2, [0 max([hist.vx id.v])*3.6*1.15]);
    xlabel(ax2, 'x [m]');  ylabel(ax2, 'v [km/h]');  title(ax2, 'v(x): real (gris) vs ideal (verde)');

    %% Gráfica 2: Fx(t) y límites
    ax3 = axes('Parent', fig, 'Position', [0.57 0.07 0.4 0.23]); hold(ax3,'on'); grid(ax3,'on');
    plot(ax3, id.t, id.Fx, '--', 'Color', cIdeal, 'LineWidth', 1.2);
    yline(ax3,  p.Fx_drive_max, 'b:', 'motor');   yline(ax3, -p.Fx_brake_max, 'm:', 'freno');
    yline(ax3,  FxAgarre, 'k-', 'agarre');        yline(ax3, -FxAgarre, 'k-', 'agarre');
    fR = plot(ax3, NaN, NaN, 'Color', cReal, 'LineWidth', 1.5);
    xlim(ax3, [0 max(hist.t(end), id.t(end))]);
    ylim(ax3, 1.15*[-max(p.Fx_brake_max, FxAgarre), max(p.Fx_drive_max, FxAgarre)]);
    xlabel(ax3, 't [s]');  ylabel(ax3, 'F_x [N]');  title(ax3, 'F_x pedida (gris) vs límites');

    %% Bucle
    n = max(numel(hist.t), numel(id.t));
    idx = unique([1:paso:n, n]);
    while true
    for k = idx
        if ~isvalid(fig), return; end
        kr = min(k, numel(hist.t));  ki = min(k, numel(id.t));
        X = hist.x(kr);  XI = id.x(ki);
        set(tfR, 'Matrix', makehgtform('translate', [X yR 0]));
        set(tfI, 'Matrix', makehgtform('translate', [XI yI 0]));
        set(luzR, 'Visible', ternario(hist.Fx(kr) < 0, 'on', 'off'));
        set(luzI, 'Visible', ternario(id.Fx(ki) < 0, 'on', 'off'));
        set(vR, 'XData', hist.x(1:kr), 'YData', hist.vx(1:kr)*3.6);
        set(pR, 'XData', X, 'YData', hist.vx(kr)*3.6);
        set(fR, 'XData', hist.t(1:kr), 'YData', hist.Fx(1:kr));
        if seguir
            camtarget(ax, [X+3 0 0.3]);
            campos(ax, [X-12, -7, 5]);
            camva(ax, 45);
        end
        aviso = '';
        if X > p.x_box, aviso = sprintf('   ¡FUERA DE CAJA! (+%.1f m)', X - p.x_box); end
        title(ax, {sprintf('t = %.2f s   x = %.1f m   v_x = %.0f km/h   F_x = %.0f N%s', ...
                   hist.t(kr), X, hist.vx(kr)*3.6, hist.Fx(kr), aviso), ...
                   sprintf('ideal: x = %.1f m   v = %.0f km/h   (para en %.1f m)', ...
                   XI, id.v(ki)*3.6, id.x(end))});
        drawnow;
        if ~isempty(gif)
            exportgraphics(fig, gif, 'Append', k ~= idx(1));
        else
            pause(paso*dt);
        end
    end
    if ~isempty(gif) || ~isvalid(fig), return; end
    pause(1);
    end
end

function id = perfilIdeal(p, ctrl, dt)
% Referencia ideal: acelera a tope, crucero a v_cru y frena a tope de agarre justo a tiempo
% para parar en x_box. Misma física longitudinal que pasoDinamico (aero + rodadura).
    L = p.ld + p.lt;
    FxAg = p.mu_d*p.m*p.g*p.lt/L + p.mu_t*p.m*p.g*p.ld/L;
    Fmot = min(p.Fx_drive_max, FxAg);  Ffre = min(p.Fx_brake_max, FxAg);
    Rr = p.fr*p.m*p.g*cos(p.theta);
    aFre = (Ffre + Rr)/p.m;                 % deceleración garantizada (sin contar el aero)
    x = 0; v = 0; t = 0; frenando = false;
    N = round(60/dt);  id.t = zeros(1,N); id.x = id.t; id.v = id.t; id.Fx = id.t;
    for k = 1:N
        Ra = 0.5*p.rho*p.Cd*p.Af*v^2;
        if ~frenando && v^2/(2*aFre) >= p.x_box - x, frenando = true; end
        if frenando,                 F = -Ffre;
        elseif v < ctrl.v_cru,       F = Fmot;
        else,                        F = Ra + Rr;          % mantener crucero
        end
        a = (F - Ra - (v > 0)*Rr)/p.m;
        id.t(k) = t; id.x(k) = x; id.v(k) = v; id.Fx(k) = F;
        x = x + v*dt;  v = max(v + a*dt, 0);  t = t + dt;
        if frenando && v <= 0.05, break; end
    end
    f = 1:k;  id.t = id.t(f); id.x = id.x(f); id.v = id.v(f); id.Fx = id.Fx(f);
end

function h = lineaSuelo(ax, x, c)
    h = line(ax, [x x], [-3 3], [0.03 0.03], 'Color', c, 'LineWidth', 3);
end

function [tf, luz] = crearCoche(ax, p, color, alfa)
% Caja en ejes del vehículo, origen en el CG, x hacia delante.
    ancho = 1.4; alto = 0.5;
    xs = [-(p.lt + 0.3), p.ld + 0.3];  ys = [-ancho/2, ancho/2];  zs = [0, alto];
    [Xc, Yc, Zc] = ndgrid(xs, ys, zs);
    F = [1 2 4 3; 5 6 8 7; 1 2 6 5; 3 4 8 7; 1 3 7 5; 2 4 8 6];
    tf = hgtransform('Parent', ax);
    patch('Vertices', [Xc(:) Yc(:) Zc(:)], 'Faces', F, 'FaceColor', color, 'FaceAlpha', alfa, 'Parent', tf);
    line([p.ld+0.3, p.ld+1.0], [0 0], [alto alto], 'Color','k', 'LineWidth', 3, 'Parent', tf);
    xb = xs(1) - 0.02;
    luz = patch([xb xb xb xb], [-0.7 0.7 0.7 -0.7], [0.1 0.1 alto+0.35 alto+0.35], [1 0 0], ...
                'EdgeColor',[1 0.9 0.9], 'LineWidth', 2, 'Parent', tf, 'Visible','off');   % sobresale para verse desde arriba
end

function out = ternario(c, a, b)
    if c, out = a; else, out = b; end
end
