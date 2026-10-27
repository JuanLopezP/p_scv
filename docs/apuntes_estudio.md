# Apuntes de estudio: control lateral y MPC

> Esqueleto con fórmulas. El texto en cursiva entre corchetes lo sustituyes tú con tus palabras.
> Lo que no tengas claro: `> DUDA: ...`

---

## 1. El problema del seguimiento de trayectoria

### 1.1 Idea
 
 El controlador lateral tiene que llevar a 0 dos errores, y solo puede para ello actuar sobre una variable de entrada $\delta$. Los errores son: 
 - Error lateral $e_y$; a cuantos metros estoy de la línea que marca la trayectoria que quiero seguir.
 - Error de rumbo: cuanto se desvía mi morro respecto a la dirección de la línea en ese punto. 

### 1.2 Física


La desviación respecto a la trayectoria es $e_y$. Puedo estar desviado 0cm pero torcido 3-4º y eso me llevará a que en el próximo segundo me haya salido de la trayectoria. 

Ejemplo de un tractor en ladera, este se escurre y se tuerce. Para corregir esa desviación el controlador mantiene el morro hacia arriba para ir compensando y mantener la trayectoria.  

### 1.3 Matemáticas

Errores de seguimiento respecto al punto más cercano de la trayectoria:

$$
e_y = \text{distancia con signo del vehículo a la trayectoria} \quad (+\ \text{izquierda})
$$

$$
e_\psi = \psi - \psi_{ref}
$$

Evolución del error lateral:

$$
\dot e_y = v_x \sin e_\psi + v_y \cos e_\psi \;\approx\; v_x\, e_\psi + v_y \qquad (e_\psi \text{ pequeño})
$$

Cadena causal (del actuador al error):

$$
\delta \;\rightarrow\; F_{yd} \;\rightarrow\; r \;\rightarrow\; \psi \,(e_\psi) \;\rightarrow\; e_y
$$

Ejemplo numérico (hipótesis: $v_y \approx 0$, $e_\psi$ constante, sin corrección):

$$
e_y(1\,\text{s}) \approx v_x \sin(e_\psi)\, t = 20 \cdot \sin(3^\circ) \cdot 1 \approx 1{,}05\ \text{m}
$$

Límite físico de corrección (agarre):

$$
|a_y| \lesssim \mu\, g
$$

| Símbolo | Significado | Unidades |
|---|---|---|
| $e_y$ | Error lateral (cross-track error) | m |
| $e_\psi$ | Error de rumbo | rad |
| $\psi$ | Rumbo (guiñada) del vehículo | rad |
| $\psi_{ref}$ | Rumbo de la trayectoria en el punto más cercano | rad |
| $v_x,\ v_y$ | Velocidades longitudinal y lateral (ejes del coche) | m/s |
| $r$ | Velocidad de guiñada | rad/s |
| $\delta$ | Ángulo de dirección | rad |
| $\mu$ | Coeficiente de adherencia | – |

### 1.4 Relación con el código MATLAB
- Estado: `z = [X, Y, psi, vx, vy, r]`. Los valores de *[¿Están e_y y e_ψ en z? ¿Quién los calcula y con qué?]*
- Actuador: `u(2) = delta`.
- Trayectoria: `path` = lista de puntos [x y] (P4).
- Saturación del agarre: `Fyd`, `Fyt` en `pasoDinamico`.

### 1.5 Fuentes
- P4, *Seguimiento de trayectoria* (D. Rodríguez), introducción y cross-track error.
- Tema 2.2, *Neumáticos y dinámica lateral* (D. Rodríguez). *[diapositiva]*
- *[Externa, si la usas: indícalo]*

### 1.6 Dudas abiertas
> DUDA:

---

## 2. Controladores geométricos: Pure Pursuit

