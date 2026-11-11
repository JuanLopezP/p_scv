# 01b. Pruebas de la competición: qué interviene y de dónde sale

Documento descriptivo. Para cada prueba se recoge en qué consiste, qué archivos intervienen, qué parámetros usa y de qué práctica viene cada cosa.

## 1. Elementos comunes

### 1.1. Cómo se ejecuta una prueba

Todas las pruebas se ejecutan desde `proyecto_scv.mlx` siguiendo la misma estructura:
- Primero se definen unos parámetros genéricos, comunes a todas las pruebas.
- Después, cada prueba tiene su propia sección con los parámetros que intervienen en sus resultados, la llamada a su simulación y, por último, sus resultados en gráficas.

En cada paso de tiempo `dt`, el simulador de la prueba llama al controlador, que calcula las entradas `u = [Fx; delta]`, y la planta `pasoDinamico` devuelve el estado siguiente:


```
proyecto_scv.mlx  →  simularEx  →  controlador(es)  →  u = [Fx; delta]  →  pasoDinamico  →  z siguiente
```

### 1.2. Parámetros comunes del vehículo

Vienen de la P2 [2] y los usan todas las pruebas, porque todas usan `pasoDinamico`. Su significado físico está en `01_analisis_planta.md` §2.4.

Se sitúan en la parte superior porque son comunes a todas las pruebas y, por tanto, deben estar disponibles y fijos en todas las llamadas a las funciones. De esta forma, cualquier modificación básica del modelo general se hace desde un único sitio y se aplica a todas las pruebas. Esto incluye los parámetros de forma y aerodinámica del vehículo, sus actuadores (motor y frenos), los neumáticos y su dinámica lateral.

Aunque una prueba vaya en línea recta, como E1, los parámetros del neumático también le afectan: `pasoDinamico` limita la fuerza longitudinal al agarre disponible, `Fx_max = mu_d·Fzd + mu_t·Fzt`.

### 1.3. Modificaciones comunes a todas las pruebas

| Qué se ha cambiado | Por qué |
|---|---|
| | |

---

## 2. E1 · Aceleración y frenada

### 2.1. En qué consiste

La prueba consiste en un tramo de aceleración, desde parado hasta una velocidad objetivo (`ctrl.v_cru`), seguido de una frenada fuerte para detener el vehículo antes de la línea límite `p.x_box`. El tiempo se mide al cruzar la línea de cronometraje `p.x_meta`.

### 2.2. Qué interviene

```
simularE1  →  controlVelocidadSimple  →  u = [Fx; 0]  →  pasoDinamico
```

### 2.3. Parámetros

| Parámetro | Valor | Origen | Para qué sirve |
|---|---|---|---|
| `p.x_meta` | 75 m | P1 | |
| `p.x_box` | 100 m | P1 | |
| `ctrl.v_cru` | 25 m/s | P1 | |
| `ctrl.x_fren` | 78 m | P1 | |
| `ctrl.Kp` | 800 N/(m/s) | P1 | |
| `ctrl.Ki` | 200 N/m | P1 | |
| `z0` | [0; 0; 0; 0; 0; 0] | Propio | |
| `dt` | 0,005 s | P1 | |
| `Tmax` | 20 s | P1 | |

### 2.4. Funciones

| Función | Origen | Qué hace |
|---|---|---|
| `simularE1` | P1 | |
| `controlVelocidadSimple` | P1 (`controlLongitudinal`) | |
| `pasoDinamico` | P2 | |
| `animarE1` | Propio | |

### 2.5. Modificaciones respecto a la base del profesor

| Elemento | Qué se ha cambiado | Por qué |
|---|---|---|
| `simularE1` | | |
| `z0` | | |
| `controlVelocidadSimple` | | |
| `pasoDinamico` | | |

---

## 3. E2 · Skidpad

### 3.1. En qué consiste

<!-- Redactar. -->

### 3.2. Qué interviene

```
simularE2  →  controlVelocidadSimple  →  u = [Fx; delta fijo]  →  pasoCinematico / pasoDinamico
```

### 3.3. Parámetros

| Parámetro | Valor | Origen | Para qué sirve |
|---|---|---|---|
| `ctrl.v_skid` | 5 m/s | P2 | |
| `ctrl.Kp` | 800 N/(m/s) | P2 | |
| `ctrl.Ki` | 200 N/m | P2 | |
| `geom.R_in` | 15,25/2 m | P2 | |
| `geom.R_out` | R_in + 3 m | P2 | |
| `geom.R` | (R_in + R_out)/2 | P2 | |
| `z0` | [0; −R; 0; v_skid; 0; 0] | P2 | |
| `dt` | 0,002 s | P2 | |
| `Tmax` | ≈ 2,5 vueltas | P2 | |

