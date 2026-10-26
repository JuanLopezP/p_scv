function animarE4(hist, p, paso, seguir, gif)
% ANIMARE4  Animación "3D" del ACC con coche líder (salida de simularE4).
%   animarE4(hist, p)                 -> cámara de persecución, 1 de cada 25 muestras
%   animarE4(hist, p, paso, seguir)   -> seguir = false para vista fija de toda la recta
%   animarE4(hist, p, paso, seguir, 'acc.gif') -> además guarda un GIF (R2022a+)
%
%   Gris = ego (tu coche), azul = líder. Verde translúcido = dónde "debería" estar el ego según
%   la política de separación de tu ACC: X_lider - d_des, con d_des = d0 + h*v_ego (hist.d_des).
%   Es una referencia derivada de tus propios parámetros, no un resultado del profesor.
%   Línea entre ego y líder: verde si gap >= d_des, naranja si d0 <= gap < d_des, roja si gap < d0.
%   Ojo: hist.gap es distancia entre CG (X_lider - X_ego), no entre parachoques.
%   Abajo: velocidades (ego, líder, v_set) y separación real vs deseada y d0.
%   Llama a esta función justo después de simularE4 (E1 también usa 'hist').
%   Se repite en bucle hasta cerrar la ventana (o Ctrl+C).
%   Las medidas de las cajas son solo visuales, no parámetros de la planta.

    if nargin < 3 || isempty(paso),   paso = 25;     end
    if nargin < 4 || isempty(seguir), seguir = true; end
    if nargin < 5, gif = ''; end

    cEgo = [0.3 0.3 0.3];  cLid = [0.1 0.3 0.9];  cIdeal = [0 0.6 0];   % gris oscuro: así resalta la luz de freno roja
    largo = p.ld + p.lt + 0.6;                 % largo visual de la caja (parachoques a parachoques)
    Xdes = hist.Xl - hist.d_des;               % posición deseada del ego

    %% Escena
    fig = figure('Color','w','Name','ACC 3D','WindowStyle','normal','Visible','on');
    ax = axes('Parent', fig, 'Position', [0.05 0.38 0.9 0.56]); hold(ax,'on'); axis(ax,'equal');
    Xmax = max(hist.Xl) + 20;
    W = 6;
    axis(ax, [-10 Xmax -W W 0 4]);
    if seguir, axis(ax,'off'); else, view(ax, -20, 25); grid(ax,'on'); xlabel(ax,'X [m]'); end

    patch(ax, [-10 Xmax Xmax -10], [-W -W W W], [0 0 0 0], [0.85 0.85 0.85], 'EdgeColor','none', ...
          'HandleVisibility','off');
    xm = 0:10:Xmax;
    scatter3(ax, xm,  2.5*ones(size(xm)), 0.05*ones(size(xm)), 30, [0 0.3 0.9],  'filled', 'HandleVisibility','off');
    scatter3(ax, xm, -2.5*ones(size(xm)), 0.05*ones(size(xm)), 30, [0.95 0.8 0], 'filled', 'HandleVisibility','off');
    for xt = 0:20:Xmax
        text(ax, xt, 3.3, 0.1, sprintf('%d m', xt), 'FontSize', 8, 'HorizontalAlignment','center');
    end

    [tfI, ~]    = crearCoche(ax, p, cIdeal, 0.3);
    [tfE, luzE] = crearCoche(ax, p, cEgo,   0.85);
    [tfL, luzL] = crearCoche(ax, p, cLid,   0.85);
    gapLin = line(ax, [0 0], [0 0], [0.8 0.8], 'LineWidth', 3, 'HandleVisibility','off');
    hE = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', cEgo,   'MarkerEdgeColor', cEgo,   'MarkerSize', 10);
    hL = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', cLid,   'MarkerEdgeColor', cLid,   'MarkerSize', 10);
    hI = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', cIdeal, 'MarkerEdgeColor', cIdeal, 'MarkerSize', 10);
    h1 = plot3(ax, NaN,NaN,NaN, '-', 'Color', [0 0.6 0], 'LineWidth', 3);
    h2 = plot3(ax, NaN,NaN,NaN, '-', 'Color', [1 0.5 0], 'LineWidth', 3);
    h3 = plot3(ax, NaN,NaN,NaN, '-', 'Color', [0.9 0 0], 'LineWidth', 3);
    legend(ax, [hE hL hI h1 h2 h3], {'ego (tu ACC)', 'líder', 'ego ideal (X_l - d_{des})', ...
           'gap \geq d_{des}', 'd_0 \leq gap < d_{des}', 'gap < d_0'}, ...
           'Location','northeastoutside', 'AutoUpdate','off');

    %% Gráfica 1: velocidades
    ax2 = axes('Parent', fig, 'Position', [0.07 0.07 0.4 0.23]); hold(ax2,'on'); grid(ax2,'on');
    plot(ax2, hist.t, hist.vl*3.6, '--', 'Color', cLid, 'LineWidth', 1.2);
    yline(ax2, p.v_set*3.6, 'k:', 'v_{set}');
    plot(ax2, hist.t, hist.vx*3.6, 'Color', [0.85 0.85 0.85]);
    vE = plot(ax2, NaN, NaN, 'Color', cEgo, 'LineWidth', 1.5);
    xlim(ax2, [0 hist.t(end)]);  ylim(ax2, [0 1.15*max([hist.vx hist.vl p.v_set])*3.6]);
    xlabel(ax2, 't [s]');  ylabel(ax2, 'v [km/h]');  title(ax2, 'Ego (gris) vs líder (azul)');

    %% Gráfica 2: separación
    ax3 = axes('Parent', fig, 'Position', [0.57 0.07 0.4 0.23]); hold(ax3,'on'); grid(ax3,'on');
    plot(ax3, hist.t, hist.d_des, '--', 'Color', cIdeal, 'LineWidth', 1.2);
    yline(ax3, p.d0, 'r-', 'd_0');
    yline(ax3, largo, 'k:', 'contacto');
    plot(ax3, hist.t, hist.gap, 'Color', [0.85 0.85 0.85]);
    gE = plot(ax3, NaN, NaN, 'Color', cEgo, 'LineWidth', 1.5);
    gP = plot(ax3, NaN, NaN, 'o', 'Color', cEgo, 'MarkerFaceColor', cEgo);
    xlim(ax3, [0 hist.t(end)]);  ylim(ax3, [min([0 hist.gap]), 1.15*max([hist.gap hist.d_des])]);
    xlabel(ax3, 't [s]');  ylabel(ax3, 'gap [m]');  title(ax3, 'Separación real vs deseada (verde)');

    %% Bucle
    idx = unique([1:paso:numel(hist.t), numel(hist.t)]);
    while true
    for k = idx
        if ~isvalid(fig), return; end
        Xe = hist.Xe(k);  Xl = hist.Xl(k);  g = hist.gap(k);
        set(tfE, 'Matrix', makehgtform('translate', [Xe 0 0]));
        set(tfL, 'Matrix', makehgtform('translate', [Xl 0 0]));
        set(tfI, 'Matrix', makehgtform('translate', [Xdes(k) -1.8 0]));   % carril de al lado
        set(luzE, 'Visible', ternario(hist.Fx(k) < 0, 'on', 'off'));
        if k > 1, set(luzL, 'Visible', ternario(hist.vl(k) < hist.vl(max(k-1,1)) - 1e-9, 'on', 'off')); end

        if g < p.d0,              c = [0.9 0 0];  aviso = '   ¡DEMASIADO CERCA! (gap < d_0)';
        elseif g < hist.d_des(k), c = [1 0.5 0];  aviso = '   gap < d_{des}';
        else,                     c = [0 0.6 0];  aviso = '';
        end
        if g < largo, aviso = '   ¡COLISIÓN!'; end
        set(gapLin, 'XData', [Xe+p.ld+0.3, Xl-p.lt-0.3], 'Color', c);

        set(vE, 'XData', hist.t(1:k), 'YData', hist.vx(1:k)*3.6);
        set(gE, 'XData', hist.t(1:k), 'YData', hist.gap(1:k));
        set(gP, 'XData', hist.t(k),   'YData', g, 'MarkerFaceColor', c);

        if seguir
            camtarget(ax, [(Xe+Xl)/2 0 0.3]);
            campos(ax, [Xe-15, -9, 6]);
            camva(ax, 45);
        end
        title(ax, {sprintf('t = %.1f s   ego %.0f km/h   líder %.0f km/h   F_x = %.0f N%s', ...
                   hist.t(k), hist.vx(k)*3.6, hist.vl(k)*3.6, hist.Fx(k), aviso), ...
                   sprintf('gap = %.1f m   deseada = %.1f m   error = %+.1f m', ...
                   g, hist.d_des(k), g - hist.d_des(k))});
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
