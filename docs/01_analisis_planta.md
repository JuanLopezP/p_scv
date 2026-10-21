# 01. Análisis de la planta base del monoplaza

## 1. Introducción

### 1.1. Contexto del proyecto

Este proyecto se encuentra dentro de la asignatura *Sistemas de Control de Vehículos* del Grado en Ingeniería Electrónica, Robótica y Mecatrónica de la Universidad de Málaga.

Su finalidad es estudiar, modelar y evaluar el comportamiento dinámico de un monoplaza de competición Formula Student Driverless mediante simulación en MATLAB.

Se parte del modelo desarrollado en las prácticas P1 (*Dinámica Longitudinal del Vehículo*), P2 (*Dinámica Lateral del Vehículo*), P3 (*Diseño de un controlador ACC*), P4 (*asdf*) y P5 (*adsfas*).

La P1 introduce el movimiento longitudinal del vehículo y un controlador PI de velocidad. Posteriormente, la P2 amplía la planta incorporando la dinámica lateral mediante dos aproximaciones:

- **Modelo de bicicleta cinemático:** describe el movimiento a partir de relaciones geométricas, sin considerar el deslizamiento de los neumáticos para los que se asume un modelo lineal.

- **Modelo de bicicleta dinámico:** incorpora fuerzas laterales de los neumáticos, ángulos de deriva y dinámica de guiñada.

El modelo dinámico de la P2 constituye la planta base sobre la que se estudiará una mejora específica del comportamiento del monoplaza.

### 1.2. Objetivos del análisis

Antes de modificar la planta, es necesario comprender su formulación y las simplificaciones empleadas.

Los objetivos de este documento son:

1. Identificar las variables de entrada, los estados y los parámetros del modelo.
2. Comprender los sistemas de referencia utilizados.
3. Deducir las ecuaciones cinemáticas y dinámicas que describen el movimiento del monoplaza.
4. Analizar el modelo de interacción entre neumáticos y calzada.
5. Estudiar el procedimiento de integración numérica.
6. Identificar las hipótesis y limitaciones de la planta original.
7. Establecer una base teórica para evaluar posibles mejoras.


## 2. Arquitectura de la planta

### 2.1. Descripción general

La planta representa el modelo del sistema físico cuyo comportamiento queremos estudiar y controlar. Esta planta sirve de base para aplicar las diferentes acciones de control que nos permitirán ajustar y a la que acoplaremos el controlador.

El sistema físico que estamos modelando es un monoplaza en el que partimos de un modelo considerablemente básico al que iremos añadiendo complementos que pueden hacer que se mejoren las capacidades o que se empeoren.

La planta nos permite obtener el estado en el que se va a encontrar el vehículo en el instante siguiente de la simulación.

Se nos proporciona dos modelos: 
- Modelo cinemático, basado en relaciones geométricas para describir el movimiento lateral. 
- Modelo dinámico, añade fuerzas laterales y las inercias del vehículo. 

### 2.2. Vector de estados

El los modelos proporcionados utilizan seis variables de estado:

$$
z = \begin{bmatrix}
X \\ Y \\ \psi \\ v_x \\ v_y \\ r
\end{bmatrix}
$$

| Variable | Descripción | Unidad |
|---|---|---|
| `X` | Posición longitudinal global del centro de gravedad | m |
| `Y` | Posición lateral global del centro de gravedad | m |
| `psi` | Orientación del vehículo respecto al sistema global | rad |
| `vx` | Velocidad longitudinal en el sistema del vehículo | m/s |
| `vy` | Velocidad lateral en el sistema del vehículo | m/s |
| `r` | Velocidad angular de guiñada | rad/s |

No podemos confundir entre las posiciones globales `X`, `Y` y las velocidades locales `vx`, `vy`. Estas últimas depende del eje x e y del chasis.




### 2.3. Vector de entradas

El modelo recibe dos entradas:

$$
u=
\begin{bmatrix}
F_x\\
\delta
\end{bmatrix}
$$

| Variable | Descripción | Unidad |
|---|---|---|
| `Fx` | Fuerza longitudinal solicitada | N |
| `delta` | Ángulo de dirección | rad |

La entrada `Fx` se toma por simplicidad. No tomamos la posición del acelerador para evitar modelar como esto afecta a las revoluciones del motor y el par que este debe entregar. Tampoco tomamos el par entregado por el motor para evitar modelar subsistemas como, la relación de transmisión, el rendimiento, dinámica de rotación de las ruedas o la adherencia del neumático.

La entrada `delta` representa el ángulo de dirección empleado en el modelo de bicicleta.

### 2.4. Parámetros físicos

Los parámetros se agrupan en la estructura `p` y caracterizan las propiedades del monoplaza. Estos se mantienen constantes durante cada ensayo.

| Parámetro MATLAB | Valor P2 | Unidad | Significado |
|---|---:|---|---|
| `p.m` | 230 | kg | Masa |
| `p.g` | 9.81 | m/s² | Gravedad |
| `p.rho` | 1.225 | kg/m³ | Densidad del aire |
| `p.Cd` | 1.0 | — | Coeficiente de resistencia aerodinámica |
| `p.Af` | 1.1 | m² | Área frontal |
| `p.fr` | 0.022 | — | Coeficiente de rodadura |
| `p.ld` | 0.765 | m | Distancia del CG al eje delantero |
| `p.lt` | 0.765 | m | Distancia del CG al eje trasero |
| `p.Iz` | 130 | kg·m² | Inercia de guiñada |
| `p.Cad` | 35000 | N/rad | Rigidez de deriva delantera |
| `p.Cat` | 50000 | N/rad | Rigidez de deriva trasera |
| `p.mu_t` | 1.5 | — | Coeficiente de adherencia trasero |
| `p.mu_d` | 1.425 | — | Coeficiente de adherencia delantero |
| `p.Fx_drive_max` | 2500 | N | Límite de fuerza motriz máxima |
| `p.Fx_brake_max` | 5000 | N | Límite de fuerza de frenado máxima |
| `p.theta` | 0 | rad | Inclinación de la calzada |

Los valores corresponden a la configuración proporcionada en las prácticas como modelo base.

### 2.5. Interfáz y salida de la planta

La función devuelve:

```matlab
z_next
```

con la misma estructura que el vector de estados:
$$

z_{k+1}=
\begin{bmatrix}
X_{k+1}\\
Y_{k+1}\\
\psi_{k+1}\\
v_{x,k+1}\\
v_{y,k+1}\\
r_{k+1}
\end{bmatrix}
$$

La salida nos da los valores de las variables de estado en el siguiente instante en base a como se encontraba y las entradas que están actuando sobre él. Repetir este cálculo durante el tiempo de simulación será lo que nos permita obtener las gráficas con el comportamiento del monoplaza.

---

## 3. Sistemas de referencia

*Pendiente de desarrollar: sistemas global y local, orientación `psi` y transformación de velocidades.*

## 4. Modelo cinemático

*Pendiente de desarrollar: geometría del modelo de bicicleta, ángulo `beta` y ecuaciones cinemáticas.*

## 5. Modelo dinámico

*Pendiente de desarrollar: dinámica longitudinal, lateral y de guiñada mediante Newton-Euler.*

## 6. Modelo de neumáticos

### 6.1. Ángulos de deriva

El angulo de deriva $\alpha$ es el angulo entre hacia dónde apunta la rueda y hacia dónde se mueve realmente la zona que está en contacto con la superficie. 

¿Por qué ocurre? --> La goma se deforma en la huella de contacto, y esa deformación es la que genera la fuerza lateral. Si no tengo $ \alpha$ no tengo Fy. 

Velocidad lateral del punto de contacto de cada eje, en ejes del vehículo:

$$
v_{y,d} = v_y + l_d\,r \qquad v_{y,t} = v_y - l_t\,r
$$

Razón por la que los signos se invierten: Pongo una regla girando sobre su centro: un extremo se mueve hacia un lado y el otro hacia el otro, esto será más rápido cuanto más lejos esté ese punto del centro. Si tengo que el coche gira a la izquierda ocurrirá: 
- El eje delantero se desplaza a la izquierda
- El eje trasero se desplaza a la derecha (signo contrario al delantero).

Todo esto se suma a la velocidad $ v_y $.

Ángulos de deriva (aproximación de ángulos pequeños, $\tan\alpha \approx \alpha$):

$$
\alpha_d = \delta - \frac{v_y + l_d\,r}{v_x}
\qquad
\alpha_t = -\,\frac{v_y - l_t\,r}{v_x}
$$

| Variable | Descripción | Unidad |
|---|---|---|
| `alpha_d` | Ángulo de deriva del eje delantero | rad |
| `alpha_t` | Ángulo de deriva del eje trasero | rad |
| `delta` | Ángulo de dirección (solo eje delantero) | rad |
| `vx_c` | Velocidad longitudinal corregida, $\max(v_x, 1)$ | m/s |