### 3.4. Funciones

| Función | Origen | Qué hace |
|---|---|---|
| `simularE2` | P2 | |
| `controlVelocidadSimple` | P2 (`controlLongitudinal`) | |
| `pasoCinematico` | P2 | |
| `pasoDinamico` | P2 | |
| `informarVueltas` | P2 | |
| `animarE2` | Propio | |

### 3.5. Modificaciones respecto a la base del profesor

| Elemento | Qué se ha cambiado | Por qué |
|---|---|---|
| `simularE2` | | |
| `controlVelocidadSimple` | | |
| `pasoCinematico`, `pasoDinamico`, `informarVueltas` | | |
| Gráficas en el Live Script | | |

---

## 4. E3 · Autocross

### 4.1. En qué consiste

<!-- Redactar. -->

### 4.2. Qué interviene

```
generarPista  →  simularE3  →  controlLateral (Pure Pursuit)    →  delta ┐
                               controlVelocidadSimple (PI)       →  Fx    ┴→  pasoDinamico
                               errorLateral (métrica)
```

### 4.3. Parámetros

| Parámetro | Valor | Origen | Para qué sirve |
|---|---|---|---|
| `ancho` | 3,0 m | P4 | |
| `p.v_set` | | P4 | |
| `p.kv_Ld` | 0,4 s | P4 | |
| `p.Ld_min` | | P4 | |
| `p.delta_max` | 30° | P4 | |
| `p.Kv_v` | 800 N/(m/s) | P4 | |
| `p.Ki_v` | 200 N/m | P4 | |
| `z0` | inicio de pista, v_set/2 | P4 | |
| `dt` | 0,01 s | P4 | |

### 4.4. Funciones

| Función | Origen | Qué hace |
|---|---|---|
| `simularE3` | P4 | |
| `controlLateral` | P4 (Pure Pursuit, propio) | |
| `controlVelocidadSimple` | P4 | |
| `generarPista` | P4 | |
| `errorLateral` | P4 | |
| `pasoDinamico` | P2 | |
| `animarE3` | Propio | |

### 4.5. Modificaciones respecto a la base del profesor

| Elemento | Qué se ha cambiado | Por qué |
|---|---|---|
| `controlLateral` | | |
| Funciones de la P4 | | |
| `controlVelocidadSimple` | | |

---

## 5. E4 · ACC (seguimiento de un líder)

### 5.1. En qué consiste

<!-- Redactar. -->

### 5.2. Qué interviene

```
simularE4  →  liderVel (líder)
           →  controlLongitudinal (ACC)  →  u = [Fx; 0]  →  pasoDinamico
```

### 5.3. Parámetros

| Parámetro | Valor | Origen | Para qué sirve |
|---|---|---|---|
| `p.d0` | 6 m | P3 | |
| `p.h` | 1,5 s | P3 | |
| `p.Kv` | 1,5 1/s | P3 | |
| `p.Kg` | 0,4 1/s² | P3 | |
| `p.Kd` | 1,0 1/s | P3 | |
| `p.jerk_max` | 2,5 m/s³ | P3 | |
| `p.v_set` | 15 m/s | Propio (P3: 25) | |
| `p.dt` | 0,002 s | P3 | |
| `esc.lead_X0` | 30 m | P3 | |
| `esc.Tmax` | 30 s | Propio (P3: 22) | |
| `z0` | [0; 0; 0; 0; 0; 0] | P3 | |

### 5.4. Funciones

| Función | Origen | Qué hace |
|---|---|---|
| `simularE4` | P3 | |
| `controlLongitudinal` | P3 | |
| `liderVel` | P3 | |
| `pasoDinamico` | P2 | |
| `animarE4` | Propio | |

### 5.5. Modificaciones respecto a la base del profesor

| Elemento | Qué se ha cambiado | Por qué |
|---|---|---|
| `simularE4`, `controlLongitudinal`, `pasoDinamico` | | |
| `liderVel` | | |
| `p.v_set` | | |
| `esc.Tmax` | | |

---

## Referencias

[1] Rodríguez Martínez, D. (2026). *P1. Dinámica Longitudinal del Vehículo*. Universidad de Málaga.

[2] Rodríguez Martínez, D. (2026). *P2. Dinámica Lateral del Vehículo*. Universidad de Málaga.

[3] Rodríguez Martínez, D. (2026). *P3. Control ACC*. Universidad de Málaga.

[4] Rodríguez Martínez, D. (2026). *P4. Seguimiento de Trayectoria*. Universidad de Málaga.