### 2.1 Idea
En la trayectoria del coche, selecciono un punto a una distancia fija por delante del coche $L_d$ (look-ahead). Obtengo el arco de circunferencia que va desde el coche hasta el punto y coloco el volante $\delta$ para recorrer ese arco. 

Cuando el coche avanza el punto avanza con él y se va recalculando todo de nuevo todo el rato. 

### 2.2 Física
Equivale a la forma en la que conducimos en la vida real, miramos a un punto en la carretera que se encuentra unos metros delante nuestra, no miramos el asfalto que hay delante de las ruedas. 

En el tractor ocurre lo mismo, miras al final de la pasada y no a la rueda.

### 2.3 Matemáticas

Hipótesis: modelo **cinemático** de bicicleta (ruedas sin deriva, $\alpha_d = \alpha_t = 0$), punto de referencia en el eje trasero.

Punto objetivo: punto de la trayectoria a distancia $L_d$ del vehículo. Ángulo entre el rumbo y la recta al punto objetivo:

$$
\alpha = \operatorname{atan2}(Y_{obj} - Y,\; X_{obj} - X) - \psi
$$

Geometría del arco (la cuerda $L_d$ subtiende el arco de radio $R$):

$$
L_d = 2R \sin\alpha \;\Rightarrow\; \kappa = \frac{1}{R} = \frac{2\sin\alpha}{L_d}
$$

Bicicleta cinemática (relación dirección–radio):

$$
\tan\delta = \frac{L}{R} = L\,\kappa
$$

Ley de control:

$$
\boxed{\;\delta = \arctan\!\left(\frac{2L\sin\alpha}{L_d}\right)\;}
$$

Distancia de anticipación dependiente de la velocidad:

$$
L_d = k_v\, v_x + L_{d,min}
$$

| Símbolo | Significado | Unidades |
|---|---|---|
| $L_d$ | Distancia de anticipación (look-ahead) | m |
| $\alpha$ | Ángulo entre el rumbo y la recta al punto objetivo | rad |
| $R,\ \kappa$ | Radio y curvatura del arco | m, 1/m |
| $L = l_d + l_t$ | Batalla | m |
| $k_v$ | Ganancia de anticipación con la velocidad | s |
| $L_{d,min}$ | Anticipación mínima (a baja velocidad) | m |

### 2.4 Relación con el código MATLAB
- Función: `[delta, mem] = controlLateral(est, path, p, mem)` (P4).
- `mem.idx`: *[¿para qué guarda el índice del último punto?]*
- Batalla: `L = p.ld + p.lt`.
- Error medido con `errorLateral(x, y, path)` (P4), positivo a la izquierda.
- *[Punto de referencia: ¿la P4 usa el CG (X, Y de `z`) o el eje trasero? Compruébalo.]*

### 2.5 Limitaciones
- Recorta curvas, esto ocurre porque el punto objetivo está lejos, ya dentro de la curva, y la cuerda que va del coche a ese punto pasa por el interior de la curva. El coche apunta a ese punto “atajando” y además el arco que calcula es más abierto que la curva real.

- Oscila cuadno tomamos una distancia $L_d$ demasiado pequeña, busca ese punto pero al llegar por la velocidad se pasa y tiene que volver a corregir. Tal y como se ve en la figura.
- A alta velocidad tenemos que aumentar la distancia $L_d$  ya que la distancia que recorremos en cada instante es mayor y por lo tanto tenemos que tener en cuenta esa distancia que recorremos mientras ajustamos el giro del volante.
![alt text](image.png)

### 2.6 Fuentes
- P4, *Seguimiento de trayectoria* (D. Rodríguez).
- Coulter, R. C. (1992). *Implementation of the Pure Pursuit Path Tracking Algorithm*. CMU-RI-TR-92-01.
- https://es.mathworks.com/help/robotics/ug/pure-pursuit-controller.html
- https://thomasfermi.github.io/Algorithms-for-Automated-Driving/Control/PurePursuit.html

### 2.7 Dudas abiertas
> DUDA:
