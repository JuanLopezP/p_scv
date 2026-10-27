function animarE3(hist, centro, cono_izq, cono_der, p, varargin)
% ANIMARE3  Animación "3D" del Autocross (P4, Pure Pursuit) a partir de la salida de simularE3.
%   animarE3(hist, centro, cono_izq, cono_der, p)
%   animarE3(..., 'Ld', 4)            -> dibuja el punto objetivo a 4 m (look-ahead)
%   animarE3(..., 'hist2', hist11)    -> añade un segundo coche (p. ej. otra velocidad) para comparar
%   animarE3(..., 'seguir', true)     -> cámara de persecución (por defecto, vista de toda la pista)
%   animarE3(..., 'paso', 25)         -> submuestreo (por defecto 25 muestras por fotograma)
%   animarE3(..., 'gif', 'ax.gif')    -> guarda un GIF de una pasada (R2022a+)
%   animarE3(..., 'nombres', {'8 m/s','11 m/s'}) -> textos de la leyenda
%   animarE3(..., 'video', 'pp_8ms.mp4')  -> graba un MP4 (una pasada, a tiempo real) y cierra
%   animarE3(..., 'fps', 30)              -> fotogramas por segundo del vídeo (ajusta el submuestreo)
%
%   Usa: hist.t, hist.X, hist.Y, hist.psi, hist.vx, hist.ect (salida de simularE3 de la P4).
%   Gris = hist, azul = hist2. Verde discontinuo = línea central (referencia).
%   Tramos de traza más gruesos = fuera de conos (|e_ct| > medio ancho de pista).
%   Punto objetivo: se RECALCULA aquí como el primer punto de 'centro', por delante del más
%   cercano, a distancia >= Ld del CG. Si tu controlLateral lo elige de otra forma (Ld = k*v,
%   desde el eje trasero...), el punto dibujado es solo aproximado.
%   Gráficas: e_ct(t) frente a los límites de la pista, y a_y = v_x*r (r derivada de psi)
%   frente a mu_d*g. v_x*r solo es a_y exacta en régimen estacionario.
%   Se repite en bucle hasta cerrar la ventana (o Ctrl+C). Desde un .mlx, si no se mueve,
%   lánzalo desde la Command Window.
%   Las medidas de la caja del coche son solo visuales, no parámetros de la planta.

    op = struct('Ld', [], 'hist2', [], 'seguir', false, 'paso', 25, 'gif', '', 'video', '', 'fps', 30, ...
                'nombres', {{'simulación 1', 'simulación 2'}});
    for i = 1:2:numel(varargin), op.(varargin{i}) = varargin{i+1}; end
    hay2 = ~isempty(op.hist2);
    c1 = [0.3 0.3 0.3];  c2 = [0.1 0.35 0.9];  cRef = [0 0.6 0];
    semi = hypot(cono_izq(1,1)-centro(1,1), cono_izq(1,2)-centro(1,2));   % medio ancho de pista

    %% Escena
    fig = figure('Color','w','Name','Autocross 3D','WindowStyle','normal','Visible','on');
    vid = [];
    if ~isempty(op.video)
        dt0 = hist.t(2) - hist.t(1);
        op.paso = max(1, round(1/(op.fps*dt0)));        % tiempo real: un fotograma cada 1/fps s
        set(fig, 'Units','pixels', 'Position', [50 50 1280 720], 'Resize','off');   % 720p fijo
        [~,~,ext] = fileparts(op.video);
        if strcmpi(ext, '.avi'), perfil = 'Motion JPEG AVI'; else, perfil = 'MPEG-4'; end
        vid = VideoWriter(op.video, perfil);
        vid.FrameRate = 1/(op.paso*dt0);
        if strcmp(perfil, 'MPEG-4'), vid.Quality = 95; end
        open(vid);
    end
    ax = axes('Parent', fig, 'Position', [0.05 0.36 0.9 0.58]); hold(ax,'on'); axis(ax,'equal');
    xr = [min([cono_izq(:,1); cono_der(:,1)]) max([cono_izq(:,1); cono_der(:,1)])] + [-5 5];
    yr = [min([cono_izq(:,2); cono_der(:,2)]) max([cono_izq(:,2); cono_der(:,2)])] + [-5 5];
    axis(ax, [xr yr 0 4]);
    if op.seguir, axis(ax,'off'); else, view(ax, -20, 55); grid(ax,'on'); xlabel(ax,'X [m]'); ylabel(ax,'Y [m]'); end

    patch(ax, xr([1 2 2 1]), yr([1 1 2 2]), [0 0 0 0], [0.85 0.85 0.85], 'EdgeColor','none', 'HandleVisibility','off');
    hI = scatter3(ax, cono_izq(:,1), cono_izq(:,2), 0.05*ones(size(cono_izq,1),1), 15, [0 0.3 0.9],  'filled');
    hD = scatter3(ax, cono_der(:,1), cono_der(:,2), 0.05*ones(size(cono_der,1),1), 15, [0.95 0.8 0], 'filled');
    cc = [centro; centro(1,:)];
    hR = plot3(ax, cc(:,1), cc(:,2), 0.02*ones(size(cc,1),1), '--', 'Color', cRef, 'LineWidth', 1.2);

    M1 = prepararModelo(ax, hist, p, c1, semi);
    if hay2, M2 = prepararModelo(ax, op.hist2, p, c2, semi); end

    % Punto objetivo (solo para hist)
    if ~isempty(op.Ld)
        hObj  = plot3(ax, NaN, NaN, NaN, 'o', 'MarkerSize', 9, 'MarkerFaceColor', [1 0.4 0], 'MarkerEdgeColor', 'k');
        hRayo = plot3(ax, NaN, NaN, NaN, '-', 'Color', [1 0.4 0], 'LineWidth', 1.5, 'HandleVisibility','off');
    end

    % Leyenda
    h1 = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', c1, 'MarkerEdgeColor', c1, 'MarkerSize', 10);
    hL = h1;  nom = op.nombres(1);
    if hay2
        h2 = plot3(ax, NaN,NaN,NaN, 's', 'MarkerFaceColor', c2, 'MarkerEdgeColor', c2, 'MarkerSize', 10);
        hL = [hL h2];  nom = [nom op.nombres(2)];
    end
    hL = [hL hR hI hD];  nom = [nom {'línea central', 'conos izq', 'conos der'}];
    if ~isempty(op.Ld), hL = [hL hObj]; nom = [nom {sprintf('punto objetivo (L_d = %g m)', op.Ld)}]; end
    legend(ax, hL, nom, 'Location','northeastoutside', 'AutoUpdate','off');

    %% Gráficas en vivo
    tEnd = hist.t(end);  if hay2, tEnd = max(tEnd, op.hist2.t(end)); end
    ax2 = axes('Parent', fig, 'Position', [0.07 0.06 0.4 0.22]); hold(ax2,'on'); grid(ax2,'on');
    yline(ax2,  semi, 'r-', 'cono');  yline(ax2, -semi, 'r-', 'cono');  yline(ax2, 0, '--', 'Color', cRef);
    es = M1.ect;  if hay2, es = [es M2.ect]; end
    M1.eV = plot(ax2, NaN, NaN, 'Color', c1, 'LineWidth', 1.5);
    if hay2, M2.eV = plot(ax2, NaN, NaN, 'Color', c2, 'LineWidth', 1.5); end
    xlim(ax2, [0 tEnd]);  ylim(ax2, 1.15*max([abs(es) semi])*[-1 1]);
    xlabel(ax2, 't [s]');  ylabel(ax2, 'e_{ct} [m]');  title(ax2, 'Error lateral (cross-track)');

    ax3 = axes('Parent', fig, 'Position', [0.57 0.06 0.4 0.22]); hold(ax3,'on'); grid(ax3,'on');
    yline(ax3, p.mu_d*p.g, 'k-', '\mu_d g');  yline(ax3, -p.mu_d*p.g, 'k-', '\mu_d g');
    as = M1.ay;  if hay2, as = [as M2.ay]; end
    M1.aV = plot(ax3, NaN, NaN, 'Color', c1, 'LineWidth', 1.5);
    if hay2, M2.aV = plot(ax3, NaN, NaN, 'Color', c2, 'LineWidth', 1.5); end
    xlim(ax3, [0 tEnd]);  ylim(ax3, 1.15*max([abs(as) p.mu_d*p.g])*[-1 1]);
    xlabel(ax3, 't [s]');  ylabel(ax3, 'a_y [m/s^2]');  title(ax3, 'a_y = v_x r  vs  límite de agarre');

    %% Bucle (mismo dt en las dos simulaciones: se sincronizan por índice)
    n = numel(hist.t);  if hay2, n = max(n, numel(op.hist2.t)); end
    idx = unique([1:op.paso:n, n]);
    dt = hist.t(2) - hist.t(1);
    while true
    for k = idx
        if ~isvalid(fig), return; end
        k1 = min(k, numel(hist.t));
        actualizar(M1, hist, k1);
        txt = sprintf('t = %.1f s   %s: v = %.1f m/s   e_{ct} = %+.2f m%s', hist.t(k1), op.nombres{1}, ...
              hist.vx(k1), M1.ect(k1), ternario(M1.fuera(k1), ' ¡FUERA!', ''));
        if hay2
            k2 = min(k, numel(op.hist2.t));
            actualizar(M2, op.hist2, k2);
            txt = {txt, sprintf('%s: v = %.1f m/s   e_{ct} = %+.2f m%s', op.nombres{2}, ...
                  op.hist2.vx(k2), M2.ect(k2), ternario(M2.fuera(k2), ' ¡FUERA!', ''))};
        end
        if ~isempty(op.Ld)
            P = puntoObjetivo(hist.X(k1), hist.Y(k1), centro, op.Ld);
            set(hObj,  'XData', P(1), 'YData', P(2), 'ZData', 0.3);
            set(hRayo, 'XData', [hist.X(k1) P(1)], 'YData', [hist.Y(k1) P(2)], 'ZData', [0.3 0.3]);
        end
        if op.seguir
            X = hist.X(k1); Y = hist.Y(k1); psi = hist.psi(k1);
            camtarget(ax, [X Y 0.3]);
            campos(ax, [X - 14*cos(psi), Y - 14*sin(psi), 7]);
            camva(ax, 50);
        end
        title(ax, txt);
        drawnow;
        if ~isempty(vid)
            writeVideo(vid, getframe(fig));
        elseif ~isempty(op.gif)
            exportgraphics(fig, op.gif, 'Append', k ~= idx(1));
        else
            pause(op.paso*dt);
        end
    end
    if ~isempty(vid)
        close(vid);  fprintf('Vídeo guardado: %s\n', op.video);
        if isvalid(fig), close(fig); end
        return
    end
    if ~isempty(op.gif) || ~isvalid(fig), return; end
    pause(1);
    end
