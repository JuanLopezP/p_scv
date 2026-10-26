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

Ejemplo de un tractor en ladera, este se escurre y se tuerce pero el gps tiene que intentar seguir la trayectoria y corregir esos grados que se encuentra torcido el tractor. 

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
- Estado: `z = [X, Y, psi, vx, vy, r]`. *[¿Están e_y y e_ψ en z? ¿Quién los calcula y con qué?]*
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

## 2. Controladores geométricos: Pure Pursuit y Stanley
*(pendiente: lo vemos juntos)*

## 3. Modelo de bicicleta lineal en errores
*(pendiente)*

## 4. LQR
*(pendiente)*

## 5. MPC
*(pendiente)*

## 6. Puente con el autoguiado agrícola (StarFire)
*(pendiente)*


### ¿Qué significa seguir una trayectoria? 

1. Controlador lateral tiene que de algunra forma llevar a cero dos errores y solo puede actuar en una variable (el volante $\delta$): 
- Error lateral $e_y$: Distancia a la que estoy de la línea que me marca la trayectoria objetivo. 
- Error de rumbo: Desviación de mi morro respecto a la dirección de la línea en ese punto. 
2. Física. Puedo estar a 0 cm de la trayectoria pero estar torcido y por tanto en un segundo ya estaré fuera de esa trayectoria.
Esta es la razón por la que hacen falta los dos errores. 
3. 