Implementación en `pasoDinamico`:

```matlab
vx_c = max(vx, 1.0); % Tomo esto para tomar como mínimo 1 y no dividir entre 0 
alpha_d = delta - (vy + p.ld*r)/vx_c;
alpha_t = - (vy - p.lt*r)/vx_c;
```


Repaso de los ángulos: 

| Ángulo | Entre... | ...y... |
|---|---|---|
| $\delta$ (dirección) | eje longitudinal del chasis | plano de la rueda delantera |
| $\beta$ (deriva del vehículo) | eje longitudinal del chasis | vector velocidad del CG, $\beta = \arctan(v_y/v_x)$ |
| $\alpha$ (deriva del neumático) | plano de la rueda | vector velocidad **del punto de contacto de esa rueda** |

### 6.2. Fuerza lateral en la zona lineal

Para que un vehículo se mueva en círculo debe haber una fuerza que lo mantenga ahí. Esta fuerza se genera en los neumáticos, que son los que están en contacto con el suelo. Estos actúan como un muelle situado en horizontal, si la rueda tiene un cierto ángulo $\alpha$ la goma se retorcerá de lado y de la misma forma esta ejercerá una fuerza en sentido contrario. 


$$
F_{y,d} = C_{\alpha d}\,\alpha_d \qquad F_{y,t} = C_{\alpha t}\,\alpha_t
$$

| Parámetro | Valor P2 | Unidad |
|---|---:|---|
| `p.Cad` | 35000 | N/rad |
| `p.Cat` | 50000 | N/rad |

$C_\alpha$ es la dureza del muelle y depende de las propiedades del neumático, en nuestro caso vale menos el delantero que el trasero. Por esta razón, el eje delantero deriva más y el vehículo describe un radio mayor al que impone la dirección. 

Fuerza que debe dar cada eje y ángulo resultante.

$$
F_{y,d} = m\,a_y\,\frac{l_t}{L} \;\Rightarrow\; \alpha_d = \frac{F_{y,d}}{C_{\alpha d}}
\qquad
F_{y,t} = m\,a_y\,\frac{l_d}{L} \;\Rightarrow\; \alpha_t = \frac{F_{y,t}}{C_{\alpha t}}
$$

El gradiente de subviraje representa cuánto volante extra necesito por cada unidad de aceleración lateral $a_y$:

$$
\delta = \frac{L}{R} + K\,a_y
\qquad
K = \frac{m}{L}\left(\frac{l_t}{C_{\alpha d}} - \frac{l_d}{C_{\alpha t}}\right)
$$

Sin deriva sería, para un radio R $ \delta = L/R $. Pero al trabajar con neumáticos reales el eje delantero deriva más que el trasero y hay que corregir $\delta$ para el mismo círculo. Esto depende proporcionalmente de la aceleración. 

Casos: 
- K > 0 vehículo subvirador. 
- K = 0 vehículo neutro. 
- K < 0 vehículo sobrevirador.

En nuestra práctica el simulador del skidpad deja $\delta$ fijo, no se añade ese giro de volante extra para compensar y como consecuencia el radio de giro se abre. Si incluimos un controlador lateral, este debería de ser capáz de corregir ese error. 

### 6.3. Límites de adherencia

El muelle solo empuja hasta un máximo, a partir de ahí la goma desliza y la fuerza ya no crece.

Carga vertical por eje (estática, sin transferencia de carga):

$$
F_{z,d} = m\,g\,\frac{l_t}{L} \qquad F_{z,t} = m\,g\,\frac{l_d}{L}
$$

Saturación de la fuerza lateral:

$$
|F_{y,d}| \le \mu_d\,F_{z,d} \qquad |F_{y,t}| \le \mu_t\,F_{z,t}
$$

| Eje | $F_z$ [N] | $\mu$ | $F_{y,\max}$ [N] | $a_{y,\max}$ [g] |
|---|---:|---:|---:|---:|
| Delantero | 1128 | 1,425 | 1608 | 1,425 |
| Trasero | 1128 | 1,50 | 1692 | 1,50 |

```matlab
Fyd = max(min(Fyd, p.mu_d*Fzd), -p.mu_d*Fzd);
Fyt = max(min(Fyt, p.mu_t*Fzt), -p.mu_t*Fzt);
```