end

function M = prepararModelo(ax, h, p, color, semi)
% Coche, traza y datos derivados de una simulación.
    dt = h.t(2) - h.t(1);
    M.ect   = h.ect;
    M.fuera = abs(h.ect) > semi;
    M.Xout  = h.X;  M.Xout(~M.fuera) = NaN;
    M.ay    = h.vx .* gradient(unwrap(h.psi), dt);        % r estimada derivando psi
    M.traza  = plot3(ax, NaN, NaN, NaN, '-', 'Color', color, 'LineWidth', 1.2, 'HandleVisibility','off');
    M.trazaF = plot3(ax, NaN, NaN, NaN, '-', 'Color', color, 'LineWidth', 4,   'HandleVisibility','off');
    ancho = 1.4; alto = 0.5;
    xs = [-(p.lt + 0.3), p.ld + 0.3];  ys = [-ancho/2, ancho/2];  zs = [0, alto];
    [Xc, Yc, Zc] = ndgrid(xs, ys, zs);
    F = [1 2 4 3; 5 6 8 7; 1 2 6 5; 3 4 8 7; 1 3 7 5; 2 4 8 6];
    M.tf = hgtransform('Parent', ax);
    patch('Vertices', [Xc(:) Yc(:) Zc(:)], 'Faces', F, 'FaceColor', color, 'FaceAlpha', 0.85, 'Parent', M.tf);
    line([p.ld+0.3, p.ld+1.0], [0 0], [alto alto], 'Color','k', 'LineWidth', 3, 'Parent', M.tf);
    M.eV = [];  M.aV = [];
