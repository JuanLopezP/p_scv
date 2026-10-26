function animarE2(hist, geom, p, paso, seguir, gif, histCin)
% ANIMARE2  Animación "3D" del skidpad a partir de la salida de simularE2.
%   animarE2(histDin, geom, p)                          -> vista fija, 1 de cada 20 muestras
%   animarE2(histDin, geom, p, paso, seguir)            -> seguir = true para cámara de persecución
%   animarE2(histDin, geom, p, paso, seguir, gif)       -> gif = 'skidpad.gif' guarda un GIF (R2022a+), '' no
%   animarE2(histDin, geom, p, paso, seguir, '', histCin) -> añade el coche cinemático para comparar
%
%   Rojo = modelo dinámico (hist), azul = modelo cinemático (histCin, opcional).
%   Verde discontinuo = trayectoria ideal (círculo de radio geom.R, línea central del carril).
%   Tramos de traza más gruesos = fuera del carril.
%   Flechas sobre el coche dinámico: fuerza lateral por eje (verde = delantero, magenta = trasero),
%   recalculada como en pasoDinamico (lineal + saturación mu*Fz); punteada = eje saturado.
%   Abajo: radio respecto al centro vs carril, y a_y = v_x*r frente a la que pide el círculo
%   ideal (v_x^2/R) y al límite mu_d*g. v_x*r solo es a_y exacta en régimen estacionario.
%
%   Desde un .mlx el Live Editor captura la figura; si no se mueve, lanza la llamada desde la
%   Command Window. Se repite en bucle hasta cerrar la ventana (o Ctrl+C).
%   Ojo: la planta es plana (sin balanceo/cabeceo); esto es 2D con perspectiva.
%   Las medidas de la caja son solo visuales, no parámetros de la planta.

    if nargin < 4 || isempty(paso),   paso = 20;      end
    if nargin < 5 || isempty(seguir), seguir = false; end
    if nargin < 6, gif = ''; end
    if nargin < 7, histCin = []; end
    hayCin = ~isempty(histCin);

    cDin = [0.85 0.1 0.1];  cCin = [0.1 0.35 0.9];  cIdeal = [0 0.55 0];

    %% Escena
    fig = figure('Color','w','Name','Skidpad 3D','WindowStyle','normal','Visible','on');
    ax = axes('Parent', fig, 'Position', [0.05 0.36 0.9 0.58]); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
    xlabel(ax,'X [m]'); ylabel(ax,'Y [m]'); zlabel(ax,'Z [m]');
    Rm = geom.R_out + 3;
    axis(ax, [-Rm Rm -Rm Rm 0 4]);
    view(ax, -30, 35);
    if seguir, axis(ax,'off'); end

    patch(ax, [-Rm Rm Rm -Rm], [-Rm -Rm Rm Rm], [0 0 0 0], [0.85 0.85 0.85], 'EdgeColor','none', ...
          'HandleVisibility','off');
    th = linspace(0, 2*pi, 48);
    hIn  = scatter3(ax, geom.R_in*cos(th),  geom.R_in*sin(th),  0.05*ones(size(th)), 30, [0 0.3 0.9],  'filled');
    hOut = scatter3(ax, geom.R_out*cos(th), geom.R_out*sin(th), 0.05*ones(size(th)), 30, [0.95 0.8 0], 'filled');
    thc = linspace(0, 2*pi, 200);
    hId = plot3(ax, geom.R*cos(thc), geom.R*sin(thc), 0.02*ones(size(thc)), '--', 'Color', cIdeal, 'LineWidth', 1.5);

    % Datos por modelo
    D = prepararModelo(ax, hist, geom, p, cDin);
    if hayCin, C = prepararModelo(ax, histCin, geom, p, cCin); end

    % Flechas de fuerza lateral (solo en el dinámico: el cinemático no tiene neumáticos)
    alto = 0.5;  esc = 1/300;  zf = alto + 0.05;
    fd = line([p.ld p.ld],  [0 0], [zf zf], 'Color',[0 0.6 0],   'LineWidth', 4, 'Parent', D.tf);
    ft = line([-p.lt -p.lt], [0 0], [zf zf], 'Color',[0.8 0 0.8], 'LineWidth', 4, 'Parent', D.tf);
    L   = p.ld + p.lt;
    Fzd = p.m*p.g*p.lt/L;   Fzt = p.m*p.g*p.ld/L;

    % Leyenda (cajas falsas para que salgan con su color)
    hD = plot3(ax, NaN, NaN, NaN, 's', 'MarkerFaceColor', cDin, 'MarkerEdgeColor', cDin, 'MarkerSize', 10);
    hL = [hD, hId, hIn, hOut];  nom = {'dinámico', 'trayectoria ideal', 'conos interiores', 'conos exteriores'};
    if hayCin
        hC = plot3(ax, NaN, NaN, NaN, 's', 'MarkerFaceColor', cCin, 'MarkerEdgeColor', cCin, 'MarkerSize', 10);
        hL = [hD, hC, hL(2:end)];  nom = [nom(1), {'cinemático'}, nom(2:end)];
    end
    legend(ax, hL, nom, 'Location', 'northeastoutside', 'AutoUpdate', 'off');

    %% Gráficas en vivo
    tEnd = hist.t(end);  if hayCin, tEnd = max(tEnd, histCin.t(end)); end
    % (1) Radio respecto al centro frente al carril
    ax2 = axes('Parent', fig, 'Position', [0.07 0.06 0.4 0.22]); hold(ax2,'on'); grid(ax2,'on');
    yline(ax2, geom.R_in,  '-', 'R_{in}',  'Color', [0 0.3 0.9]);
    yline(ax2, geom.R_out, '-', 'R_{out}', 'Color', [0.9 0.7 0]);
    yline(ax2, geom.R,     '--', 'R ideal', 'Color', cIdeal);
    rads = D.rad;  if hayCin, rads = [rads C.rad]; end
    D.radV = plot(ax2, NaN, NaN, 'Color', cDin, 'LineWidth', 1.5);
    if hayCin, C.radV = plot(ax2, NaN, NaN, 'Color', cCin, 'LineWidth', 1.5); end
    xlim(ax2, [0 tEnd]);  ylim(ax2, [min([rads geom.R_in])-0.5, max([rads geom.R_out])+0.5]);
    xlabel(ax2, 't [s]'); ylabel(ax2, 'radio [m]'); title(ax2, 'Radio respecto al centro');

    % (2) Aceleración lateral
    ax3 = axes('Parent', fig, 'Position', [0.57 0.06 0.4 0.22]); hold(ax3,'on'); grid(ax3,'on');
    plot(ax3, hist.t, hist.vx.^2/geom.R, '--', 'Color', cIdeal);
    yline(ax3, p.mu_d*p.g, 'k-', '\mu_d g');
    ays = [D.ay hist.vx.^2/geom.R p.mu_d*p.g];  if hayCin, ays = [ays C.ay]; end
    D.ayV = plot(ax3, NaN, NaN, 'Color', cDin, 'LineWidth', 1.5);
    if hayCin, C.ayV = plot(ax3, NaN, NaN, 'Color', cCin, 'LineWidth', 1.5); end
    xlim(ax3, [0 tEnd]);  ylim(ax3, [0, 1.15*max(ays)]);
    xlabel(ax3, 't [s]'); ylabel(ax3, 'a_y [m/s^2]');
    title(ax3, 'a_y = v_x r  vs  necesaria v_x^2/R (verde)');

    %% Bucle
    idx = 1:paso:numel(hist.t);
    while true
    for k = idx
        if ~isvalid(fig), return; end
        actualizar(D, hist, k);
        if hayCin, actualizar(C, histCin, min(k, numel(histCin.t))); end

        Fyd = max(min(p.Cad*hist.af(k),  p.mu_d*Fzd), -p.mu_d*Fzd);
        Fyt = max(min(p.Cat*hist.ar(k),  p.mu_t*Fzt), -p.mu_t*Fzt);
        set(fd, 'YData', [0 Fyd*esc], 'LineStyle', ternario(abs(Fyd) >= 0.999*p.mu_d*Fzd, ':', '-'));
        set(ft, 'YData', [0 Fyt*esc], 'LineStyle', ternario(abs(Fyt) >= 0.999*p.mu_t*Fzt, ':', '-'));

        if seguir
            X = hist.X(k); Y = hist.Y(k); psi = hist.psi(k);
            camtarget(ax, [X Y 0.3]);
            campos(ax, [X - 15*cos(psi), Y - 15*sin(psi), 8]);
            camva(ax, 50);
        end
        txt = sprintf('t = %.2f s   v_x = %.2f m/s   radio din = %.2f m%s', ...
              hist.t(k), hist.vx(k), D.rad(k), ternario(D.fuera(k), ' ¡FUERA!', ''));
        if hayCin
            kc = min(k, numel(histCin.t));
            txt = [txt, sprintf('   cin = %.2f m%s', C.rad(kc), ternario(C.fuera(kc), ' ¡FUERA!', ''))];
        end
        title(ax, {txt, sprintf('ideal = %.2f m   F_{yd} = %.0f N   F_{yt} = %.0f N   \\beta_{din} = %.1f°', ...
              geom.R, Fyd, Fyt, atan2(hist.vy(k), hist.vx(k))*180/pi)});
        drawnow;
        if ~isempty(gif)
            exportgraphics(fig, gif, 'Append', k ~= idx(1));
        else
            pause(paso*(hist.t(2)-hist.t(1)));
        end
    end
    if ~isempty(gif) || ~isvalid(fig), return; end
    pause(1);
    end

