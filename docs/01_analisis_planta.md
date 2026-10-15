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

El modelo dinámico utiliza seis variables de estado:

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

No podemos confundir entre las posiciones globales `X`, `Y` y las velocidades locales `vx`, `vy`.

Esta diferencia requiere en algunas ocasiones utilizar las transformaciones necesarias para pasar de las 



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

Los parámetros se agrupan en la estructura `p`.

| Parámetro MATLAB | Valor P2 | Unidad | Significado |
|---|---:|---|---|
| `p.m` | 230 | kg | Masa |
| `p.g` | 9.81 | m/s² | Gravedad |
| `p.rho` | 1.225 | kg/m³ | Densidad del aire |
| `p.Cd` | 1.0 | — | Coeficiente aerodinámico |
| `p.Af` | 1.1 | m² | Área frontal |
| `p.fr` | 0.022 | — | Coeficiente de rodadura |
| `p.ld` | 0.765 | m | Distancia del CG al eje delantero |
| `p.lt` | 0.765 | m | Distancia del CG al eje trasero |
| `p.Iz` | 130 | kg·m² | Inercia de guiñada |
| `p.Cad` | 35000 | N/rad | Rigidez de deriva delantera |
| `p.Cat` | 50000 | N/rad | Rigidez de deriva trasera |
| `p.mu_t` | 1.5 | — | Coeficiente de rozamiento trasero |
| `p.mu_d` | 1.425 | — | Coeficiente de rozamiento delantero |
| `p.Fx_drive_max` | 2500 | N | Fuerza motriz máxima |
| `p.Fx_brake_max` | 5000 | N | Fuerza de frenado máxima |
| `p.theta` | 0 | rad | Inclinación de la calzada |

Los valores corresponden a la configuración proporcionada en la P2.

### 2.5. Salida de la planta

La función devuelve:

```matlab
z_next
```

con la misma estructura que el vector de estados:

\[
z_{k+1}=
\begin{bmatrix}
X_{k+1}\\
Y_{k+1}\\
\psi_{k+1}\\
v_{x,k+1}\\
v_{y,k+1}\\
r_{k+1}
\end{bmatrix}
\]

La salida representa el estado del monoplaza después de aplicar las entradas durante un paso de integración.

---

## 3. Sistemas de referencia

*Pendiente de desarrollar: sistemas global y local, orientación `psi` y transformación de velocidades.*

## 4. Modelo cinemático

*Pendiente de desarrollar: geometría del modelo de bicicleta, ángulo `beta` y ecuaciones cinemáticas.*

## 5. Modelo dinámico

*Pendiente de desarrollar: dinámica longitudinal, lateral y de guiñada mediante Newton-Euler.*

## 6. Modelo de neumáticos

*Pendiente de desarrollar: ángulos de deriva, fuerzas laterales y límites de adherencia.*

## 7. Integración numérica

*Pendiente de desarrollar: método de Euler explícito y sus implicaciones.*

## 8. Hipótesis y limitaciones

*Pendiente de desarrollar tras estudiar las ecuaciones originales.*

## 9. Conclusiones

*Pendiente de completar al finalizar el análisis.*

---

## Referencias

[1] Rodríguez Martínez, D. (2026). *P1. Dinámica Longitudinal del Vehículo*. Universidad de Málaga.

[2] Rodríguez Martínez, D. (2026). *P2. Dinámica Lateral del Vehículo*. Universidad de Málaga.