El eje que satura primero es el delantero. En el límite el coche se va de morro.

### 6.4. Fuerza longitudinal

La planta no incluye un modelo longitudinal del neumático. La fuerza $F_x$ es una entrada que se satura al agarre total:

$$
|F_x| \le F_{x,\max} = \mu_d\,F_{z,d} + \mu_t\,F_{z,t} \approx 3300\ \text{N}\ (1{,}46\,g)
$$

```matlab
Fx_max = p.mu_d*Fzd + p.mu_t*Fzt; 
Fx = max(min(Fx, Fx_max), -Fx_max);
```
En este caso estoy tomando tracción a las cuatro ruedas al tomar Fzd y Fzt.

| Límite | Valor [N] | Dónde se aplica | ¿Activo? |
|---|---:|---|---|
| Agarre total | 3300 | Planta | Solo en frenada |
| Motor `Fx_drive_max` | 2500 | Controlador | Siempre en tracción |
| Freno `Fx_brake_max` | 5000 | Controlador | No (lo recorta el agarre) |

### 6.5. Comparación con modelos más completos

| Modelo | Qué describe | Fuente | ¿En la planta P2? |
|---|---|---|---|
| Lineal con saturación | $F_y = C_\alpha\,\alpha$ hasta $\mu F_z$ | Tema 2.2, diap. 27 | Sí |
| Pacejka (Magic Formula) | Curva completa $F(\alpha)$ o $F(\kappa)$ con pico y caída | Tema 2.2, diap. 11–14 | No |
| Burckhardt | $\mu(\sigma)$ longitudinal según el firme | Tema 3.2, diap. 6 | No |
| Elipse de fricción | Límite combinado $F_x$–$F_y$ | Tema 2.2, diap. 19 | No |

Magic Formula (forma general):

$$
F = D\,\sin\!\Big(C\,\arctan\big(B\,x - E\,(B\,x - \arctan(B\,x))\big)\Big)
$$

Burckhardt:

$$
\mu(\sigma) = c_1\left(1 - e^{-c_2\,\sigma}\right) - c_3\,\sigma
$$

| Firme | $c_1$ | $c_2$ | $c_3$ | $\mu_{\max}$ | $\sigma$ del pico |
|---|---:|---:|---:|---:|---:|
| Asfalto seco | 1,2801 | 23,99 | 0,52 | ≈ 1,17 | ≈ 0,17 |
| Asfalto mojado | 0,857 | 33,822 | 0,347 | ≈ 0,80 | ≈ 0,13 |

Elipse de fricción (círculo si $\mu_x = \mu_y$):

$$
\sqrt{F_x^2 + F_y^2} \le \mu\,F_z
$$

### 6.6. Ventajas e inconvenientes de modelos más completos

| Nivel | Modelo | Estados nuevos | Parámetros nuevos | Ventaja principal | Inconveniente principal |
|---|---|---|---|---|---|
| 0 | Lineal + saturación (P2) | — | — | Simple y robusto | Tracción ideal; sin interacción Fx–Fy |
| 1 | + Elipse de fricción por eje | — | reparto de Fx | Penaliza acelerar en curva | Hay que elegir qué fuerza se prioriza |
| 2 | + Transferencia longitudinal | — | `h` | Fz realista al acelerar y frenar | `h` no viene en la P2 (hipótesis) |
| 3 | + Rueda con Burckhardt | ω por eje (+2) | `J`, `r_r`, c1–c3 | Aparece σ: permite un TCS | Cambia z; dinámica rápida (¿dt?) |
| 4 | Pacejka combinado | igual que 3 | B, C, D, E por eje | Curva completa Fx y Fy con pico | Coeficientes sin datos de neumático |


## 7. Integración numérica

*Pendiente de desarrollar: método de Euler explícito y sus implicaciones.*

## 8. Hipótesis y limitaciones

Fx actúa en el CG, así que no genera momento de guiñada. Por eso el torque vectoring (tu prioridad 3) es imposible sin cambiar la planta: necesita repartir Fx entre izquierda y derecha. Apúntalo para la sección 8.

## 9. Conclusiones

*Pendiente de completar al finalizar el análisis.*

---

## Referencias

[1] Rodríguez Martínez, D. (2026). *P1. Dinámica Longitudinal del Vehículo*. Universidad de Málaga.

[2] Rodríguez Martínez, D. (2026). *P2. Dinámica Lateral del Vehículo*. Universidad de Málaga.