end

function actualizar(M, h, k)
% Mueve coche, traza y curvas en vivo de un modelo al instante k.
    set(M.tf, 'Matrix', makehgtform('translate', [h.X(k) h.Y(k) 0], 'zrotate', h.psi(k)));
    set(M.traza,  'XData', h.X(1:k),     'YData', h.Y(1:k), 'ZData', 0.03*ones(1,k));
    set(M.trazaF, 'XData', M.Xout(1:k),  'YData', h.Y(1:k), 'ZData', 0.04*ones(1,k));
    set(M.radV, 'XData', h.t(1:k), 'YData', M.rad(1:k));
    set(M.ayV,  'XData', h.t(1:k), 'YData', M.ay(1:k));
end

function M = prepararModelo(ax, h, geom, p, color)
% Coche, traza y datos derivados de un modelo.
    M.rad   = hypot(h.X, h.Y);
    M.fuera = M.rad < geom.R_in | M.rad > geom.R_out;
    M.Xout  = h.X;  M.Xout(~M.fuera) = NaN;
    M.ay    = h.vx .* h.r;
    M.traza  = plot3(ax, NaN, NaN, NaN, '-', 'Color', color, 'LineWidth', 1.2, 'HandleVisibility','off');
    M.trazaF = plot3(ax, NaN, NaN, NaN, '-', 'Color', color, 'LineWidth', 4,   'HandleVisibility','off');
    ancho = 1.4; alto = 0.5;
    xs = [-(p.lt + 0.3), p.ld + 0.3];  ys = [-ancho/2, ancho/2];  zs = [0, alto];
    [Xc, Yc, Zc] = ndgrid(xs, ys, zs);
    F = [1 2 4 3; 5 6 8 7; 1 2 6 5; 3 4 8 7; 1 3 7 5; 2 4 8 6];
    M.tf = hgtransform('Parent', ax);
    patch('Vertices', [Xc(:) Yc(:) Zc(:)], 'Faces', F, 'FaceColor', color, 'FaceAlpha', 0.8, 'Parent', M.tf);
    line([p.ld+0.3, p.ld+1.0], [0 0], [alto alto], 'Color','k', 'LineWidth', 3, 'Parent', M.tf);
    M.radV = [];  M.ayV = [];
end

function out = ternario(c, a, b)
    if c, out = a; else, out = b; end
end
