function [tx, ty, idx] = buscarPuntoAdelante(path, x, y, Ld, idx)
% Devuelve el punto objetivo y el índice actualizado.
    N = size(path,1);
    
    d2 = (path(:,1)-x).^2 + (path(:,2)-y).^2; % en caso de desvio, reanclar el indice al punto más cercano
    [~, icerca] = min(d2);
    idx = icerca;

    for step = 0:N % avanza por el path hasta acumular Ld
        j = mod(idx-1+step,N)+1;
        if hypot(path(j,1)-x, path(j,2)-y) >= Ld
            tx = path(j,1);  ty = path(j,2);  idx = j;  return;
        end
    end
    j = mod(idx-1+round(N/10), N) + 1; % si ningún punto está tan lejos, usa el más adelantado disponible
    tx = path(j,1);  ty = path(j,2);  idx = j;
end
