# Práctica #3 – Programación Avanzada Web

Aplicación web desarrollada como parte de la **Práctica #3 del curso Programación Avanzada Web**.  
El proyecto permite consultar compras registradas y realizar **abonos o pagos parciales**, actualizando automáticamente el saldo y el estado de cada compra.

## Objetivo

Implementar una solución web utilizando una arquitectura separada en:

- **Proyecto Web** con patrón MVC en .NET Core.
- **Proyecto API** con patrón MVC en .NET Core.
- **SQL Server** como base de datos.
- **Dapper** para el acceso a datos.
- **Procedimientos almacenados** para las operaciones contra la base de datos.

## Arquitectura

La solución debe contemplar una separación similar a la siguiente:

```text
Solución
│
├── Proyecto Web MVC
│   ├── Controllers
│   ├── Models
│   ├── Views
│   └── wwwroot
│
├── Proyecto API MVC
│   ├── Controllers
│   ├── Models
│   └── Acceso a datos con Dapper
│
└── Base de Datos
    ├── Principal
    ├── Abonos
    └── Procedimientos almacenados
```

> Los nombres reales de los proyectos, controladores, modelos y procedimientos almacenados pueden variar según la implementación realizada.

## Base de datos

La base de datos utilizada en el script suministrado se llama:

```sql
PracticaS13
```

### Tabla `Principal`

Almacena la información principal de cada compra.

| Campo | Tipo | Descripción |
|---|---|---|
| `Id_Compra` | `BIGINT IDENTITY` | Identificador único de la compra. |
| `Precio` | `DECIMAL(18,5)` | Precio original de la compra. |
| `Saldo` | `DECIMAL(18,5)` | Saldo pendiente de pago. |
| `Descripcion` | `VARCHAR(500)` | Descripción del producto o compra. |
| `Estado` | `VARCHAR(100)` | Estado de la compra, por ejemplo `Pendiente` o `Cancelado`. |

El script incluye cinco registros iniciales en estado `Pendiente`.

### Tabla `Abonos`

Registra los pagos parciales realizados sobre una compra.

| Campo | Tipo | Descripción |
|---|---|---|
| `Id_Compra` | `BIGINT` | Compra a la que pertenece el abono. |
| `Id_Abono` | `BIGINT IDENTITY` | Identificador único del abono. |
| `Monto` | `DECIMAL(18,2)` | Monto abonado. |
| `Fecha` | `DATETIME` | Fecha en la que se registra el abono. |

La tabla `Abonos` mantiene una llave foránea hacia `Principal.Id_Compra`.

## Funcionalidades

### 1. Consulta

La opción **Consulta** permite visualizar todas las compras registradas, independientemente de su estado.

La información mostrada debe incluir:

- Código de compra.
- Descripción.
- Precio.
- Saldo.
- Estado.

Los registros deben ordenarse por estado, mostrando primero las compras **Pendientes**.

### 2. Registro de abonos

La opción **Registro** permite realizar un pago parcial sobre una compra pendiente.

El formulario contempla:

- **Compra:** lista desplegable con únicamente las compras cuyo estado sea `Pendiente`.
- **Saldo anterior:** campo de solo lectura.
- **Abono:** campo obligatorio para ingresar el monto que se desea pagar.
- **Botón Abonar:** registra el pago parcial.

Cuando el usuario selecciona una compra, el saldo pendiente debe cargarse dinámicamente mediante **JavaScript, jQuery y Ajax**.

## Reglas de negocio

Al registrar un abono se deben cumplir las siguientes reglas:

1. La compra seleccionada debe encontrarse en estado `Pendiente`.
2. El monto del abono es obligatorio.
3. El abono no puede ser mayor que el saldo anterior.
4. El abono debe registrarse en la tabla `Abonos`.
5. El monto abonado debe descontarse del campo `Saldo` de la tabla `Principal`.
6. Si el nuevo saldo queda en `0`, el estado de la compra debe cambiar a `Cancelado`.
7. Después de registrar correctamente el abono, el sistema debe redireccionar a la vista **Consulta**.

### Ejemplo

Si una compra tiene un saldo de:

```text
₡50,000
```

y se registra un abono de:

```text
₡15,000
```

el nuevo saldo será:

```text
₡35,000
```

La compra continuará en estado:

```text
Pendiente
```

Si posteriormente se abonan los ₡35,000 restantes, el saldo será `0` y el estado deberá actualizarse a:

```text
Cancelado
```

## Flujo general

```text
Usuario
   │
   ▼
Proyecto Web MVC
   │
   │ Solicitud HTTP / Ajax
   ▼
Proyecto API MVC
   │
   │ Dapper + Procedimientos almacenados
   ▼
SQL Server
   │
   ├── Principal
   └── Abonos
```

## Flujo del registro de un abono

```text
Seleccionar compra pendiente
          │
          ▼
Consultar saldo actual
          │
          ▼
Mostrar saldo anterior
          │
          ▼
Ingresar monto del abono
          │
          ▼
Validar monto <= saldo
          │
          ▼
Registrar en Abonos
          │
          ▼
Actualizar saldo en Principal
          │
          ▼
¿Saldo = 0?
     │          │
    Sí          No
     │          │
     ▼          ▼
 Cancelado   Pendiente
     │          │
     └────┬─────┘
          ▼
Redireccionar a Consulta
```

## Tecnologías requeridas

- .NET Core
- ASP.NET Core MVC
- ASP.NET Core Web API
- SQL Server
- Dapper
- Procedimientos almacenados
- HTML
- CSS
- JavaScript
- jQuery
- Ajax

## Configuración de la base de datos

1. Abrir **SQL Server Management Studio**.
2. Ejecutar el script de base de datos suministrado.
3. Verificar que se haya creado la base:

```sql
PracticaS13
```

4. Verificar la existencia de las tablas:

```sql
SELECT * FROM Principal;
SELECT * FROM Abonos;
```

5. Configurar en los proyectos la cadena de conexión correspondiente al servidor SQL Server utilizado.

Ejemplo de estructura:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=SERVIDOR;Database=PracticaS13;Trusted_Connection=True;TrustServerCertificate=True;"
  }
}
```

> Sustituir `SERVIDOR` por el nombre de la instancia de SQL Server utilizada en el equipo.

## Ejecución

1. Restaurar las dependencias de los proyectos.
2. Verificar la cadena de conexión.
3. Ejecutar primero el proyecto **API**.
4. Verificar que el proyecto Web esté configurado para consumir la URL correcta de la API.
5. Ejecutar el proyecto **Web MVC**.
6. Desde el menú principal ingresar a:
   - **Consulta**, para visualizar las compras.
   - **Registro**, para realizar un abono.

## Validaciones esperadas

El sistema debe impedir situaciones como:

```text
Saldo actual: ₡10,000
Abono ingresado: ₡15,000
```

Resultado esperado:

```text
El abono no puede ser mayor al saldo anterior.
```

También debe impedir el envío del formulario cuando el monto del abono no haya sido indicado.

## Datos iniciales

El script suministrado contiene las siguientes compras de prueba:

| Código | Descripción | Precio inicial | Estado |
|---:|---|---:|---|
| 1 | Producto 1 | ₡50,000 | Pendiente |
| 2 | Producto 2 | ₡13,500 | Pendiente |
| 3 | Producto 3 | ₡83,600 | Pendiente |
| 4 | Producto 4 | ₡1,220 | Pendiente |
| 5 | Producto 5 | ₡480 | Pendiente |

## Consideraciones

- La consulta debe mostrar registros pendientes y cancelados.
- El dropdown de registro debe mostrar únicamente compras pendientes.
- El saldo anterior no debe ser editable manualmente.
- La consulta del saldo debe realizarse dinámicamente.
- La actualización del saldo y el registro del abono deben mantener consistencia entre las tablas.
- Al cancelar por completo una compra, esta ya no debe aparecer como opción disponible para nuevos abonos.

## Autoría

Proyecto académico correspondiente al curso **Programación Avanzada Web – Ingeniería en Sistemas de Computación**.

## Licencia

Proyecto elaborado con fines exclusivamente académicos.