end

function actualizar(M, h, k)
% Mueve coche, traza y curvas en vivo de una simulación al instante k.
    set(M.tf, 'Matrix', makehgtform('translate', [h.X(k) h.Y(k) 0], 'zrotate', h.psi(k)));
    set(M.traza,  'XData', h.X(1:k),    'YData', h.Y(1:k), 'ZData', 0.03*ones(1,k));
    set(M.trazaF, 'XData', M.Xout(1:k), 'YData', h.Y(1:k), 'ZData', 0.04*ones(1,k));
    set(M.eV, 'XData', h.t(1:k), 'YData', M.ect(1:k));
    set(M.aV, 'XData', h.t(1:k), 'YData', M.ay(1:k));
end

function P = puntoObjetivo(x, y, centro, Ld)
% Primer punto de la línea central, por delante del más cercano, a distancia >= Ld.
    N = size(centro, 1);
    [~, i] = min((centro(:,1)-x).^2 + (centro(:,2)-y).^2);
    for s = 0:N-1
        j = mod(i - 1 + s, N) + 1;
        if hypot(centro(j,1)-x, centro(j,2)-y) >= Ld, P = centro(j,:); return; end
    end
    P = centro(i,:);
end

function out = ternario(c, a, b)
    if c, out = a; else, out = b; end
end
